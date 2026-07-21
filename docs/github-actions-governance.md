# GitHub Actions Governance

This guide defines how the managed repositories receive consistent GitHub
Actions validation without duplicating the full implementation in every
repository.

## Architecture

The governance system has four layers:

1. `config/repository-actions-policy.yaml` maps repositories to validation
   profiles and required workflow paths.
2. `.github/workflows/reusable-validation.yml` provides the shared baseline
   validation job.
3. Each managed repository contains a small, commit-SHA-pinned caller workflow
   plus any specialized workflows required by its profile.
4. `.github/workflows/repository-governance.yml` runs the cross-repository
   policy audit on a schedule and on demand.

The policy starts in `report-only` mode. Missing or invalid workflows are
reported without failing the scheduled governance job. Change both the policy
and workflow invocation deliberately when enforcement is approved.

## Implementation status

The governance rollout is complete for every repository in the policy
manifest. Each repository has the shared baseline caller, the actionlint
pre-commit hook, and any workflows required by its assigned profiles.

| Profile | Repository coverage |
| --- | --- |
| Baseline | All managed repositories |
| Bats | `bash-bcs-workspace` |
| Architecture | `homelab-dns` |
| Mermaid and LikeC4 | `homelab-docs` |
| Container security | `homelab-notification` |
| PowerShell | `homelab-scripts` |
| Terraform | `homelab-terraform` |

The reusable baseline is pinned to the immutable commit recorded in
`config/repository-actions-policy.yaml`. The remote audit was verified on July
21, 2026 against all 11 managed repositories with zero policy violations.

## Baseline validation

The reusable baseline installs the versions recorded in
[Development Tool Stack](development-tool-stack.md) and runs the common local
pre-commit hook IDs. It also scans repository history with Gitleaks. Specialized
checks such as Bats, LikeC4, Mermaid, Pester, container-image scans, and
Terraform validation stay in repository-specific workflows.

Caller workflows reference the reusable workflow by a full 40-character commit
SHA. A central workflow update therefore has no effect on callers until its new
SHA is reviewed and rolled out through the policy and caller repositories.

## Run the audit locally

With all managed repositories checked out as siblings under
`/home/aaron/code`, run:

```bash
scripts/audit-repository-actions.sh
```

Use enforcement mode only when testing a clean rollout:

```bash
scripts/audit-repository-actions.sh --enforce
```

The audit verifies required workflow paths, the actionlint pre-commit hook,
workflow syntax, baseline pull-request coverage, explicit permissions, and
immutable external action references. Specialized scheduled workflows do not
need artificial pull-request triggers.

## Run the remote audit

The scheduled workflow clones every repository declared in the policy:

```bash
scripts/audit-repository-actions.sh --remote
```

Most managed repositories are public. `bash-bcs-workspace` is private, so the
governance repository requires a `REPOSITORY_AUDIT_TOKEN` Actions secret. Use a
fine-grained personal access token with read-only Contents and Metadata access
to only `bash-bcs-workspace`. The workflow falls back to its repository
`GITHUB_TOKEN`, but that token cannot clone the private repository. An
inaccessible repository is counted as a policy violation even in report-only
mode.

Do not grant write, administration, workflow, issue, or pull-request permission
to the audit token.

### Audit credential inventory

| Property | Value |
| --- | --- |
| Credential | Fine-grained GitHub personal access token |
| GitHub resource owner | `Racerx323` |
| GitHub repository access | Only `bash-bcs-workspace` |
| GitHub repository permissions | Contents: read; Metadata: read |
| Doppler source of truth | Project `homelab-dev`, environment `github`, config `ci` |
| Doppler secret name | `REPOSITORY_AUDIT_TOKEN` |
| GitHub sync target | Repository `Racerx323/homelab-docs`, Actions secrets |
| Workflow consumer | `.github/workflows/repository-governance.yml` |

The token value belongs only in Doppler and the encrypted GitHub Actions secret
created by the Doppler integration. Never put it in documentation, repository
files, shell history, issue text, workflow input, or a local `.env` file. Do not
reuse the broader GitHub CLI OAuth token.

### Doppler-to-GitHub sync

The Doppler GitHub integration synchronizes config `ci` in the `github`
environment of project `homelab-dev` to the Actions secrets for
`homelab-docs`. Doppler is the source of truth; GitHub stores the execution copy
consumed by the workflow. Update and rotate the value in Doppler, not directly
in GitHub, so later synchronization cannot overwrite an out-of-band change.

The workflow does not fetch secrets from Doppler at runtime and therefore does
not need a Doppler service token. The GitHub repository currently receives
these synchronized secret names:

- `DOPPLER_PROJECT`
- `DOPPLER_ENVIRONMENT`
- `DOPPLER_CONFIG`
- `REPOSITORY_AUDIT_TOKEN`

Inspect names without printing values:

```bash
doppler secrets \
  --project homelab-dev \
  --config ci \
  --only-names

gh secret list --repo Racerx323/homelab-docs
```

Trigger and verify the audit after initial setup or rotation:

```bash
gh workflow run repository-governance.yml \
  --repo Racerx323/homelab-docs

gh run list \
  --repo Racerx323/homelab-docs \
  --workflow repository-governance.yml \
  --limit 1

gh run watch RUN_ID \
  --repo Racerx323/homelab-docs \
  --exit-status
```

Because the audit is report-only, a successful workflow conclusion means the
audit executed, not necessarily that the violation count is zero. Open the run
summary or log and confirm `Policy violations: 0`.

### Rotate or revoke the audit PAT

1. Create a replacement fine-grained PAT with the same single-repository,
   read-only scope and a defined expiration.
2. Replace `REPOSITORY_AUDIT_TOKEN` in project `homelab-dev`, environment
   `github`, config `ci`.
3. Confirm the Doppler integration updates the GitHub Actions secret timestamp.
4. Run the governance workflow and confirm zero violations.
5. Revoke the old PAT in GitHub.

If the token is exposed or suspected of misuse, revoke it immediately, create
a replacement, update Doppler, rerun the audit, and review GitHub and Doppler
audit logs. Do not wait for the normal rotation window.

## Add a repository

1. Add the repository and its default branch, visibility, and profiles to the
   policy manifest.
2. Add `.github/workflows/validation.yml` with the current reusable workflow
   commit SHA.
3. Add the actionlint system hook to `.pre-commit-config.yaml`.
4. Add each specialized workflow required by the selected profiles.
5. Run the local audit and repository-specific tests.
6. Publish the changes and confirm a successful pull-request workflow run.

Use `frame-and-sample` as the starting template so new repositories inherit the
baseline caller and hook.

## Update the reusable workflow

1. Change and validate the reusable workflow in `homelab-docs`.
2. Merge it before changing any callers.
3. Record the merged commit SHA in the policy manifest.
4. Replace the reusable-workflow SHA in every caller.
5. Run the local audit in enforcement mode.
6. Publish the caller updates.

Never reference `main`, a mutable tag, or a shortened commit in a cross-
repository caller.
