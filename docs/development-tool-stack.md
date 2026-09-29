# Development Tool Stack

This document records the shared development and validation tools used across
the homelab repositories. The primary workstation baseline is Ubuntu 24.04
under WSL2, with VS Code on the Windows host and PowerShell 7 installed in both
Ubuntu and Windows. The platform, Ubuntu CLI tools, VS Code, active extensions,
Codex plugin state, and browser runtimes were last verified on September 14,
2026. The Codex skills maintenance, WSL Codex/LikeC4/Playwright CLI versions, and
matching Chromium runtime were verified on September 29, 2026. Other rows retain
their September 14 observation date; Windows-local skill discovery was not refreshed.

The version table is an inventory, not a lock file. Repository configuration,
such as `.pre-commit-config.yaml`, remains the source of truth for required
checks and arguments.

## Workstation and editor

| Component | Version | Scope |
| --- | --- | --- |
| Windows | 10.0.26340.9482 | VS Code host and WSL platform |
| WSL | 2.9.4.0 | Linux development environment |
| WSL kernel | 6.18.35.2-microsoft-standard-WSL2 | Microsoft WSL2 kernel |
| Ubuntu | 24.04.5 LTS | Primary CLI environment |
| VS Code | 1.137.0, commit `645f29cc3176500b4b5762ba887cf2a7f0ffdf2c` | Windows UI and WSL remote extension host |

VS Code maintains separate Windows-local and WSL extension hosts. The following
extensions are installed at the same version in both hosts:

| Extension | Version | Extension | Version |
| --- | --- | --- | --- |
| `aaron-bond.better-comments` | 3.0.2 | `antonreshetov.masscode-assistant` | 2.0.1 |
| `christian-kohler.path-intellisense` | 2.10.0 | `coderabbit.coderabbit-vscode` | 0.21.6 |
| `davidanson.vscode-markdownlint` | 0.62.1 | `eamodio.gitlens` | 19.1.0 |
| `ecmel.vscode-html-css` | 2.0.14 | `esbenp.prettier-vscode` | 12.4.0 |
| `formulahendry.code-runner` | 0.12.2 | `github.remotehub` | 0.64.0 |
| `github.vscode-github-actions` | 0.32.3 | `hashicorp.terraform` | 2.40.0 |
| `juniormayhe.copy-as-wsl` | 0.0.3 | `justinxai.wsl-reveal-explorer-pro` | 1.1.6 |
| `likec4.likec4-vscode` | 1.59.3 | `mdickin.markdown-shortcuts` | 0.12.0 |
| `mermaidchart.vscode-mermaid-chart` | 2.7.8 | `ms-azuretools.vscode-containers` | 2.5.0 |
| `ms-python.debugpy` | 2026.6.0 | `ms-python.isort` | 2026.6.0 |
| `ms-python.python` | 2026.4.0 | `ms-python.vscode-pylance` | 2026.3.1 |
| `ms-python.vscode-python-envs` | 1.36.0 | `ms-vscode.cmake-tools` | 1.24.42 |
| `ms-vscode.cpp-devtools` | 0.6.18 | `ms-vscode.cpptools` | 1.34.4 |
| `ms-vscode.cpptools-extension-pack` | 1.5.1 | `ms-vscode.cpptools-themes` | 2.0.0 |
| `ms-vscode.makefile-tools` | 0.12.17 | `ms-vscode.notepadplusplus-keybindings` | 1.0.7 |
| `ms-vscode.powershell` | 2025.4.0 | `ms-vscode.remote-repositories` | 0.42.0 |
| `ms-vscode.vscode-chat-customizations-evaluations` | 1.0.8 | `ms-vscode.vscode-serial-monitor` | 0.13.1 |
| `openai.chatgpt` | 26.908.40401 | `redhat.vscode-yaml` | 1.24.0 |
| `ronaldosena.arduino-snippets` | 1.0.2 | `saoudrizwan.claude-dev` | 4.1.17 |
| `sayedabdulkarim.origami-vscode` | 0.0.2 | `streetsidesoftware.code-spell-checker` | 4.9.3 |
| `usernamehw.errorlens` | 3.28.0 | `vexp.vexp-vscode` | 3.1.3 |
| `vscode-icons-team.vscode-icons` | 12.19.0 | `yzane.markdown-pdf` | 2.2.0 |
| `yzhang.markdown-all-in-one` | 3.6.3 | — | — |

