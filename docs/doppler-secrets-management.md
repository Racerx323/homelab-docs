# Doppler Secrets Management

This guide configures Doppler as the secrets manager for the local development
environment under `/home/aaron/code`.

- Doppler project: `homelab-dev`
- Default personal config: `dev_personal`
- Workspace scope: `/home/aaron/code`

`dev_personal` is the user's default personal development secret space. This
guide uses it directly; no user-named config needs to be created.

## Intended design

Doppler stores secret values and injects them into one explicitly launched
process. Repositories contain variable names and documentation, never values.

```text
Doppler homelab-dev/dev_personal
             |
             | doppler run -- <command>
             v
     one trusted child process
             |
             +-- Erode receives ERODE_GEMINI_API_KEY
             +-- other tools receive only their required variables

GitHub CLI credential store
             |
             +-- gh auth token -> ERODE_GITHUB_TOKEN for one Erode process

Doppler homelab-dev, environment github
             |
             +-- ci_governance -> homelab-docs
             |                    REPOSITORY_AUDIT_TOKEN
             |
             +-- ci_architecture -> homelab-dns
                                  ERODE_GEMINI_API_KEY
```

This separation is intentional:

- Doppler manages third-party API keys and other development secrets.
- GitHub CLI continues to manage interactive local GitHub credentials.
- A separate least-privilege GitHub PAT for CI is stored in Doppler and synced
  to GitHub Actions; it is never derived from the GitHub CLI OAuth token.
- Non-secret settings remain in normal configuration files.
- Secrets are not loaded globally by `.bashrc`, `.profile`, or an interactive
  shell.
- Codex is not launched through Doppler and does not automatically inherit
  every development secret.

## Security rules

1. Run commands with `doppler run -- <command>` instead of exporting secrets
   into the current shell.
2. Do not put secret values in `.env` files, repository files, shell startup
   files, command-line arguments, or `~/.eroderc.json`.
3. Do not commit Doppler service tokens or set `DOPPLER_TOKEN` in a shell
   startup file.
4. Do not run `doppler run -- bash`, `doppler run -- zsh`, or another
   long-lived interactive shell.
5. Do not run `doppler run -- codex`. Codex and its child tools would inherit
   every injected variable.
6. Run only trusted programs and repository hooks with injected secrets. A
   child process can read its environment.
7. Do not print the environment, use shell tracing with `set -x`, or enable
   verbose HTTP logging while secrets are present.

## Configuration model

Doppler organizes secrets as projects and configs. The `homelab-dev` project
is the shared boundary for development tooling. The default `dev_personal`
space keeps personal values separate from shared defaults and other users.

The deployed project layout is:

| Environment | Configs | Purpose |
| --- | --- | --- |
| Development | `dev`, `dev_personal` | Shared development defaults and personal development credentials |
| Staging | `stg` | Staging credentials and configuration |
| Production | `prd` | Production credentials and configuration |
| `github` | `ci`, `ci_architecture`, `ci_governance` | Common CI metadata and consumer-specific GitHub Actions credentials |

The lowercase `github` environment is intentionally separate from Development,
Staging, and Production. Its `ci` root contains only Doppler metadata.
`ci_architecture` syncs only to `homelab-dns`, while `ci_governance` syncs only
to `homelab-docs`.

In the Doppler dashboard:

1. Open the `homelab-dev` project.
2. Use the existing `dev` root config as the development baseline.
3. Select the existing default personal config, `dev_personal`.
4. Put personal API credentials in `dev_personal`, not in `stg` or `prd`.

Do not use production credentials for local development. Create separate keys
with the narrowest permissions supported by each provider.

## Initial secret inventory

Start with the credentials required by Erode:

| Variable | Store | Purpose |
| --- | --- | --- |
| `ERODE_AI_PROVIDER` | Doppler | Provider selection, initially `gemini` |
| `ERODE_GEMINI_API_KEY` | Doppler | Gemini API credential used by Erode |
| `ERODE_GITHUB_TOKEN` | GitHub CLI | Supplied at runtime by `gh auth token` |
| `ERODE_MODEL_PATH` | `~/.eroderc.json` | Non-secret central LikeC4 model path |

Although `ERODE_AI_PROVIDER` is not sensitive, keeping it beside the provider
credential makes the selected provider an atomic configuration. The LikeC4
model path is ordinary configuration and should not be treated as a secret.

Use uppercase names with underscores for future secrets. Prefer names scoped
to the consuming tool, such as `TERRAFORM_CLOUD_TOKEN`, over a generic name
such as `API_KEY`.

