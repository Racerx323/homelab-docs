# Erode Installation and Configuration

This guide installs Erode as the architecture-drift detection layer for the
homelab development environment. It complements the LikeC4 formatting and
validation checks described in
[LikeC4 Installation and Configuration](likec4-installation-and-configuration.md).
Provider credentials are supplied through the Doppler configuration described
in [Doppler Secrets Management](doppler-secrets-management.md).

LikeC4 validation proves that an architecture model is internally consistent.
Erode performs a different check: it compares source-code changes with the
declared architecture and reports undeclared dependencies or structural drift.

The setup is designed for:

- Ubuntu 24.04 under WSL2.
- Node.js managed by NVM.
- User-level global npm tools.
- The canonical model in `homelab-docs/architecture/likec4`.
- Local Git hooks managed by pre-commit.
- GitHub pull-request checks across the homelab repositories.
- Doppler project `homelab-dev` with default personal config `dev_personal`.

## Important limitations

Erode is experimental and under active development. Its CLI, configuration,
and findings may change between releases.

Erode uses an AI provider to analyze selected source-code diffs and LikeC4
model context. This means relevant code and architecture data are sent to the
configured Gemini, OpenAI, or Anthropic service. Review the provider's data
handling terms before enabling Erode for private or sensitive repositories.

Erode does not currently document Ollama as a supported provider. The local
Ollama installation used by BCS cannot be assumed to work with Erode.

Start with advisory results. Do not make Erode a required merge check until
its findings, operating cost, and data exposure have been evaluated.

## Prerequisites

The workstation's Node.js 26 installation satisfies Erode's Node.js 24 or
newer requirement. Verify the active NVM environment:

```bash
nvm use default
node --version
npm --version
npx --version
```

Verify the existing LikeC4 model before installing another analysis layer:

```bash
cd /home/aaron/code/homelab-docs
likec4 validate --json --no-layout architecture/likec4
```

The result must report `"valid": true` before Erode is used to judge code
changes.

Local analysis requires an API key for one supported AI provider. Doppler
supplies that key only to the Erode process. GitHub access uses the existing
GitHub CLI login instead of duplicating its token in Doppler.

Verify the credential tools before configuring Erode:

```bash
doppler --version
doppler me
gh auth status
```

The Doppler CLI must be mapped to `homelab-dev/dev_personal` at
`/home/aaron/code`. Complete the Doppler guide before continuing if any of
these checks fail.

## Install the Erode CLI globally

Install the CLI under the active NVM-managed Node.js version:

```bash
nvm use default
npm install --global @erode-app/cli
```

Verify the installation:

```bash
command -v erode
erode --version
erode --help
```

The executable is named `erode`; the npm package is named
`@erode-app/cli`.

### Preserve Erode across NVM upgrades

NVM stores global packages separately for every installed Node.js version.
Add this package as its own line in `$NVM_DIR/default-packages`:

```text
@erode-app/cli
```

The default package file should then include both architecture tools:

```text
likec4
@erode-app/cli
```

After installing a new Node.js version, verify both executables:

```bash
nvm use default
likec4 --version
erode --version
```

## Configure non-secret user defaults

Erode reads `.eroderc.json` from the current directory first and then the
user's home directory. Create `~/.eroderc.json` for defaults that apply across
all repositories:

```json
{
  "$schema": "https://erode.dev/schemas/v0/eroderc.schema.json",
  "adapter": {
    "format": "likec4",
    "modelPath": "/home/aaron/code/homelab-docs/architecture/likec4"
  },
  "constraints": {
    "maxFilesPerDiff": 50,
    "maxLinesPerDiff": 5000,
    "maxContextChars": 10000
  }
}
```

The absolute model path is intentional for this workstation-wide
configuration. It lets `erode-drift` run from any repository under
`/home/aaron/code` while using the canonical model.

Keep API keys, provider selection, and GitHub tokens out of this file. It
contains non-secret configuration; Doppler is authoritative for the provider
and provider credential.

A repository may commit its own `.eroderc.json` when it needs different
constraints or adapter settings. Environment variables override both
repository and user configuration.

## Configure local credentials with Doppler

Use the existing `homelab-dev` project and its default personal development
config, `dev_personal`. No user-named config needs to be created. In the
Doppler dashboard, add these variables to `dev_personal`:

```text
ERODE_AI_PROVIDER=gemini
ERODE_GEMINI_API_KEY=<personal Gemini API key>
```

For OpenAI or Anthropic, change `ERODE_AI_PROVIDER` and store the corresponding
Erode provider variable documented by Erode. An OpenAI API key is separate
from ChatGPT or Codex subscription sign-in.

Do not add `ERODE_GITHUB_TOKEN` to Doppler. GitHub CLI already protects that
credential, and the Erode wrapper retrieves it only when starting a check.