The Windows host additionally owns the extensions that establish and manage
remote environments:

| Extension | Version | Extension | Version |
| --- | --- | --- | --- |
| `jkudo.wsl-manager` | 0.25.3 | `ms-vscode-remote.remote-ssh` | 0.128.0 |
| `ms-vscode-remote.remote-ssh-edit` | 0.87.0 | `ms-vscode-remote.remote-wsl` | 0.104.3 |
| `ms-vscode-remote.vscode-remote-extensionpack` | 0.26.0 | `ms-vscode.remote-explorer` | 0.5.0 |
| `ms-vscode.remote-server` | 1.5.3 | `tyriar.windows-terminal` | 0.7.0 |

Run `code --list-extensions --show-versions` in a WSL terminal to inventory the
WSL extension host. Run the Windows launcher from PowerShell to inventory the
Windows-local host. Extension directories can retain older inactive versions,
so directory listings are not an authoritative active-extension inventory.

```powershell
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" `
    --list-extensions --show-versions
```

## Core workflow

| Tool | Version | Purpose |
| --- | --- | --- |
| Git | 2.43.0 | Source control and change inspection |
| GitHub CLI (`gh`) | 2.45.0 | GitHub repository, issue, and pull request workflows |
| pre-commit | 3.6.2 | Runs the common validation suite before commits |

Install the hooks after cloning a repository:

```bash
pre-commit install
pre-commit run --all-files
```

Hooks configured with the `manual` stage run only when explicitly requested.
Invoke networked or AI-backed hooks by ID so the command does not unexpectedly
run every manual check in the repository:

```bash
pre-commit run trivy-config --hook-stage manual --all-files
pre-commit run erode-architecture-drift --hook-stage manual
```

> [!WARNING]
> The Erode hook sends selected code changes and LikeC4 model context to the
> configured AI provider and can consume API quota.

Review the staged change scope before running Erode. Use
`pre-commit run --hook-stage manual --all-files` only when every configured
manual hook is intentionally in scope.

## Shell development and testing

| Tool | Version | Purpose |
| --- | --- | --- |
| ShellCheck | 0.9.0 | Static analysis for shell scripts |
| shfmt | 3.8.0 | Checks consistent shell formatting |
| Bats | 1.10.0 | Automated testing for Bash scripts |

The shared shfmt policy uses four-space indentation and case indentation. The
`bash-bcs-workspace` repository intentionally uses two-space indentation.

Run the tools directly when troubleshooting a hook failure:

```bash
shellcheck path/to/script.sh
shfmt -d -i 4 -ci path/to/script.sh
bats test/
```

## PowerShell development and testing

| Tool | Version or constraint | Purpose |
| --- | --- | --- |
| PowerShell | 7.6.6 | Runs cross-platform PowerShell and validates Windows automation |
| Windows PowerShell | 5.1.26100.9482 | Provides the bundled Windows compatibility shell |
| Pester (Windows local) | 6.0.0; 5.9.0 also installed | Tests PowerShell, registry launchers, and task automation |
| Pester (CI) | 5.5.0 through 5.99.99 | Runs the authoritative Pester 5 regression suite |
| GitHub Actions | `windows-latest` | Runs the Pester regression suite on pull requests and `main` |

Install PowerShell in Ubuntu 24.04 from the Microsoft package repository:

```bash
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common
source /etc/os-release
wget -q "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
pwsh --version
```

This is Microsoft's preferred installation channel and allows PowerShell to be
updated through APT. Use `pwsh` to start it in Linux. Windows-specific registry
and Task Scheduler behavior still requires PowerShell 7 on Windows. Run those
tests from Windows, using the repository through its WSL network path:

```powershell
Set-Location \\wsl.localhost\Ubuntu\home\aaron\code\homelab-scripts
Invoke-Pester -Path @(
    '.\windows\system-repair\tests\SystemRepairMenu.Tests.ps1'
    '.\windows\wsl-code-directory-sync\tests\GithubRepoSyncNotify.Tests.ps1'
) -CI
```

Windows PowerShell 5.1 includes Pester 3.4.0, but it cannot update that bundled
copy in place. Install a current stable Pester side by side from PowerShell 7:

```powershell
Install-Module -Name Pester -Scope CurrentUser -Force -SkipPublisherCheck
```

The `homelab-scripts` workflow deliberately constrains CI to Pester 5 until the
suite is reviewed for Pester 6. The tests retain compatibility with the bundled
Pester 3.4.0 for basic local fallback coverage, but Pester 5 CI is authoritative.
Pester is not installed in the Ubuntu WSL PowerShell environment; run these
Windows-specific tests from PowerShell 7 on the Windows host.

## Documentation and structured data

| Tool | Version | Purpose |
| --- | --- | --- |
| markdownlint-cli2 | 0.23.2 | Markdown style and consistency checks |
| markdown-link-check | 3.15.0 | Checks links in Markdown documents |
| yamllint | 1.33.0 | YAML syntax and style validation |
| actionlint | 1.7.12 | Static analysis for GitHub Actions workflows |
| check-jsonschema | 0.37.4 | Schema validation for Compose and GitHub issue YAML |
| jq | 1.7.1 | JSON queries and syntax validation |
| Mike Farah `yq` | 4.53.3 | Native YAML queries and edits using `yq eval` syntax |
| Mermaid CLI (`mmdc`) | 12.0.0 installed; 11.16.0 repository pin | Validates Mermaid files and exports SVG, PNG, or PDF |

Common direct checks include:

```bash
markdownlint-cli2 '**/*.md'
markdown-link-check README.md
yamllint --strict .
actionlint
check-jsonschema --builtin-schema vendor.compose-spec compose.yaml
jq empty path/to/file.json
yq eval '.services' compose.yaml
```

The active `yq` implementation must be Mike Farah v4. Confirm it with:

```bash
yq --version
```

The Mermaid CLI version is pinned in `.mermaid-version`. See
[Mermaid Installation and Configuration](mermaid-installation-and-configuration.md)
for the authoring, validation, export, editor, pre-commit, and CI workflow.
The current global CLI is one release ahead of this repository's pin. Mermaid
validation is expected to fail closed until the global package is returned to
11.16.0 or a separately reviewed repository change advances the pin.

actionlint complements yamllint with GitHub Actions-aware semantic, expression,
action-input, reusable-workflow, and inline-script checks. See
[actionlint Installation and Configuration](actionlint-installation-and-configuration.md)
for installation, pre-commit integration, and upgrades.

Shared workflow presence, immutable action references, permissions, and
pull-request coverage are governed by
[GitHub Actions Governance](github-actions-governance.md).

## Security and container validation

| Tool | Version | Purpose |
| --- | --- | --- |
| Gitleaks | 8.16.0 | Detects secrets in staged changes |
| Trivy | 0.74.0 | Scans Terraform configuration and container images |
| Podman | 4.9.3 | Builds, runs, and inspects rootless containers |
| Skopeo | 1.13.3 | Inspects and copies container images without running them |

Gitleaks runs on every pre-commit invocation. Trivy usage is repository
specific:

- `homelab-terraform` scans Terraform configuration for high and critical
  findings.
- `homelab-notification` provides manual scans for the Apprise API and Mailrise
  container images.

Useful standalone commands are:

```bash
gitleaks protect --staged --redact --no-banner
trivy config --exit-code 1 --severity HIGH,CRITICAL .
trivy image --ignore-unfixed --severity HIGH,CRITICAL IMAGE
podman compose config
skopeo inspect docker://docker.io/library/alpine:latest
```

## Terraform

| Tool | Version | Purpose |
| --- | --- | --- |
| Terraform | 1.16.2 | Formats, validates, plans, and applies infrastructure |
| TFLint | 0.63.1 | Finds Terraform errors and provider-specific problems |
| terraform-docs | 0.24.0 | Generates module input and output documentation |
| Trivy | 0.74.0 | Scans infrastructure-as-code configuration |

Use this local validation sequence from `homelab-terraform`:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
tflint --recursive
terraform-docs markdown table .
trivy config --exit-code 1 --severity HIGH,CRITICAL .
pre-commit run --all-files
```