The GitHub CI configs have separate inventories:

| Variable | Store | Purpose |
| --- | --- | --- |
| `ERODE_GEMINI_API_KEY` | Doppler `homelab-dev/ci_architecture` | Gemini credential used by the `homelab-dns` architecture-drift workflow |
| `REPOSITORY_AUDIT_TOKEN` | Doppler `homelab-dev/ci_governance` | Read-only access to private `bash-bcs-workspace` during governance audits |
| `DOPPLER_PROJECT` | Doppler integration metadata | Identifies `homelab-dev` at the GitHub sync target |
| `DOPPLER_ENVIRONMENT` | Doppler integration metadata | Identifies the `github` environment |
| `DOPPLER_CONFIG` | Doppler integration metadata | Identifies the synchronized branch config |

`REPOSITORY_AUDIT_TOKEN` is a fine-grained GitHub PAT restricted to Contents
and Metadata read access for only `bash-bcs-workspace`. It must not have write,
administration, workflow, issue, or pull-request permissions.

## Install the Doppler CLI in WSL

Install Doppler inside the Ubuntu WSL distribution where the development tools
run. Installing only the Windows CLI is insufficient because Windows and WSL
have separate executables, environments, and credential services.

Add Doppler's signed APT repository:

```bash
curl -sLf --retry 3 --tlsv1.2 --proto "=https" \
  'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' |
  sudo gpg --dearmor \
    -o /usr/share/keyrings/doppler-archive-keyring.gpg

echo 'deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main' |
  sudo tee /etc/apt/sources.list.d/doppler-cli.list

sudo apt-get update
sudo apt-get install doppler
```

Verify the installation:

```bash
doppler --version
doppler --help
```

APT will manage future upgrades:

```bash
sudo apt-get update
sudo apt-get upgrade doppler
```

## Authenticate and test persistence

Authenticate interactively:

```bash
doppler login
doppler me
```

Complete the browser authorization flow for the existing Doppler account. Do
not copy the resulting CLI token into a shell profile.

Verify that the WSL credential service persists the login:

1. Run `doppler me` successfully.
2. Close every terminal connected to the WSL distribution.
3. Open a new WSL terminal.
4. Run `doppler me` again without setting an environment variable.

Confirm that the token was not placed in the shell environment:

```bash
test -z "${DOPPLER_TOKEN:-}" && echo 'DOPPLER_TOKEN is not exported'
```

