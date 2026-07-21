#!/usr/bin/env bash

set -euo pipefail

REPOSITORY_ROOT="$(git rev-parse --show-toplevel)"
readonly REPOSITORY_ROOT
readonly POLICY_FILE="${REPOSITORY_ROOT}/config/repository-actions-policy.yaml"

audit_mode="local"
enforce=false
workspace_root="$(dirname "${REPOSITORY_ROOT}")"
issue_count=0
temporary_directory=""
loaded_repository_path=""

usage() {
    printf '%s\n' \
        "Usage: scripts/audit-repository-actions.sh [OPTIONS]" \
        "" \
        "Options:" \
        "  --local-root PATH  Audit sibling checkouts below PATH (default)." \
        "  --remote           Clone repositories from GitHub before auditing." \
        "  --enforce          Return nonzero when policy violations are found." \
        "  --help             Show this help."
}

record_result() {
    local status="$1"
    local repository="$2"
    local message="$3"

    printf '%-5s %-34s %s\n' "${status}" "${repository}" "${message}"
    if [[ "${status}" == "FAIL" ]]; then
        issue_count=$((issue_count + 1))
    fi
}

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "${command_name}" >&2
        exit 2
    fi
}

prepare_remote_workspace() {
    temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/actions-audit.XXXXXX")"
    workspace_root="${temporary_directory}"
    trap 'rm -rf -- "${temporary_directory}"' EXIT
}

load_repository() {
    local owner="$1"
    local repository="$2"
    loaded_repository_path="${workspace_root}/${repository}"

    if [[ "${audit_mode}" == "remote" ]]; then
        if ! gh repo clone "${owner}/${repository}" "${loaded_repository_path}" -- \
            --depth=1 --quiet; then
            record_result FAIL "${repository}" "unable to clone repository"
            return 1
        fi
    elif [[ ! -d "${loaded_repository_path}/.git" ]]; then
        record_result FAIL "${repository}" \
            "checkout missing below ${workspace_root}"
        return 1
    fi
}

check_actionlint_hook() {
    local repository="$1"
    local repository_path="$2"
    local config_file="${repository_path}/.pre-commit-config.yaml"
    local hook_id

    if [[ ! -f "${config_file}" ]]; then
        record_result FAIL "${repository}" "missing .pre-commit-config.yaml"
        return
    fi

    hook_id="$(yq eval \
        '.repos[].hooks[] | select(.id == "actionlint") | .id' \
        "${config_file}")"
    if [[ "${hook_id}" == "actionlint" ]]; then
        record_result PASS "${repository}" "actionlint pre-commit hook"
    else
        record_result FAIL "${repository}" "actionlint pre-commit hook missing"
    fi
}

check_required_workflows() {
    local repository="$1"
    local repository_path="$2"
    local profile workflow
    local -A required_workflows=()
    local -a profiles=()

    mapfile -t profiles < <(
        REPOSITORY_NAME="${repository}" yq eval \
            '.repositories[strenv(REPOSITORY_NAME)].profiles[]' \
            "${POLICY_FILE}"
    )

    for profile in "${profiles[@]}"; do
        while IFS= read -r workflow; do
            required_workflows["${workflow}"]=1
        done < <(
            PROFILE_NAME="${profile}" yq eval \
                '.profiles[strenv(PROFILE_NAME)].required_workflows[]' \
                "${POLICY_FILE}"
        )
    done

    for workflow in "${!required_workflows[@]}"; do
        if [[ -f "${repository_path}/${workflow}" ]]; then
            record_result PASS "${repository}" "${workflow}"
        else
            record_result FAIL "${repository}" "missing ${workflow}"
        fi
    done
}