Do not run `terraform apply` as part of routine validation. Review a saved plan
before making infrastructure changes.

## Configuration management and orchestration

| Tool | Version | Purpose |
| --- | --- | --- |
| Ansible Core | 2.21.3 | Validates and runs reviewed host-configuration and orchestration playbooks |

Install the minimal controller with pipx. Repository playbooks use only
`ansible.builtin` modules, so Ansible Core supplies the required commands:

```bash
pipx install ansible-core==2.21.3
ansible-playbook --version
```

Run repository-specific syntax checks from the owning repository. For the
Nautobot host-qualification playbook:

```bash
cd /home/aaron/code/homelab-server-configs
ansible-playbook --syntax-check \
    -i inventory/prod/hosts.yaml \
    Nautobot/ansible/playbooks/qualify-host.yaml
```

The syntax check parses the inventory and playbook without contacting a managed
host. A check-mode or live playbook invocation can still execute read-only
commands and requires the owning repository's reviewed command and
authorization boundary.

## AI-assisted development

| Tool | Version or model | Purpose |
| --- | --- | --- |
| Codex CLI | 0.159.1 (WSL, September 29) | Repository-aware implementation and troubleshooting |
| GitHub Copilot CLI | 1.0.83 | Command-line development assistance |
| CodeRabbit CLI | 0.7.6 | AI review of local changes and committed ranges |
| BCS | 2.0.1 | AI-assisted Bash code review |
| Ollama | 0.32.14; `qwen3.5:9b` | Local inference backend and model used by BCS |
| vexp CLI | 3.1.3 | Local multi-repository context, impact analysis, and completion checks |
| LikeC4 CLI | 1.59.4 (WSL, September 29; running MCP version not refreshed) | Architecture-as-code modeling, validation, previews, and model queries |
| Erode CLI | 0.10.3 | AI-assisted comparison of code changes with the LikeC4 model |
| Playwright CLI | 0.1.22 (WSL, September 29) | Browser inspection and automation for agent-assisted workflows |
| Playwright Chromium | Runtime 1247; Chrome for Testing 155.0.8059.12 (WSL, September 29) | Version-matched browser used by Playwright CLI |

