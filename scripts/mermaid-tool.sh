#!/usr/bin/env bash

set -euo pipefail

REPOSITORY_ROOT="$(git rev-parse --show-toplevel)"
readonly REPOSITORY_ROOT
readonly VERSION_FILE="${REPOSITORY_ROOT}/.mermaid-version"

usage() {
    printf '%s\n' \
        "Usage:" \
        "  scripts/mermaid-tool.sh validate [FILE ...]" \
        "  scripts/mermaid-tool.sh render INPUT OUTPUT" \
        "" \
        "OUTPUT may use the .svg, .png, or .pdf extension."
}

require_mermaid_cli() {
    local required_version actual_version

    if [[ ! -f "${VERSION_FILE}" ]]; then
        printf 'Missing Mermaid version pin: %s\n' "${VERSION_FILE}" >&2
        return 1
    fi

    required_version="$(tr -d '[:space:]' <"${VERSION_FILE}")"

    if ! command -v mmdc >/dev/null 2>&1; then
        printf '%s\n' \
            "Mermaid CLI is required." \
            "Install it with:" \
            "  npm install --global --allow-scripts=puppeteer @mermaid-js/mermaid-cli@${required_version}" >&2
        return 1
    fi

    actual_version="$(mmdc --version)"
    actual_version="${actual_version#v}"
    if [[ "${actual_version}" != "${required_version}" ]]; then
        printf 'Mermaid CLI %s is required; found %s.\n' \
            "${required_version}" "${actual_version}" >&2
        return 1
    fi
}

validate_files() (
    local temporary_directory index file
    local -a files=("$@")

    if ((${#files[@]} == 0)); then
        mapfile -d '' files < <(
            git -C "${REPOSITORY_ROOT}" ls-files -z -- '*.mmd' '*.mermaid'
        )
    fi

    if ((${#files[@]} == 0)); then
        printf '%s\n' 'No tracked Mermaid files to validate.'
        return 0
    fi

    temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/mermaid-validate.XXXXXX")"
    trap 'rm -rf -- "${temporary_directory}"' EXIT

    index=0
    for file in "${files[@]}"; do
        if [[ ! -f "${file}" ]]; then
            continue
        fi

        index=$((index + 1))
        printf 'Validating %s\n' "${file}"
        mmdc --input "${file}" --output "${temporary_directory}/${index}.svg"
    done
)

render_file() {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "${input_file}" ]]; then
        printf 'Mermaid input does not exist: %s\n' "${input_file}" >&2
        return 1
    fi

    case "${output_file}" in
        *.svg | *.png | *.pdf) ;;
        *)
            printf '%s\n' 'Output must end in .svg, .png, or .pdf.' >&2
            return 1
            ;;
    esac

    mkdir -p "$(dirname "${output_file}")"
    mmdc --input "${input_file}" --output "${output_file}"
}

main() {
    local command="${1:-}"

    case "${command}" in
        validate)
            shift
            require_mermaid_cli
            validate_files "$@"
            ;;
        render)
            if (($# != 3)); then
                usage >&2
                return 2
            fi
            require_mermaid_cli
            render_file "$2" "$3"
            ;;
        *)
            usage >&2
            return 2
            ;;
    esac
}

main "$@"
