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
| Architecture | `homelab-dns` |
| Mermaid and LikeC4 | `homelab-docs` |
| Container security | `homelab-notification` |
| PowerShell | `homelab-scripts` |
| Terraform | `homelab-terraform` |

The reusable baseline is pinned to the immutable commit recorded in
`config/repository-actions-policy.yaml`. The remote audit was verified on July
21, 2026 against the then-current 11-repository manifest with zero policy
violations. The current manifest contains ten public repositories; that historical
result does not validate the revised manifest.

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

All repositories in the current policy manifest are public. The governance
workflow uses its repository `GITHUB_TOKEN` with read-only Contents permission;
it does not require a separate audit PAT or Doppler sync. An inaccessible
repository is counted as a policy violation even in report-only mode.

### Architecture credentials

The architecture-drift workflow uses a least-privilege sync:

| Property | Value |
| --- | --- |
| Doppler source of truth | Project `homelab-dev`, environment `ci`, config `ci_architecture` |
| Doppler secret name | `ERODE_GEMINI_API_KEY` |
| GitHub sync target | Repository `Racerx323/homelab-dns`, Actions secrets |
| Workflow consumer | `.github/workflows/architecture-drift.yml` |

The `ci` root config contains only Doppler metadata. The `ci_architecture`
branch contains only the Gemini key. Do not sync either config to additional
repositories without reviewing that boundary. Retired audit credentials and
syncs require separate live cleanup; these repository edits do not revoke them.

Erode loads the canonical `architecture/likec4` workspace. Keep that workspace
valid with both the stack's pinned LikeC4 release and the LikeC4 release
embedded by the pinned Erode action. Where a presentation feature is newer
than Erode's parser, use an equivalent compatible view structure, such as
separate sequence views for alternative paths.

The workflow pins both Erode Gemini model tiers to `gemini-3.1-flash-lite`.
That stable model was verified with the scoped `ci_architecture` credential.
Model IDs are non-secret configuration and belong in the workflow, while only
the API key belongs in Doppler. Review Google's model lifecycle before changing
the IDs; do not rely on Erode's embedded defaults remaining available.

Inspect names without printing values:

```bash
doppler secrets \
  --project homelab-dev \
  --config ci_architecture \
  --only-names

gh secret list --repo Racerx323/homelab-dns
```

Trigger and verify the audit after policy or workflow changes:

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