LikeC4 is installed globally under the active NVM Node.js version. See
[LikeC4 Installation and Configuration](likec4-installation-and-configuration.md)
for the workstation, Codex, VS Code, repository, and CI setup.

### vexp indexing and IDE integration

The global Ubuntu CLI and the VS Code extension use the same workspace index
when both target `/home/aaron/code`. The primary index and workspace definition
live under `/home/aaron/code/.vexp`. Each registered child repository has a
local `.vexp/parent_workspace.json` pointer to that workspace. The files under
`.vexp` are workstation state and do not belong in Git.

A running daemon indexes saved files as they change. Workspace Git hooks
finalize the index before a commit, synchronize it after a branch checkout,
and recover it after a merge. Normal editing through VS Code or the Ubuntu CLI
does not require a separate `vexp index` command while the shared daemon is
running and the index reports no stale files.

Check the shared workspace from its root:

```bash
cd /home/aaron/code
vexp --version
vexp daemon-cmd status
vexp index --status
vexp hooks check
vexp doctor
```

The daemon status lists the primary workspace and each indexed repository.
`vexp index --status` reports the primary workspace-root counts, so its file
count does not equal the sum of all secondary repositories. Use the daemon or
doctor output for aggregate and per-repository counts.

Start a stopped daemon with:

```bash
cd /home/aaron/code
vexp daemon-cmd start
```

Run a full refresh after a vexp upgrade, a workspace membership change, a
repaired parent-workspace link, or a nonzero stale count:

```bash
cd /home/aaron/code
vexp daemon-cmd restart
vexp index /home/aaron/code
vexp index --status
vexp doctor
```

The current vexp release writes its version, timestamp, and primary-root counts
to `/home/aaron/code/.vexp/manifest.json`. Do not delete `.vexp` to repair a
stale manifest. Restart the daemon and use the supported index command first.
A successful repair requires a reachable daemon socket, `Stale: 0`, current
manifest metadata, and a clean `vexp doctor` result.

Playwright CLI and its Chromium runtime are part of the development-tool
baseline for browser inspection and automation. The npm package and browser
runtime are separate installations. A Playwright CLI update can require a new
runtime revision even when an older Chromium download remains in the cache.
Install or update both, then prove a browser can launch:

```bash
npm install -g @playwright/cli@latest
playwright-cli install-browser chromium
playwright-cli open https://example.com
playwright-cli --raw eval 'document.title'
playwright-cli close
```