check_workflow_structure() {
    local repository="$1"
    local repository_path="$2"
    local workflow_path workflow_file uses_reference
    local has_permissions has_pull_request

    while IFS= read -r workflow_path; do
        [[ -n "${workflow_path}" ]] || continue
        workflow_file="${repository_path}/${workflow_path}"

        has_permissions="$(yq eval 'has("permissions")' "${workflow_file}")"
        if [[ "${has_permissions}" != "true" ]]; then
            record_result FAIL "${repository}" \
                "${workflow_path}: top-level permissions missing"
        fi

        if [[ "${workflow_path}" == ".github/workflows/validation.yml" ]]; then
            has_pull_request="$(yq eval '.on | has("pull_request")' \
                "${workflow_file}")"
            if [[ "${has_pull_request}" != "true" ]]; then
                record_result FAIL "${repository}" \
                    "${workflow_path}: pull_request trigger missing"
            fi
        fi

        while IFS= read -r uses_reference; do
            [[ -n "${uses_reference}" ]] || continue
            if [[ "${uses_reference}" == ./* ]]; then
                continue
            fi
            if [[ ! "${uses_reference}" =~ @[0-9a-f]{40}$ ]]; then
                record_result FAIL "${repository}" \
                    "${workflow_path}: unpinned ${uses_reference}"
            fi
        done < <(
            yq eval -r \
                '.jobs[] | (.uses // ""), (.steps[]?.uses // "")' \
                "${workflow_file}"
        )
    done < <(git -C "${repository_path}" ls-files .github/workflows)
}

check_actionlint() {
    local repository="$1"
    local repository_path="$2"
    local output

    if output="$(cd "${repository_path}" && actionlint 2>&1)"; then
        record_result PASS "${repository}" "actionlint"
    else
        record_result FAIL "${repository}" "actionlint failed"
        printf '%s\n' "${output}"
    fi
}

write_summary() {
    if [[ -z "${GITHUB_STEP_SUMMARY:-}" ]]; then
        return
    fi

    {
        printf '## Repository Actions governance audit\n\n'
        printf -- '- Mode: %s\n' "${audit_mode}"
        printf -- '- Policy violations: %d\n' "${issue_count}"
        printf -- '- Enforcement: %s\n' "${enforce}"
    } >>"${GITHUB_STEP_SUMMARY}"
}

main() {
    local owner repository repository_path
    local -a repositories=()

    while (($# > 0)); do
        case "$1" in
            --local-root)
                [[ $# -ge 2 ]] || {
                    usage >&2
                    return 2
                }
                workspace_root="$2"
                shift 2
                ;;
            --remote)
                audit_mode="remote"
                shift
                ;;
            --enforce)
                enforce=true
                shift
                ;;
            --help)
                usage
                return 0
                ;;
            *)
                usage >&2
                return 2
                ;;
        esac
    done

    require_command actionlint
    require_command git
    require_command yq
    [[ "${audit_mode}" != "remote" ]] || require_command gh

    if [[ ! -f "${POLICY_FILE}" ]]; then
        printf 'Policy file not found: %s\n' "${POLICY_FILE}" >&2
        return 2
    fi

    if [[ "${audit_mode}" == "remote" ]]; then
        prepare_remote_workspace
    fi

    owner="$(yq eval -r '.owner' "${POLICY_FILE}")"
    mapfile -t repositories < <(
        yq eval -r '.repositories | keys | .[]' "${POLICY_FILE}"
    )

    for repository in "${repositories[@]}"; do
        if ! load_repository "${owner}" "${repository}"; then
            continue
        fi
        repository_path="${loaded_repository_path}"
        check_required_workflows "${repository}" "${repository_path}"
        check_actionlint_hook "${repository}" "${repository_path}"
        check_workflow_structure "${repository}" "${repository_path}"
        check_actionlint "${repository}" "${repository_path}"
    done

    printf '\nPolicy violations: %d\n' "${issue_count}"
    write_summary

    if [[ "${enforce}" == "true" && "${issue_count}" -gt 0 ]]; then
        return 1
    fi
}

main "$@"
