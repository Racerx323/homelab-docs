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
workflow syntax, pull-request triggers, explicit permissions, and immutable
external action references.

## Run the remote audit

The scheduled workflow clones every repository declared in the policy:

```bash
scripts/audit-repository-actions.sh --remote
```

Most managed repositories are public. `bash-bcs-workspace` is private, so the
governance repository requires a `REPOSITORY_AUDIT_TOKEN` Actions secret. Use a
fine-grained personal access token with read-only Contents and Metadata access
to only the managed repositories. The workflow falls back to its repository
`GITHUB_TOKEN`, but that token cannot clone the private repository.

Do not grant write, administration, workflow, issue, or pull-request permission
to the audit token.

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