The runtime is stored beneath `~/.cache/ms-playwright`. The matching Chromium
and headless-shell revision was verified on September 29; disk usage was not
remeasured. Repeat
`playwright-cli install-browser chromium` after every Playwright CLI upgrade so
the cached browser revision matches the CLI. Generating Mermaid source remains
browser-free, but browser-backed validation and image or PDF rendering require
their configured runtime.

Erode is installed for manual, advisory use. The current model validation has
19 repository-linked components and 50 unlinked components, so Erode should not
be promoted to a blocking check until the relevant mappings are complete.

BCS is maintained in `bash-bcs-workspace`. Its configured model name must match
an installed Ollama model:

```bash
ollama list
bcs check path/to/script.sh
```

CodeRabbit is available as both `coderabbit` and `cr`. It requires
authentication and sends the selected change data to the CodeRabbit service,
so review the scope before running it:

```bash
coderabbit doctor
coderabbit review --plain
```

The CLI is sufficient for terminal and Codex review workflows; a VS Code
extension is optional.

Every managed repository contains a root `.coderabbit.yaml` that inherits the
CodeRabbit organization settings and applies the shared draft-first policy:

- automatic reviews remain enabled for ready pull requests;
- draft pull requests are not reviewed;
- skipped-draft status comments are suppressed.

This avoids consuming review capacity during active draft work while keeping
the organization configuration as the source for all other review behavior.
Comment `@coderabbitai review` on a pull request to request an incremental
review manually.

## Codex extensions

Codex loads reusable workflows from skills and plugins. A skill supplies
instructions and supporting resources. An MCP server supplies tools, live
data, or controlled actions. Plugins can package either or both. The tables
below inventory active capabilities, not every package retained in a local
download cache.

Do not copy `~/.codex/config.toml`, MCP environment blocks, HTTP headers,
connector identifiers, authentication state, or generated session files into
this repository. Record capability names and purposes here; keep credentials
in their owning credential store.

### Installed Ubuntu CLI plugins

| Plugin | Version | Included capability |
| --- | --- | --- |
| Context7 | 1.0.1 | Current library and framework documentation through a skill and MCP server |

`codex plugin list --json` is the authority for the Ubuntu CLI plugin inventory.
Packages retained beneath the Codex plugin cache are not installed plugins.
CodeRabbit remains available through its standalone CLI and VS Code extension;
GitHub workflows remain available through `gh` and the GitHub VS Code
extensions.

### Skills

Codex may invoke a skill when a request matches its description. Invoke one
explicitly with `$skill-name` when the workflow must be selected. The detailed
trigger rules and procedures remain in each skill's `SKILL.md`.

| Scope | Skills | Purpose |
| --- | --- | --- |
| Codex system, discovered by CLI | `imagegen`, `openai-docs`, `review-agent`, `skill-creator`, `skill-installer` | Image generation, authoritative OpenAI documentation, review support, and skill creation or installation |
| Personal | `clear-writing`, `likec4-dsl`, `playwright-cli` | Prose drafting, editing and detection; LikeC4 DSL guidance; browser automation |
| Context7 plugin | `context7:context7-mcp` | Documentation lookup workflow bundled with the Context7 MCP server |

On September 29, 2026, forced CLI discovery returned nine enabled skills with
no load errors. Supported `codex update` moved the standalone CLI from 0.159.0
to 0.159.1. It did not resolve the `plugin-creator` discrepancy. In one invocation,
CLI discovery removed that skill's eleven files and changed the managed cache
marker while leaving other system-file hashes unchanged. The session host later
materialized its copy again. Its unchanged entrypoint was discoverable in a
throwaway repo, so a frontmatter failure is not supported by the reproducer.