Configure the workspace mapping once:

```bash
cd /home/aaron/code
doppler setup --project homelab-dev --config dev_personal
doppler configure --scope "$(pwd)"
```

Verify that the expected names exist without printing their values:

```bash
doppler secrets \
  --project homelab-dev \
  --config dev_personal \
  --only-names
```

Do not put these values in `.eroderc.json`, `.env`, `.bashrc`, `.profile`,
repository files, command arguments, or shell history. Do not export them into
the interactive terminal. `doppler run` injects them only into its child
process.

## Create the credential-scoped Erode wrapper

Create `~/.local/bin/erode-drift`:

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly model_path='/home/aaron/code/homelab-docs/architecture/likec4'

if [[ ! -d "$model_path" ]]; then
  printf 'LikeC4 model not found: %s\n' "$model_path" >&2
  exit 1
fi

ERODE_GITHUB_TOKEN="$(gh auth token)"
export ERODE_GITHUB_TOKEN

exec doppler run --project homelab-dev --config dev_personal -- \
  erode check "$model_path" "$@"
```

Make it executable and restrict changes to the owner:

```bash
chmod 0700 ~/.local/bin/erode-drift
command -v erode-drift
```

The explicit project and config prevent a nested directory mapping from
silently changing the credential source. Only the Erode process and its child
processes receive the provider and GitHub variables.

Do not start an interactive shell or Codex through `doppler run`; that would
expose every injected variable to a much larger process tree.

## Validate model-to-repository mappings

Erode needs repository links in the architecture model so it can associate
changed code with the correct components. Validate those mappings from
`homelab-docs`:

```bash
cd /home/aaron/code/homelab-docs
erode validate architecture/likec4
```

This is different from `likec4 validate`:

- `likec4 validate` checks LikeC4 syntax, semantics, and layout drift.
- `erode validate` checks whether architecture components have repository
  links needed for drift analysis.

Resolve missing repository links before deploying Erode checks broadly.

Inspect the components and declared connections when troubleshooting mapping:

```bash
erode components architecture/likec4
erode connections architecture/likec4 \
    --repo https://github.com/Racerx323/homelab-docs
```

## Run a local drift check

From any homelab source repository, compare uncommitted changes with the
canonical model:

```bash
cd /home/aaron/code/homelab-network
erode-drift
```

Check staged changes only:

```bash
erode-drift --staged --fail-on-violations
```

Check the current branch against `main`, which is the preferred pre-push
behavior:

```bash
erode-drift --branch main --fail-on-violations
```

Erode exits with a nonzero status when `--fail-on-violations` is present and
violations are found. Without that flag, findings are advisory.

## Add a manual pre-commit hook

AI-backed analysis can be slower and more expensive than deterministic linting.
Begin with a manual-stage hook in each source repository rather than running it
on every commit:

```yaml
- repo: local
  hooks:
    - id: erode-architecture-drift
      name: Check architecture drift with Erode
      entry: erode-drift --staged --fail-on-violations
      language: system
      stages: [manual]
      pass_filenames: false
      always_run: true
```

Run it explicitly. The wrapper obtains the provider secrets from Doppler and
the GitHub token from GitHub CLI:

```bash
pre-commit run erode-architecture-drift \
    --hook-stage manual \
    --all-files
```

The user-level wrapper contains a workstation-specific absolute model path but
the committed hook contains only its command name. Other developers need their
own compatible wrapper on `PATH`; otherwise use a repository-owned portable
wrapper or rely on the GitHub Actions check.

### Promote the hook to pre-push

After evaluating local results, change the hook to compare the branch with
`main`:

```yaml
- repo: local
  hooks:
    - id: erode-architecture-drift
      name: Check architecture drift with Erode
      entry: erode-drift --branch main --fail-on-violations
      language: system
      stages: [pre-push]
      pass_filenames: false
      always_run: true
```

Install both the normal and pre-push hook types:

```bash
pre-commit install
pre-commit install --hook-type pre-push
```

Keep CI authoritative. A developer can bypass a local hook, and local
credentials may be intentionally unavailable.

The hook executes a user-owned wrapper outside the repository. Review changes
to repository hook definitions before running them because hook configuration
is executable code. Keep `~/.local/bin/erode-drift` owned by the user and mode
`0700`.

## Add GitHub Actions drift detection

Add `.github/workflows/architecture-drift.yml` to each repository whose code
is represented in the canonical model:

```yaml
---
name: Architecture Drift Check

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

concurrency:
  group: architecture-drift-${{ github.event.pull_request.number }}
  cancel-in-progress: true

permissions:
  contents: read
  pull-requests: read
  issues: write