If authentication does not survive a new terminal, see
[Keyring problems](#keyring-problems). Do not work around it by putting
`DOPPLER_TOKEN` in `.bashrc`.

## Add the initial secrets

Use the Doppler dashboard to enter values. This avoids placing a value in shell
history, terminal logs, or process arguments.

In `homelab-dev` > `dev_personal`, create:

```text
ERODE_AI_PROVIDER=gemini
ERODE_GEMINI_API_KEY=<personal Gemini API key>
```

Do not add `ERODE_GITHUB_TOKEN`. GitHub CLI already stores that credential and
can provide it only when Erode launches.

Inspect names without displaying values:

```bash
doppler secrets --project homelab-dev --config dev_personal --only-names
```

Avoid commands that print secret values into the terminal or its scrollback.

## Configure the development workspace

Map the common repository parent to the project and personal config:

```bash
cd /home/aaron/code
doppler setup --project homelab-dev --config dev_personal
```

Check the mapping:

```bash
doppler configure --scope "$(pwd)"
```

Doppler records directory mappings in `~/.doppler/.doppler.yaml`. The mapping
selects a project and config; it does not inject secrets into the shell and
does not belong in Git.

Doppler uses the nearest directory mapping. A repository can override the
parent mapping later:

```bash
cd /home/aaron/code/example-repo
doppler setup --project another-project --config dev_personal
```

Use explicit flags when a command can run from different directories:

```bash
doppler run \
  --project homelab-dev \
  --config dev_personal \
  -- command arguments
```

Command flags take precedence over a directory mapping.

## Run tools with secrets

The general pattern is:

```bash
doppler run -- command arguments
```

Doppler supplies the selected variables only to the child process. They
disappear when the process exits.

For a one-off Erode command, combine the GitHub CLI credential with Doppler:

```bash
ERODE_GITHUB_TOKEN="$(gh auth token)" \
  doppler run --project homelab-dev --config dev_personal -- \
  erode check /home/aaron/code/homelab-docs/architecture/likec4
```

This avoids duplicating the GitHub token in Doppler. Use a small trusted
wrapper for regular work.

## Create an Erode wrapper

Create `~/.local/bin/erode-drift` with this content:

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

Restrict modifications to the owner and confirm the wrapper is on `PATH`:

```bash
chmod 0700 ~/.local/bin/erode-drift
command -v erode-drift
```

The wrapper uses an explicit project, config, and model path so a nested
directory mapping cannot silently switch credentials.

Examples:

```bash
erode-drift --staged
erode-drift --branch main --fail-on-violations
```

## Pre-commit integration

Keep AI-assisted architecture checking manual at first. Unlike deterministic
LikeC4 validation, Erode makes a network request, incurs provider usage, and
requires credentials.

Add this local hook to a repository's `.pre-commit-config.yaml` only after the
wrapper works interactively:

```yaml
repos:
  - repo: local
    hooks:
      - id: erode-architecture-drift
        name: Check architecture drift with Erode
        entry: erode-drift --staged
        language: system
        stages: [manual]
        pass_filenames: false
        always_run: true
```

Run it explicitly:

```bash
pre-commit run --hook-stage manual erode-architecture-drift
```

After its output and cost are predictable, a repository may promote the check
to pre-push:

```yaml
entry: erode-drift --branch main --fail-on-violations
stages: [pre-push]
```

Review repository hook changes before running them. A hook is executable code
and can read variables available to its process tree.

## Using Doppler across repositories

The `/home/aaron/code` mapping provides a common default. Repositories should
document required variable names, not values. They may provide safe examples
with empty values.

For commands that must always use `homelab-dev/dev_personal`, prefer explicit
flags or a reviewed wrapper. For ordinary commands within the development
tree, the directory mapping is sufficient:

```bash
cd /home/aaron/code/some-repo
doppler run -- npm test
```

Do not wrap commands that do not need secrets. Smaller process scopes reduce
accidental exposure.

## Codex and AI tool boundary

Do not start Codex with `doppler run`. Doing so would expose the injected
secrets to Codex and every command it launches during that session.

Doppler offers an MCP server, but it should not be enabled for the initial
configuration. A secret-management MCP gives an AI agent direct secret read or
write capabilities, which is unnecessary for running Erode. If it is ever
needed, create a dedicated Doppler identity with narrowly scoped permissions;
do not expose the personal CLI identity.

The safer pattern is to let Codex edit normally and let a small reviewed
wrapper invoke only the tool that requires a credential.

## GitHub Actions and automation

Local CLI authentication is for interactive development only. Never copy the
local Doppler CLI token into a repository or reuse it as a CI credential.

GitHub Actions use two deployed Doppler GitHub integration syncs:

1. `ci_governance` syncs `REPOSITORY_AUDIT_TOKEN` to the `homelab-docs`
   repository's Actions secrets.
2. `ci_architecture` syncs `ERODE_GEMINI_API_KEY` to the `homelab-dns`
   repository's Actions secrets.
3. The governance workflow uses `secrets.REPOSITORY_AUDIT_TOKEN` as `GH_TOKEN` and falls
   back to `github.token` when the secret is unavailable.
4. The architecture workflow passes `secrets.ERODE_GEMINI_API_KEY` to Erode's
   `gemini-api-key` action input.
5. The audit token grants read access only to the private repository that the default
   workflow token cannot clone.

The integration pushes an encrypted execution copy to GitHub; the workflow does
not retrieve the PAT from Doppler at runtime. Do not add a Doppler service token
or run the governance job through `doppler run`. Continue to restrict workflow
permissions, pin third-party actions to full commit SHAs, and avoid exposing
secrets to workflows from untrusted forks.

Local `dev_personal`, the `github` environment's consumer-specific configs,
staging, and production must remain separate credential boundaries.

Inspect the CI inventory without displaying values:

```bash
doppler secrets \
  --project homelab-dev \
  --config ci_governance \
  --only-names

gh secret list --repo Racerx323/homelab-docs

doppler secrets \
  --project homelab-dev \
  --config ci_architecture \
  --only-names

gh secret list --repo Racerx323/homelab-dns
```

See [GitHub Actions Governance](github-actions-governance.md) for PAT creation,
workflow verification, rotation, revocation, and incident response.

## Verification checklist

```bash
# CLI and login.
doppler --version
doppler me
test -z "${DOPPLER_TOKEN:-}"

# Expected workspace mapping.
cd /home/aaron/code
doppler configure --scope "$(pwd)"

# Expected names, without values.
doppler secrets \
  --project homelab-dev \
  --config dev_personal \
  --only-names

# GitHub CLI remains the GitHub credential source.
gh auth status

# CI secret names and synchronized GitHub target, without values.
doppler secrets --project homelab-dev --config ci_governance --only-names
gh secret list --repo Racerx323/homelab-docs
doppler secrets --project homelab-dev --config ci_architecture --only-names
gh secret list --repo Racerx323/homelab-dns

# Trusted Erode wrapper.
command -v erode-drift
erode-drift --staged
```

Also verify that secret values are absent from:

- `~/.bashrc`
- `~/.profile`
- `~/.eroderc.json`
- repository `.env` files
- repository documentation and configuration

## Rotation procedure

1. Create a replacement key at the upstream provider with minimal permissions.
2. Update its value in `homelab-dev/dev_personal` through the dashboard.
3. Run the smallest relevant verification command with `doppler run`.
4. Revoke the old key at the upstream provider.
5. Review provider and Doppler audit logs for unexpected use.

Prefer a short overlap where both keys work, then revoke the old key after
verification. Updating Doppler does not revoke the original provider key.

For `REPOSITORY_AUDIT_TOKEN`, create the replacement in GitHub first, update
the value in project `homelab-dev`, environment `github`, config
`ci_governance`, wait for
the GitHub Actions sync, run the governance audit, and then revoke the old PAT.
Confirm the audit log reports zero policy violations. Emergency exposure
requires immediate revocation and replacement rather than an overlap window.

If a secret may have entered Git history or terminal logs, rotate it. Removing
the text alone does not make the old credential safe.

## Troubleshooting

### Wrong project or config

Inspect the exact directory scope:

```bash
doppler configure --scope "$(pwd)"
```

Re-run setup at the intended directory:

```bash
cd /home/aaron/code
doppler setup --project homelab-dev --config dev_personal
```

A mapping on a nearer child directory overrides its parent.

### Keyring problems

If `doppler me` reports that the token is missing after WSL restarts, confirm
that the distribution has a functioning Secret Service and D-Bus user session.
Do not fall back to a plaintext shell export.

Remove only the stale root token configuration and authenticate again:

```bash
doppler configure unset token --scope /
doppler login
doppler me
```

Use `doppler configure reset` only as a last resort because it removes all
local Doppler configuration, including directory mappings.

### Command not found

If `doppler` is missing, verify the package:

```bash
dpkg -s doppler
command -v doppler
```

If `erode-drift` is missing, verify that `~/.local/bin` is on `PATH` and that
the wrapper is executable.

### Secret unavailable to a command

Confirm the variable name with `--only-names`, verify the selected project and
config, and ensure the command is a child of `doppler run`. Do not diagnose by
printing the secret; use the tool's authentication or connectivity check.

### Offline behavior

Doppler may use an encrypted local fallback when the service is unavailable,
depending on CLI configuration and prior successful fetches. Do not rely on
that cache for first-time setup, rotation verification, or disaster recovery.
Test critical offline workflows explicitly before depending on them.

## Remove or reset the local configuration

Remove the workspace mapping without deleting cloud secrets:

```bash
doppler configure unset project config --scope /home/aaron/code
```

Log the CLI out of the current WSL environment:

```bash
doppler logout
```

Uninstall the package if Doppler is no longer used:

```bash
sudo apt-get remove doppler
```

Removing the CLI or mapping does not delete `homelab-dev` or revoke upstream
provider credentials. Revoke or delete those separately when appropriate.

## Recommended rollout

1. Enter the two initial Erode variables in the existing `dev_personal` config.
2. Install the CLI and verify login persistence across a WSL restart.
3. Map `/home/aaron/code` to `homelab-dev/dev_personal`.
4. Create and test the `erode-drift` wrapper.
5. Use Erode manually until results and provider cost are understood.
6. Add the manual pre-commit hook to selected repositories.
7. Promote it to pre-push only when reliable enough to block pushes.
8. Keep CI credentials in the separate `github` environment and `ci` config;
   synchronize them through the reviewed GitHub Actions integration.

## References

- [Doppler CLI](https://docs.doppler.com/docs/cli)
- [Install the Doppler CLI](https://docs.doppler.com/docs/install-cli)
- [CLI project and config setup](https://docs.doppler.com/docs/secrets-setup-guide)
- [Environment-based configuration](https://docs.doppler.com/docs/environment-based-configuration)
- [Root and branch configs](https://docs.doppler.com/docs/root-configs)
- [CLI troubleshooting](https://docs.doppler.com/docs/cli-troubleshooting)
- [Doppler MCP server](https://docs.doppler.com/docs/mcp)
- [Doppler GitHub Actions integration](https://docs.doppler.com/docs/github-actions)
- [GitHub fine-grained personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [GitHub Actions secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)