Keep system maintenance through Codex. Do not patch `.system`, its marker, or
add a personal duplicate. The local skills repository contains the submitted
upstream report, evidence and a reproduction procedure in
`docs/plugin-creator-cache-refresh.md`; the related reproduction is posted on
[Codex issue #19265](https://github.com/openai/codex/issues/19265#issuecomment-5899517948).
A shared root cause and an upstream fix remain unconfirmed.

The personal `context7-mcp` entrypoint was byte-for-byte identical to the plugin
entrypoint. After verifying plugin discovery and a successful documentation lookup,
the personal duplicate was backed up and retired. Use `context7:context7-mcp`.
The Context7 plugin and MCP configuration were not changed.

`clear-writing` replaces `stop-slop` with one curated skill derived from Stop Slop
and No AI Slop. It supports drafting, minimal editing, and detection without
rewriting or claiming AI authorship. It preserves facts, uncertainty, technical
literals, operational boundaries, and the writer's voice. Meaningful adverbs,
passive voice, and software subjects remain valid. No separate `no-ai-slop` or
Taste Skill installation was added.

Source, upstream commit hashes, MIT notices, evaluation cases, and maintenance
instructions live in
[personal-codex-skills](https://github.com/Racerx323/personal-codex-skills).
The local source checkout is `$HOME/code/personal-codex-skills`; install only its
reviewed `skills/<name>/` bundle into `$HOME/.agents/skills/<name>/`.
The installed bundle is a verified copy and does not automatically follow source edits.

Both retired personal skills and their hash manifest are retained outside discovery
under `$HOME/.local/state/personal-codex-skills/backups/20260929T202415Z/`.
The skills repository documents restoration and records installed file hashes.
The September 29 maintenance adapts LikeC4 and Playwright in the personal skills
repository, retains upstream license notices, and moves lengthy catalogs into
references. LikeC4 guidance now checks file-filter counts, avoids obsolete
version pinning, and corrects parser-tested deployment, identifier, predicate
and dynamic-view rules. Playwright guidance limits cleanup to owned sessions,
protects state artifacts and preserves requested test assertions. The detailed
installation record, audit coverage and test results belong in that repository's
`docs/maintenance-result-2026-09-29.md` and `evals/maintenance-2026-09-29/`.

Personal standalone skills belong in `$HOME/.agents/skills`. Codex-managed system
skills and compatibility data remain under `$HOME/.codex/skills`.

#### Per-client capability inventory

Maintain this matrix here as the shared operational inventory. Keep file hashes,
source provenance, evaluation transcripts and rollback records in the skills
repository/private state archive, not duplicated throughout this document.
Observation date: September 29, 2026. An unavailable client is marked unverified,
not assumed to match another client.

| Capability | WSL CLI 0.159.1 | Active Codex conversation | Windows-local client | Owner / action |
| --- | --- | --- | --- | --- |
| Clear Writing, LikeC4, Playwright skills | Discovered, enabled | Supplied | Unverified | Personal source bundles; refresh after deployment |
| Context7 1.0.1 | Installed, enabled; skill discovered | Skill and MCP supplied | Unverified | Plugin; keep one personal/plugin copy |
| imagegen, openai-docs, skill-creator, skill-installer | Discovered, enabled | Supplied | Unverified | Codex-managed |
| review-agent | Discovered, enabled | Not in supplied catalog | Unverified | Codex-managed; client availability differs |
| plugin-creator | Omitted; removed during cache refresh | Supplied | Unverified | Codex-managed; reproducible cache conflict |
| CodeRabbit 1.1.4 skill package | No persistent CLI plugin installation established | Supplied | Unverified | Session/plugin owner; standalone CLI is a separate tool |
| Codex Security 0.1.31 skill package | No persistent CLI plugin installation established | Supplied | Unverified | Session/plugin owner; source audit has host/native limitations |
| plugin-management 0.1.0 | No persistent CLI plugin installation established | Supplied | Unverified | Session/plugin owner |
| work-pets 0.1.6 | No persistent CLI plugin installation established | Supplied | Unverified | Session/plugin owner; uploaded assets need task authorization |

The WSL VS Code extension reports `openai.chatgpt@26.917.62051`; an extension
version is not proof of its complete skill catalog. Session-supplied capabilities
and cached packages do not imply persistent CLI plugin installation. The earlier
remote marketplace lookup returned HTTP 503; no complete remote catalog is claimed.
Do not install session-only plugins merely to make the tables match. Decide which
capabilities are needed in each client, use supported provisioning, then verify
that client's own discovery in a fresh conversation. Windows-local observations
remain an explicit inventory gap.

#### Runtime and audit notes

Playwright CLI 0.1.22 uses playwright/core 1.64.0-alpha-1790635538000. Its required
Chromium 1247 was missing; the user-approved install supplied Chrome for Testing
155.0.8059.12 and matching headless shell. The installer also garbage-collected
unused Chromium 1237; this was not a CLI package update. Loopback fixtures checked
interaction, synthetic state save/load, named-session cleanup and external-browser
detach/reconnection. These checks do not exercise production sites or accounts.

The expanded risk-based static audit includes skill instructions, helpers and
available bundled plugin implementation, including decoded JavaScript. It found
two LOW local integrity issues involving pre-created shared temporary directories
(documentation cache and temporary security artifacts). The canonical report
records exact evidence. Native host/service implementation and inherited MCP
write authority remain unverified; a local read-only profile does not prove all
MCP tools are read-only. System/plugin source was not patched. Local mitigations now use a checked private
manual-cache wrapper at `$HOME/.local/share/codex-hardening/fetch-manual-private.py`
and personal instructions requiring persistent inline supplemental artifacts.
Temporary saves and `sourcePath` imports remain prohibited until the actual
plugin process has a verified private temporary parent. Eight wrapper checks and
an official manual fetch passed; this does not reproduce a multiuser attack or
fix the upstream implementations. See the skills repository maintenance guidance
for boundaries and follow-up.

### MCP servers

| Server | Provisioning | Purpose |
| --- | --- | --- |
| vexp | Global Codex configuration; vexp CLI 3.1.3 | Shared local multi-repository context, impact analysis, and completion checks |
| LikeC4 | Global Codex configuration; LikeC4 1.59.3 | Architecture model search, graph queries, semantic layout, and view or deployment inspection |
| GitKraken | Global Codex configuration through GitLens | Git operations plus GitHub issue, pull request, workspace, and review workflows |
| Playwright | Global Codex configuration; on-demand `@playwright/mcp` package | Browser inspection and automation |
| Context7 | Context7 plugin and global remote-server registration | Current, version-specific library, framework, SDK, API, CLI, and cloud-service documentation |

Context7 exposes `resolve-library-id` and `query-docs`. Resolve a library name
before querying its documentation unless the request already supplies an exact
Context7 library ID. Both tools are read-only but send the documentation query
to the Context7 service, so never include credentials, private source, personal
data, or other confidential content in a query.

vexp runs locally and indexes repositories under the development workspace.
Playwright can interact with live web pages and GitKraken can mutate Git and
GitHub state; review the requested scope before approving write operations.

### Agents and persistent instructions

| Agent or instruction scope | Configuration | Role |
| --- | --- | --- |
| Codex primary agent | Codex session | Performs the requested repository work under the active sandbox and approval policy |
| Codex sub-agents | Created on demand within a Codex session | Handle explicitly delegated, bounded work in parallel; they share the workspace and do not represent persistent named agents |
| Personal Codex instructions | `$HOME/.codex/AGENTS.md` | Apply personal defaults across workspaces |
| Development-workspace instructions | `$HOME/code/AGENTS.md` | Apply shared development rules, including Context7, vexp, Podman, and shell-formatting policy |
| Repository instructions | Repository or nested `AGENTS.md` files | Add repository-specific validation, review, and safety rules; the closest applicable file governs its subtree |
| CodeRabbit | `.coderabbit.yaml` plus the CodeRabbit service | Reviews ready pull requests and skips drafts unless review is requested manually |
| GitHub Actions | `.github/workflows/` | Runs baseline validation, LikeC4 and Mermaid checks, and repository-governance auditing |

Files named `agents/openai.yaml` inside installed skills define display,
invocation, policy, and tool-dependency metadata for those skills. They do not
define additional autonomous agents. The repository `AGENTS.md` also describes
Dependabot, Codecov, and a generic style-linter role, but this repository does
not currently configure those three services; do not treat them as active
agents until their configuration exists.

## Secrets and credentials

| Tool | Version | Purpose |
| --- | --- | --- |
| Doppler CLI | 3.76.5 | Command-scoped secret injection for local development tools |

Erode uses Doppler project `homelab-dev` and config `dev_personal` for its AI
provider credential. GitHub CLI remains the source of its GitHub token. See
[Erode Installation and Configuration](erode-installation-and-configuration.md)
and [Doppler Secrets Management](doppler-secrets-management.md) for the
credential-scoped wrapper and security boundaries.

GitHub Actions governance uses Doppler project `homelab-dev`, environment
`github`, and config `ci`. Its `REPOSITORY_AUDIT_TOKEN` is a read-only
fine-grained GitHub PAT restricted to the private `bash-bcs-workspace`
repository and synchronized into the `homelab-docs` Actions secrets. See
[GitHub Actions Governance](github-actions-governance.md) for its permissions,
verification, rotation, and revocation procedures.

## Supporting runtimes and package managers

| Tool | Version | Current use |
| --- | --- | --- |
| Python | 3.12.3 | pre-commit, yamllint, and Python-based CLI tooling |
| pipx | 1.4.3 | Isolated installation of check-jsonschema and Ansible Core |
| Node.js | 26.4.0 | Markdown and AI CLI tools |
| npm | 12.0.2 | User-level global Node package installation |
| Go | 1.26.8 | User-level installation of Go CLIs such as `yq` |
| NVM | 0.40.5 | Selects the active Node.js toolchain |

User-level executables are installed in `~/.local/bin`, which must appear on
`PATH`. Node-based tools are installed under the active NVM version.

Examples of the current installation channels are:

```bash
pipx install check-jsonschema
pipx install ansible-core==2.21.3
npm install --global markdownlint-cli2 markdown-link-check vexp-cli
GOBIN="$HOME/.local/bin" go install github.com/mikefarah/yq/v4@latest
GOBIN="$HOME/.local/bin" go install \
    github.com/rhysd/actionlint/cmd/actionlint@v1.7.12
```

The current installation channels are:

| Channel | Tools |
| --- | --- |
| Ubuntu APT packages | Git, GitHub CLI, pre-commit, ShellCheck, shfmt, Bats, yamllint, jq, Gitleaks, Podman, Skopeo |
| Vendor APT repositories | PowerShell, Terraform, Trivy, Doppler |
| Global npm under NVM | Copilot, LikeC4, Mermaid CLI, Erode, vexp, markdownlint-cli2, markdown-link-check |
| pipx | check-jsonschema, Ansible Core |
| Go build in `~/.local/bin` | Mike Farah yq v4, actionlint |
| User-local upstream binaries | Codex, CodeRabbit, TFLint, terraform-docs |
| Snap | Ollama 0.32.14, published as `mz2` |

Avoid similarly named packages from unrelated projects, especially the
Python/jq-wrapper package named `yq`.

## Repository validation coverage

All managed repositories use local pre-commit hooks for applicable files:
ShellCheck, shfmt, markdownlint-cli2, yamllint, GitHub issue-form schemas,
Compose schemas, JSON parsing with jq, Gitleaks, and actionlint. Every managed
repository calls the shared baseline GitHub Actions workflow. A hook runs only
when a repository contains a matching file type. Repository-specific coverage
is:

| Repository | Primary content | Additional tools and validation |
| --- | --- | --- |
| `bash-bcs-workspace` | Bash, Bats tests, Markdown, environment templates | BCS with Ollama; two-space shfmt; Bats CI |
| `frame-and-sample` | Markdown documentation and templates | Baseline workflow and new-repository template |
| `homelab-dns` | Bash, service configuration, Markdown | Shell validation; architecture-drift workflow |
| `homelab-docs` | Markdown, GitHub YAML, LikeC4, and Mermaid | LikeC4, Mermaid, baseline, and governance workflows; manual Erode drift analysis; owns this inventory |
| `homelab-monitoring-observability` | Apache and Munin configuration documentation | Shared checks for applicable files |
| `homelab-network` | Network documentation and repository scaffolding | Shared checks for applicable files |
| `homelab-notification` | Bash, Podman Compose YAML, JSON examples, service configuration | Compose schema checks; scheduled and manual Trivy image scans |
| `homelab-ntp` | NTPsec documentation and configuration scaffolding | Shared checks for applicable files |
| `homelab-scripts` | PowerShell, registry files, Task Scheduler XML, Markdown | Pester 5 on Windows plus baseline validation |
| `homelab-server-configs` | Server configuration, inventory, and Nautobot automation | Shared checks; Nautobot desired-state schema and Ansible syntax validation |
| `homelab-terraform` | Terraform HCL and Markdown | Terraform, TFLint, terraform-docs, and Trivy CI |

The PowerShell workflow is intentionally path-filtered to the two Windows tool
directories and its own workflow file. Its job has read-only repository
permissions and uses an immutable `actions/checkout` commit on
`windows-latest`.

## Maintenance

After installing or upgrading tools, verify the complete repository suite:

```bash
pre-commit clean
pre-commit run --all-files
```

Update this document when a tool is added, removed, or materially changes its
command syntax. Keep repository-specific arguments in that repository's
configuration rather than duplicating them here.