jobs:
  erode:
    if: >-
      github.actor != 'dependabot[bot]' &&
      !github.event.pull_request.draft
    runs-on: ubuntu-latest

    steps:
      - name: Compare code changes with LikeC4
        uses: erode-app/erode@0
        with:
          model-repo: Racerx323/homelab-docs
          model-path: architecture/likec4
          model-ref: main
          model-format: likec4
          ai-provider: gemini
          github-token: ${{ secrets.GITHUB_TOKEN }}
          gemini-api-key: ${{ secrets.GEMINI_API_KEY }}
          fail-on-violations: "false"
```

The action reads the source pull-request diff and clones the canonical model;
an `actions/checkout` step is not required. It posts results using GitHub's
Issues API, so `issues: write` is required even though the comment appears on a
pull request.

Add `GEMINI_API_KEY` under each repository's **Settings > Secrets and
variables > Actions**. Use the OpenAI or Anthropic action input instead when a
different provider is selected.

GitHub Actions secrets are intentionally separate from the local
`homelab-dev/dev_personal` config during the initial rollout. Do not copy the
personal Doppler CLI token into GitHub. If CI is later connected directly to
Doppler, use a dedicated workload identity authenticated through GitHub OIDC
and grant it access only to the required CI config. See the
[Doppler Secrets Management](doppler-secrets-management.md) guide for that
boundary.

### Access a private model repository

The default `GITHUB_TOKEN` belongs to the source repository and may not clone a
different private repository. Create a fine-grained token or GitHub App token
with read-only Contents access to `Racerx323/homelab-docs`. Store it as
`MODEL_REPO_TOKEN` in the source repository and add:

```yaml
model-repo-token: ${{ secrets.MODEL_REPO_TOKEN }}
```

Do not grant model-repository write access during the initial rollout.

For organization-wide deployment, prefer a GitHub App token over a personal
access token. App tokens are short-lived, repository-scoped, and not tied to a
single user account.

### Pin the GitHub Action

The official examples use the moving major reference `erode-app/erode@0`.
After the evaluation period, replace `@0` with a reviewed full commit SHA and
retain a version comment:

```yaml
uses: erode-app/erode@FULL_COMMIT_SHA # v0.x.y
```

Dependabot can propose future SHA updates for review.

## Roll out enforcement gradually

Use three phases:

1. **Local manual evaluation**: run `erode-drift` on selected changes and
   evaluate mapping quality, false positives, provider cost, and data exposure.
2. **Advisory pull-request checks**: deploy the workflow with
   `fail-on-violations: "false"` so it comments without blocking merges.
3. **Required pull-request checks**: change the value to `"true"` and make
   `Architecture Drift Check` required in branch protection after findings are
   consistently useful.

Skip Dependabot and draft pull requests during evaluation to avoid unnecessary
provider calls. Remove those guards only if those changes must also receive
architecture analysis.

## Optional model update pull requests

Erode can propose changes to the model repository. Do not enable this while
initial findings are still being calibrated.

After review, `open-pr: "auto"` can offer on-demand model updates. Creating
model branches and pull requests requires a separate model-repository token
with:

- Contents: read and write.
- Pull requests: read and write.

Relationship removals remain informational and require manual review. A
generated model update must still pass:

```bash
likec4 format --check
likec4 validate
pre-commit run --all-files
```

Never merge an automated architecture update solely to silence a drift check.
Confirm that it describes the intended system design.

## Verify the complete setup

Verify the local installation and model:

```bash
nvm use default
erode --version
likec4 --version
doppler --version
doppler me
gh auth status
likec4 validate --json --no-layout \
    /home/aaron/code/homelab-docs/architecture/likec4
erode validate /home/aaron/code/homelab-docs/architecture/likec4
doppler configure --scope /home/aaron/code
```

Then create a harmless test branch in one source repository, make a small
architecture-relevant change, and run:

```bash
erode-drift --branch main
```

After the command exits, the provider variables should still be absent from
the parent terminal:

```bash
test -z "${ERODE_GEMINI_API_KEY:-}"
test -z "${ERODE_GITHUB_TOKEN:-}"
```

For GitHub Actions verification:

1. Open a draft pull request and confirm that the workflow is skipped.
2. Mark it ready for review and confirm the Erode job starts.
3. Confirm the job can read the central model.
4. Confirm it posts an advisory result without blocking the pull request.
5. Inspect the provider's usage records for expected cost and request volume.

## Upgrade and maintenance

Upgrade the CLI under the active default Node.js version:

```bash
nvm use default
npm update --global @erode-app/cli
erode --version
```

After an upgrade:

1. Review the Erode changelog and migration notes.
2. Update the version in `development-tool-stack.md` after installation.
3. Re-run `erode validate` against the canonical model.
4. Run a local drift check against a known change.
5. Review and update the pinned GitHub Action SHA.
6. Keep blocking enforcement disabled until changed behavior is understood.

Periodically review:

- Provider API keys, Doppler activity, and provider usage.
- GitHub token scopes and expiration.
- Model component repository links.
- False-positive and false-negative examples.
- Diff limits in `.eroderc.json`.
- Whether every modeled source repository has the workflow.

## Troubleshooting

### `erode: command not found`

Confirm the default NVM environment and global package installation:

```bash
nvm use default
npm list --global --depth=0 @erode-app/cli
command -v erode
```

If a Node.js upgrade removed the executable, reinstall it and confirm that
`@erode-app/cli` is present in `$NVM_DIR/default-packages`.

### Erode reports a missing API key

Confirm that Doppler is authenticated and the workspace resolves to the
expected project and config:

```bash
doppler me
doppler configure --scope /home/aaron/code
doppler secrets \
  --project homelab-dev \
  --config dev_personal \
  --only-names
```

The names must include `ERODE_AI_PROVIDER` and the key for that provider. Do
not print the value while troubleshooting. Confirm that the command was
launched with `erode-drift`, not `erode check` directly.

Environment variables take precedence over `.eroderc.json`. Remove any old
`ERODE_AI_PROVIDER` or provider-key exports from shell startup files so they do
not conflict with Doppler.

### Doppler authentication is unavailable

If `doppler me` fails after restarting WSL, do not export a CLI token in
`.bashrc`. Repair the WSL Secret Service or D-Bus user session, then refresh
the login:

```bash
doppler configure unset token --scope /
doppler login
doppler me
```

If the repository was moved, re-run the workspace mapping:

```bash
cd /home/aaron/code
doppler setup --project homelab-dev --config dev_personal
```

Use `doppler configure reset` only as a last resort because it removes every
local Doppler mapping.

### GitHub authentication is unavailable

The wrapper obtains `ERODE_GITHUB_TOKEN` from `gh auth token`. Check the GitHub
CLI identity without printing the token:

```bash
gh auth status
```

Reauthenticate with `gh auth login` if required. Do not duplicate the GitHub
token in Doppler to work around a GitHub CLI configuration problem.

### Erode cannot find the LikeC4 model

Verify the configured directory and both validators:

```bash
test -f /home/aaron/code/homelab-docs/architecture/likec4/likec4.config.json
likec4 validate --json --no-layout \
    /home/aaron/code/homelab-docs/architecture/likec4
erode validate /home/aaron/code/homelab-docs/architecture/likec4
```

For GitHub Actions, confirm both values:

```yaml
model-repo: Racerx323/homelab-docs
model-path: architecture/likec4
```

### A private model repository cannot be cloned

The source repository's default `GITHUB_TOKEN` is repository-scoped. Add a
separate `model-repo-token` with access to `Racerx323/homelab-docs`, or use a
GitHub App installed on both repositories.

### Erode analyzes the wrong changes

Use the appropriate comparison explicitly:

- `--staged` for files staged for the next commit.
- No comparison flag for unstaged `git diff` changes.
- `--branch main` for the complete local branch difference.
- Use the Erode GitHub Action for remote pull-request analysis.

Use `--skip-file-filtering` only while diagnosing relevance filtering. It sends
more changed content to the AI provider and can increase cost and exposure.

### Findings are noisy or incomplete

First verify component repository links with `erode validate`. Then review the
model's declared components and connections. Adjust diff limits only after
confirming the model mapping is correct.

Keep `fail-on-violations: "false"` while tuning. Erode findings are review
signals, not proof that a code change or architecture model is wrong.

## Remove Erode

Remove Erode hooks and workflows from source repositories before uninstalling
the CLI. Then uninstall the global package:

```bash
npm uninstall --global @erode-app/cli
```

Remove `@erode-app/cli` from `$NVM_DIR/default-packages`. Remove
`~/.eroderc.json` and `~/.local/bin/erode-drift` only if they are not used by
another installation. Delete Erode-specific repository secrets after
confirming no workflows depend on them.

Delete `ERODE_AI_PROVIDER` and the provider key from
`homelab-dev/dev_personal` only if no other Erode installation uses them. Do not
uninstall Doppler or remove unrelated secrets as part of removing Erode.

Uninstalling Erode does not remove or alter the LikeC4 model.

## References

- [Local Doppler secrets management](doppler-secrets-management.md)
- [Doppler CLI](https://docs.doppler.com/docs/cli)
- [Erode overview](https://likec4.dev/tooling/community/erode/)
- [Erode getting started](https://erode.dev/docs/getting-started/)
- [Erode CLI commands](https://erode.dev/docs/reference/cli-commands/)
- [Erode configuration](https://erode.dev/docs/reference/configuration/)
- [Erode GitHub Actions](https://erode.dev/docs/integrations/github-actions/)
- [Erode authentication](https://erode.dev/docs/reference/authentication/)
- [Erode source repository](https://github.com/erode-app/erode)
