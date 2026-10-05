# Development Tool Stack

This document records the current development and validation tools used across
the homelab repositories. The workstation uses Ubuntu 24.04 under WSL2, Windows
11, and VS Code with separate Windows-local and WSL extension hosts.

Observation and qualification date: October 4, 2026. Installed versions are the
intended workstation baseline. The inventory includes fresh browser qualification,
Ubuntu and native Windows Codex skill/plugin discovery, both extension inventories,
and local repository hook/workflow configuration checks. Qualification uses
synthetic task-owned browser profiles; production sites and accounts are not tested.

The version tables are an inventory, not a lock file. Repository configuration,
such as `.pre-commit-config.yaml`, remains the source of truth for required
checks, arguments, and CI version constraints.

## Workstation and editor

| Component | Version | Scope |
| --- | --- | --- |
| Windows | 10.0.26340.9596 | Windows host; October 4 observation |
| WSL | 2.9.13.0 | WSL manager; October 4 observation |
| WSL kernel | 6.18.40.1-microsoft-standard-WSL2 | Microsoft WSL2 kernel |
| Ubuntu | 24.04.5 LTS | Primary CLI environment |
| VS Code remote launcher | 1.140.0, commit `07f806f999227108933c2e30515b26eecc1fda74` | WSL `code --version`, October 4 |
| VS Code Windows launcher | 1.140.0, commit `07f806f999227108933c2e30515b26eecc1fda74` | Windows `code.cmd --version`, October 4 |

Independent October 4 inventories returned 47 WSL extensions and 55 Windows-local
extensions. The 47 extensions below have matching installed versions in both hosts.
The additional eight Windows-local extensions are listed separately.

| Extension | Version | Extension | Version |
| --- | --- | --- | --- |
| `aaron-bond.better-comments` | 3.0.2 | `antonreshetov.masscode-assistant` | 2.0.1 |
| `christian-kohler.path-intellisense` | 2.10.0 | `coderabbit.coderabbit-vscode` | 0.21.9 |
| `davidanson.vscode-markdownlint` | 0.62.1 | `eamodio.gitlens` | 19.3.0 |
| `ecmel.vscode-html-css` | 2.0.14 | `esbenp.prettier-vscode` | 12.4.0 |
| `formulahendry.code-runner` | 0.12.2 | `github.remotehub` | 0.64.0 |
| `github.vscode-github-actions` | 0.32.3 | `hashicorp.terraform` | 2.40.0 |
| `juniormayhe.copy-as-wsl` | 0.0.3 | `justinxai.wsl-reveal-explorer-pro` | 1.1.6 |
| `likec4.likec4-vscode` | 1.59.4 | `mdickin.markdown-shortcuts` | 0.12.0 |
| `mermaidchart.vscode-mermaid-chart` | 2.8.1 | `monokai.theme-monokai-pro-vscode` | 2.0.16 |
| `ms-azuretools.vscode-containers` | 2.5.2 | `ms-python.debugpy` | 2026.6.0 |
| `ms-python.isort` | 2026.6.0 | `ms-python.python` | 2026.6.0 |
| `ms-python.vscode-pylance` | 2026.4.1 | `ms-python.vscode-python-envs` | 1.38.0 |
| `ms-vscode.cmake-tools` | 1.24.42 | `ms-vscode.cpp-devtools` | 0.6.18 |
| `ms-vscode.cpptools` | 1.34.4 | `ms-vscode.cpptools-extension-pack` | 1.5.1 |
| `ms-vscode.cpptools-themes` | 2.0.0 | `ms-vscode.makefile-tools` | 0.12.17 |
| `ms-vscode.notepadplusplus-keybindings` | 1.0.7 | `ms-vscode.powershell` | 2025.4.0 |
| `ms-vscode.remote-repositories` | 0.42.0 | `ms-vscode.vscode-chat-customizations-evaluations` | 1.0.9 |
| `ms-vscode.vscode-serial-monitor` | 0.13.1 | `openai.chatgpt` | 26.930.41038 |
| `openai.codex-audio` | 26.930.41038 | `redhat.vscode-yaml` | 1.24.0 |
| `ronaldosena.arduino-snippets` | 1.0.2 | `saoudrizwan.claude-dev` | 4.1.22 |
| `sayedabdulkarim.origami-vscode` | 0.0.2 | `streetsidesoftware.code-spell-checker` | 4.9.3 |
| `usernamehw.errorlens` | 3.29.0 | `vexp.vexp-vscode` | 3.3.2 |
| `vscode-icons-team.vscode-icons` | 13.0.0 | `yzane.markdown-pdf` | 2.2.0 |
| `yzhang.markdown-all-in-one` | 3.6.3 | `—` | — |

Windows-local remote-management extensions observed on October 4:

| Extension | Version | Extension | Version |
| --- | --- | --- | --- |
| `jkudo.wsl-manager` | 0.26.1 | `ms-vscode-remote.remote-ssh` | 0.128.0 |
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

The shared shfmt policy uses four-space indentation and case indentation.

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
| Windows PowerShell | 5.1.26100.9596 | Provides the bundled Windows compatibility shell |
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
| markdownlint-cli2 | 0.23.3 | Markdown style and consistency checks |
| markdown-link-check | 3.15.0 | Checks links in Markdown documents |
| yamllint | 1.33.0 | YAML syntax and style validation |
| actionlint | 1.7.12 | Static analysis for GitHub Actions workflows |
| check-jsonschema | 0.37.4 | Schema validation for Compose and GitHub issue YAML |
| jq | 1.7.1 package; CLI banner `jq-1.7` | JSON queries and syntax validation |
| Mike Farah `yq` | 4.53.3 | Native YAML queries and edits using `yq eval` syntax |
| Mermaid CLI (`mmdc`) | 12.0.0 installed and repository pin | Validates Mermaid files and exports SVG, PNG, or PDF |

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

The Mermaid CLI version is pinned in `.mermaid-version`. The installed CLI and
repository pin both use 12.0.0. Bundled Puppeteer 25.12.0 selects
chrome-headless-shell 154.0.8037.57. On October 4, the repository Mermaid validation
and SVG, PNG, and PDF exports passed with the installed browser and no browser
override. See
[Mermaid Installation and Configuration](mermaid-installation-and-configuration.md)
for authoring, validation, export, editor, pre-commit, and CI procedures. After a
CLI change, verify its matching browser before repeating qualification.

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
| Gitleaks | 8.16.0 (APT metadata; CLI build version unset) | Detects secrets in staged changes |
| Trivy | 0.75.0 | Scans Terraform configuration and container images |
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
| Terraform | 1.16.5 | Formats, validates, plans, and applies infrastructure |
| TFLint | 0.63.1 | Finds Terraform errors and provider-specific problems |
| terraform-docs | 0.24.0 | Generates module input and output documentation |
| Trivy | 0.75.0 | Scans infrastructure-as-code configuration |

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
| Codex CLI | 0.160.0 (WSL, October 4) | Repository-aware implementation and troubleshooting |
| GitHub Copilot CLI | 1.0.91 (runtime version verified October 4) | Command-line development assistance |
| CodeRabbit CLI | 0.7.6 | AI review of local changes and committed ranges |
| BCS | 2.0.1 | AI-assisted Bash code review |
| Ollama | 0.34.0; model `qwen3.5:9b` confirmed October 4 | Local inference backend and model used by BCS |
| vexp CLI | 3.3.2 | Local multi-repository context, impact analysis, and completion checks |
| LikeC4 CLI | 1.59.4 (WSL); CI pins 1.59.1 | Architecture-as-code modeling, validation, previews, and model queries |
| Erode CLI | 0.11.0 (package metadata) | AI-assisted comparison of code changes with the LikeC4 model |
| Playwright CLI | 0.1.22 (WSL, October 4) | Browser inspection and automation for agent-assisted workflows |
| Playwright Chromium | Runtime 1247; Chrome for Testing 155.0.8059.12 (qualified October 4) | Version-matched browser used by Playwright CLI |
| ExtraHeadroom Desktop | 0.9.32 (Ubuntu `.deb`) | Manages the local optimization proxy and tool integrations |
| Headroom runtime | 0.39.0 (desktop-managed Python environment) | Compresses model requests and supplies compression MCP tools |

LikeC4 is installed globally under the active NVM Node.js version. See
[LikeC4 Installation and Configuration](likec4-installation-and-configuration.md)
for the workstation, Codex, VS Code, repository, and CI setup.

GitHub Copilot's version command completed using its installed 1.0.91 runtime
outside the filesystem sandbox. No Copilot model request was made.

### Headroom optimization and managed integrations

See [ExtraHeadroom in Ubuntu WSL2](extraheadroom-wsl2.md) for installation,
updates, configuration ownership, operating procedures, and separate readiness,
routing, and savings checks. That guide distinguishes the intended Windows and
Ubuntu roles from the behavior qualified by the observations below.

Headroom's Ubuntu-managed integration records and Codex registration were checked
on October 4. Desktop integration status and Codex plugin installation are
separate observations; Chisle appears in both inventories.

| Integration | Installed version | Provisioning and capability |
| --- | --- | --- |
| Headroom MCP | 0.39.0 | Desktop-managed runtime; user-level Codex MCP registration; compression, retrieval, and statistics tools supplied in the VS Code session |
| RTK | 0.48.0 | Desktop-managed binary; managed shell PATH and workspace instructions select compact shell-command output |
| Codebase Memory MCP | 0.11.0 | Desktop-managed binary; enabled integration and user-level Codex MCP registration; graph, architecture, outline, and snippet tools supplied in the VS Code session |
| Serena MCP | 1.7.0 (`serena-agent`) | Headroom-managed Python environment; user-level Codex MCP registration; symbol navigation, targeted source reads, and symbol editing |
| Chisle | 3.7.0 | Enabled desktop integration and installed Codex plugin; efficiency mode, audit, review, and help skills |

Chisle's desktop record selects `latest`; the installed Codex plugin version is
3.7.0. Headroom's runtime lives under
`$HOME/.local/share/Headroom/headroom/runtime/venv`; it is not on the audited shell
PATH as a bare `headroom` command. RTK and Codebase Memory executables live under
`$HOME/.local/share/Headroom/headroom/bin`.

The WSL VS Code Codex app-server uses `$HOME/.codex` and version 0.160.0.
Its user configuration selects `model_provider = "headroom"` with
`http://127.0.0.1:6767/v1`, and its process inherited that `OPENAI_BASE_URL`.
The managed `.bashrc` and `.profile` routing blocks match. Ubuntu's desktop owns
the front port 6767 and its Headroom worker owns port 6768; both returned ready
health responses. The October 4 routing check found no Windows listener on either port. The separate Codex desktop client uses `/mnt/c/Users/aaron/.codex`, whose
provider configuration is separate from this verified VS Code route.

The routing guard is registered once in `$HOME/.codex/hooks.json` as a
`SessionStart` hook, with trust recorded in the user configuration. It loads
alongside repository hooks; do not duplicate it in every repository. It reports
route problems but deliberately allows Codex to continue. The fresh-task check
recorded no guard issues.

On October 4 at 14:39:08 CDT, a fresh VS Code Codex task selected the Headroom
provider and produced a matching proxy completion. The proxy reduced input from
27,503 to 27,289 tokens, saving 214 tokens (about 0.78%); Codex reported exactly
27,289 input tokens. AI request counters increased during the test window, but
the audit also generated requests, so the entire counter increase is not assigned
to the test. MCP availability, generated instructions, guard trust, and healthy
proxy endpoints are separate checks; successful model routing requires request
evidence. Token compression does not establish a subscription billing reduction.

### Serena installation and WSL IPv4 workaround

[Serena](https://github.com/oraios/serena) provides language-server-backed symbol
tools, including `get_symbols_overview`, `find_symbol`, and
`find_referencing_symbols`, plus symbol editing tools. It can read a selected
function body instead of a whole file. The settled workspace workflow remains
vexp first for orientation and Codebase Memory second for unresolved structural
questions; Serena adds targeted symbol inspection and editing capabilities.

On October 4, Headroom installed `serena-agent` 1.7.0 in
`$HOME/.local/share/Headroom/headroom/serena-venv`. Ubuntu's user-level Codex
registration selects that environment's `bin/serena` executable with
`start-mcp-server`, `--project-from-cwd`, `--context codex`, and
`--open-web-dashboard False`. Project detection uses the nearest ancestor with
`.serena/project.yml` or `.git`; the dashboard flag suppresses automatic browser
opening. Installation, registration, executable launch, and dependency checks
passed. After the Python language-server dependency was configured, a fresh MCP
process reported `ready` and a read-only symbol query succeeded. The existing
connection also returned symbols after the project context was refreshed.

The initial Headroom installation stalled while its pip subprocess waited on an
IPv6 connection to PyPI. It used `--timeout 180 --retries 10` and remained active
after ten minutes. A forced IPv4 request to the same package endpoint returned
HTTP 200 in about 0.09 seconds; a forced IPv6 connection timed out after five
seconds. Compare both paths when diagnosing this symptom:

```bash
curl -4 --silent --show-error --output /dev/null \
    --connect-timeout 5 --max-time 10 \
    --write-out 'IPv4: HTTP %{http_code}, seconds %{time_total}\n' \
    https://pypi.org/simple/serena-agent/
curl -6 --silent --show-error --output /dev/null \
    --connect-timeout 5 --max-time 10 \
    --write-out 'IPv6: HTTP %{http_code}, seconds %{time_total}\n' \
    https://pypi.org/simple/serena-agent/
```

The approved workaround changed `/etc/gai.conf` to prefer IPv4 while keeping
IPv6 enabled and retaining the other default precedence entries. This affects
Ubuntu applications that use the system address-selection policy, beyond Serena.
It works around the observed connection failure; the underlying IPv6
reachability problem was not diagnosed.

For a future installation with the same confirmed symptom, obtain approval for
that Ubuntu-wide change, retain a protected pre-edit rollback copy, and review
any existing active precedence rules before editing with `sudoedit /etc/gai.conf`.
This installation had no active rules beforehand. The applied table is:

```text
precedence ::1/128 50
precedence ::/0 40
precedence 2002::/16 30
precedence ::/96 20
precedence ::ffff:0:0/96 100
```

The owner ran a guarded helper with interactive sudo authentication. It checked
the approved original and proposed contents, preserved ownership and permissions,
and verified that a fresh Serena Python process preferred IPv4 and reached PyPI
with TLS verification. It then sent SIGTERM only to the stalled pip installer
after matching its command, owner, and Headroom parent. Headroom stayed running;
Serena installation and Codex registration subsequently completed.

After changing the policy, verify address ordering in a fresh process. Stop only
a positively identified stale Serena pip subprocess, then inspect Headroom's
result before retrying the add-on. Avoid a second concurrent installer. Check
the completed installation with:

```bash
"$HOME/.local/share/Headroom/headroom/serena-venv/bin/serena" --help
"$HOME/.local/share/Headroom/headroom/serena-venv/bin/python3" -m pip check
```

Both commands exited successfully; pip reported `No broken requirements found`.
To undo the address preference, restore the verified pre-edit configuration,
reviewing any intervening changes first. The temporary helper and rollback copy
from this installation are session evidence, not permanent recovery tools.

#### Serena Python language-server dependencies

Serena's Python backend uses Pyright, provisioned through `uvx`. The `uv`
installation supplies both `uv` and `uvx`; `uvx` is the tool-running interface
equivalent to `uv tool run`. Both installed binaries reported version 0.12.23
on October 4 and live under `$HOME/.local/bin`.

The initial Python activation failed because neither `uvx` nor `uv` could be
found. The owner installed them with Astral's standalone installer, selecting
the user-local directory without modifying shell profiles:

```bash
curl -4 -LsSf https://astral.sh/uv/install.sh |
    env UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 sh

"$HOME/.local/bin/uv" --version
"$HOME/.local/bin/uvx" --version
```

Ubuntu's `$HOME/.codex/config.toml` explicitly selects the installed runner for
Serena, so it does not depend on the MCP process's inherited PATH:

```toml
[mcp_servers.serena.env]
UVX = "/home/aaron/.local/bin/uvx"
```

For the activated `homelab-server-configs` project, `.serena/project.yml`
contains this language-server selection:

```yaml
language_servers: ["python"]
```

The `python` entry selects Pyright. Review each repository's languages before
reusing this setting; it does not configure servers for every language in a
mixed repository. Serena's dependency provider fetches and caches its pinned
Pyright package through `uvx`, outside the Headroom-managed Serena environment.

A running MCP process may retain a previous startup failure. Load the saved
environment in a fresh Serena process, or refresh the project context after the
runner becomes available. Qualification succeeded in both a fresh process using
the saved `UVX` setting and the existing connection: `get_symbols_overview` read
`Webmin/tests/test_disk_discovery_candidate.py` and returned its constants and
`DiskDiscoveryTests` class. No source files were edited and onboarding remained
unperformed. Verify language-server status and an actual symbol query, rather
than relying only on executable version or pip dependency checks.

See [uv installation](https://docs.astral.sh/uv/getting-started/installation/)
and [Serena configuration](https://oraios.github.io/serena/02-usage/050_configuration.html)
for supported installation methods and language-server settings.

### Codebase Memory indexing and agent workflow

Codebase Memory is registered in Ubuntu's `$HOME/.codex/config.toml` with the
Headroom-managed executable
`$HOME/.local/share/Headroom/headroom/bin/codebase-memory-mcp` and
`CBM_CACHE_DIR=$HOME/.local/share/Headroom/headroom/tools/codebase-memory-cache`.
Use that cache explicitly for CLI configuration commands so they address the
same settings and indexes as the MCP server.

On October 4, the managed CLI's `config list` confirmed these effective settings:

| Setting | Effective value | Purpose |
| --- | --- | --- |
| `auto_index` | `true` | Initially indexes a new project when an MCP session connects |
| `auto_index_limit` | `50000` | Maximum file count for automatic initial indexing |
| `auto_watch` | `true` | Registers the connecting session's project with the background watcher |
| `watcher_enabled` | `true` | Enables the background watcher subsystem |

The owner enabled `auto_index`; the watcher settings retain their enabled
defaults. To enable automatic initial indexing and inspect the effective
configuration in the Headroom cache:

```bash
CBM_CACHE_DIR="$HOME/.local/share/Headroom/headroom/tools/codebase-memory-cache" \
    "$HOME/.local/share/Headroom/headroom/bin/codebase-memory-mcp" \
    config set auto_index true

CBM_CACHE_DIR="$HOME/.local/share/Headroom/headroom/tools/codebase-memory-cache" \
    "$HOME/.local/share/Headroom/headroom/bin/codebase-memory-mcp" \
    config list
```

Automatic initial indexing applies to the detected project on session connection;
it does not promise to discover every sibling repository under `$HOME/code`.
Existing manually created indexes remain available after enabling `auto_index`
and do not require a blanket reindex. The background watcher detects Git
working-tree changes and updates registered projects incrementally while running.
These settings were verified; an edit-to-index update was not exercised for every
repository. If an index appears stale, request a refresh through
`index_repository`, then inspect `index_status` and `check_index_coverage`.
Automatic indexing still respects exclusions and can report parsing gaps.

The shared `$HOME/code/AGENTS.md` defines the agent handoff: use vexp first for
orientation when discovery is needed, and skip orientation when the task already
identifies the files or symbols. Use Codebase Memory second for unresolved
structural questions about callers, dependencies, call paths, or architecture,
or when vexp is unavailable, degraded, or returns no useful pivots. Do not repeat
discovery that vexp has already answered adequately.

Select the Codebase Memory project matching the repository; query each relevant
project for cross-repository work. Use `search_graph` for symbols, `trace_path`
for relationships, and `get_architecture` for broader structure. Check coverage
for files relied on, and read source directly where coverage is incomplete or
freshness is uncertain. Use direct searches for literal strings, configuration,
and excluded files. Current source is authoritative when either index disagrees;
retain vexp completion checks and required repository tests.

See the upstream [Codebase Memory configuration guide](https://github.com/DeusData/codebase-memory-mcp/blob/main/docs/CONFIGURATION.md)
for setting defaults and daemon lifecycle details, and its
[tool documentation](https://github.com/DeusData/codebase-memory-mcp#tools)
for indexing and graph queries.

### vexp indexing and IDE integration

The global Ubuntu CLI and the VS Code extension use the same workspace index
when both target `/home/aaron/code`. The primary index and workspace definition
live under `/home/aaron/code/.vexp`. Each registered child repository has a
local `.vexp/parent_workspace.json` pointer to that workspace. The files under
`.vexp` are workstation state and do not belong in Git.

The October 4 status checks found a reachable running daemon, parser 3.3.2,
`Stale: 0`, and all three workspace Git hooks present. No daemon restart or
manual reindex was performed.

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
Verify the installed CLI, its bundled Playwright package, and that package's
browser manifest/executable before launching. A cached browser directory alone
does not establish compatibility. Do not automatically install a runtime during
an audit or downgrade the intended installed version.

The maintained synthetic qualification is in the personal skills checkout:

```bash
python3 evals/playwright-cli/verify_lifecycle.py --report /private/path/report.json
```

Run from that checkout, outside the filesystem sandbox, with a private report
parent. The harness creates an owner-private working/output directory before
launch, unique task sessions, and synthetic loopback pages. It uses only the
existing CLI/browser pairing, closes only owned sessions/tabs, and preserves
preexisting tabs in its synthetic attached browser. Raw state, traces, and video
stay in its private task folder; the report contains sanitized evidence.

The Playwright runtime is stored beneath `~/.cache/ms-playwright`. CLI 0.1.22
uses Playwright/Core 1.64.0-alpha-1790635538000 and Chromium 1247
(155.0.8059.12). The October 4 qualification passed all ten checks: browser-version
readback, snapshot interaction, synthetic storage roundtrip, error handling,
trace/video creation, independent-session cleanup, external-browser attach/detach,
generated-test assertions, and artifact privacy.

The synthetic external-browser launcher uses `--password-store=basic` to avoid
system keyring prompts. This applies only to the test-owned profile. No user
keyring settings or existing browser profiles are changed. Future runtime
installation is a separate maintenance action. Mermaid source generation remains
browser-free; validation and rendering use their own installed runtime.

The installed LikeC4 1.59.4 CLI validated all 16 repository model files on
October 4. The current CI workflow independently pins LikeC4 1.59.1; that
constraint remains recorded because it is still configured.

Erode 0.11.0 is installed for manual advisory analysis through the
credential-scoped wrapper. Its version is confirmed from installed package
metadata; this inventory does not retrieve a provider credential or run an AI
analysis.

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

The eleven surveyed local checkouts have `.coderabbit.yaml` files that inherit
CodeRabbit organization settings and apply the shared draft-first policy:

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
| Context7 | 1.0.1 | Library documentation skill and MCP server |
| GitHub | 0.1.12-5f7cd798dc99 | GitHub connector tools |
| Codex Security | 0.1.31 | Security review workflows |
| Mintlify MCP | 1.0.0 | Documentation connector tools |
| CodeRabbit | 1.1.4 | Review workflow skill |
| OpenAI Templates | 0.1.1 | Explicit workflow templates |
| Pages | 0.1.19 | Page and Space workflows |
| Sites | 1.0.0-b | Website creation, publishing, and hosting workflows |
| Chisle | 3.7.0 | Efficiency mode, audit, review, and help skills; managed through Headroom |
| Plugin Management | 0.1.0 | Plugin management workflow |
| Work Pets | 0.1.6 | Pet asset workflows |

All eleven were installed and enabled in the October 4 `codex plugin list --json`
result. That command is the installation authority; cached packages and a
session's supplied skill catalog are separate observations. Enabled installation
does not prove every capability is callable in every client.

### Skills

Codex may invoke a skill when a request matches its description. Invoke one
explicitly with `$skill-name` when the workflow must be selected. The detailed
trigger rules and procedures remain in each skill's `SKILL.md`.

Fresh metadata-only `skills/list` discovery used the actual client homes:
`/home/aaron/.codex` for Ubuntu and `C:\\Users\\aaron\\.codex` for native Windows.
Ubuntu returned 13 enabled entries with no load errors. Windows returned 12
enabled entries with no load errors, including two `openai-docs` entries.

| Scope | Current discovered skills | Client |
| --- | --- | --- |
| Managed system | `imagegen`, `openai-docs`, `review-agent`, `skill-creator`, `skill-installer` | Ubuntu and native Windows |
| Personal | `clear-writing`, `likec4-dsl`, `playwright-cli` | Ubuntu |
| Context7 plugin | `context7:context7-mcp` | Ubuntu |
| Chisle plugin | `chisle:chisle`, `chisle:chisle-audit`, `chisle:chisle-review`, `chisle:chisle-help` | Ubuntu |
| Windows user scope | `doc`, `migrate-to-codex`, `openai-docs`, `pdf`, `security-best-practices`, `security-ownership-map`, `security-threat-model` | Native Windows |

Windows has a user-scoped `openai-docs` alongside its managed system copy.
Discovery lists both as enabled; this inventory does not establish which duplicate
wins invocation. Native Windows discovery refreshed its client-managed system
bundle automatically. Ubuntu's managed skill files were unchanged.

`clear-writing` supports drafting, minimal editing, and detection without
rewriting or claiming AI authorship. Personal source bundles and maintenance
instructions live in
[personal-codex-skills](https://github.com/Racerx323/personal-codex-skills).
The source checkout is `$HOME/code/personal-codex-skills`; install only reviewed
`skills/<name>/` bundles under `$HOME/.agents/skills`. Installed copies do not
automatically follow source edits. Codex-managed system skills and compatibility
data remain under `$HOME/.codex/skills`. Use the Context7 plugin bundle rather
than adding a duplicate personal entrypoint.

#### Per-client capability inventory

Observation date: October 4, 2026. Native Windows discovery used the Windows VS
Code extension's bundled Codex 0.160.0, not the WSL process used by the separate
Codex desktop client. Plugin installation, local skill discovery, and the
capabilities supplied to the active VS Code conversation are separate observations.

| Capability | Ubuntu Codex 0.160.0 | Active WSL VS Code conversation | Native Windows Codex 0.160.0 |
| --- | --- | --- | --- |
| Clear Writing, LikeC4, Playwright skills | Discovered, enabled | Supplied | Not discovered |
| Context7 1.0.1 | Plugin installed/enabled; skill discovered | Skill and MCP supplied | Plugin not installed; skill not discovered |
| imagegen, openai-docs, skill-creator, skill-installer | Discovered, enabled | Supplied | Discovered, enabled; openai-docs also has a user copy |
| review-agent | Discovered, enabled | Not supplied | Discovered, enabled |
| CodeRabbit 1.1.4 | Plugin installed/enabled; skill not in local discovery | Skill supplied | Plugin installed/enabled; skill not in local discovery |
| Codex Security 0.1.31 | Plugin installed/enabled; skills not in local discovery | Skills supplied | Plugin installed/enabled; skills not in local discovery |
| Plugin Management 0.1.0 | Plugin installed/enabled; skill not in local discovery | Skill supplied | Plugin installed/enabled; skill not in local discovery |
| Work Pets 0.1.6 | Plugin installed/enabled; skills not in local discovery | Skills supplied | Plugin installed/enabled; skills not in local discovery |
| Pages 0.1.19 | Plugin installed/enabled; skills not in local discovery | Skills supplied | Plugin installed/enabled; skills not in local discovery |
| Sites 1.0.0-b | Plugin installed/enabled; skill not in local discovery | Skill supplied | Plugin installed/enabled; skill not in local discovery |
| Chisle 3.7.0 | Plugin installed/enabled; four skills discovered | Four skills supplied | Plugin not installed; skills not discovered |
| Headroom / Codebase Memory MCP | Both user-level registrations present | Tools supplied; Headroom routing separately verified | Headroom MCP registered; Codebase Memory absent; no Headroom model provider selected |
| Serena MCP | 1.7.0 installed; user-level registration; explicit `UVX` setting | Tools supplied after installation; Python symbol query passed | Not checked for Serena |
| OpenAI Templates 0.1.1 | Plugin installed/enabled | Not supplied | Plugin installed/enabled |
| GitHub / Mintlify MCP | Plugins installed/enabled | Connector tools supplied | Plugins installed/enabled; callable tools not tested |
| Windows user-scoped skills | Not discovered | Not supplied | Seven enabled entries listed above |

Native Windows has nine installed/enabled plugins: the Ubuntu plugin list minus
Context7 and Chisle. Enabled installation does not prove every capability is
callable. Local `skills/list` results do not include every remotely supplied
plugin skill. Do not install packages simply to make different clients match.

#### Runtime and helper constraints

The managed OpenAI Docs manual helper is invoked through
`$HOME/.local/share/codex-hardening/fetch-manual-private.py`, which validates its
private cache. Codex Security supplemental artifacts use persistent storage and
inline content. Temporary saves and `sourcePath` imports remain prohibited until
the actual plugin process has a verified owner-private temporary parent.

### MCP servers

| Server | Provisioning | Purpose |
| --- | --- | --- |
| vexp | Installed CLI/parser 3.3.2; user-level Codex registration | Shared local multi-repository context, impact analysis, and completion checks |
| LikeC4 | Installed CLI 1.59.4; user-level Codex registration | Architecture model search, graph queries, semantic layout, and view or deployment inspection |
| GitKraken | Global Codex configuration through GitLens | Git operations plus GitHub issue, pull request, workspace, and review workflows |
| Playwright | Global Codex configuration; on-demand `@playwright/mcp` package | Browser inspection and automation |
| Context7 | Context7 plugin and global remote-server registration | Current, version-specific library, framework, SDK, API, CLI, and cloud-service documentation |
| Headroom | Desktop-managed runtime 0.39.0 and user-level Codex registration | Local compression, retrieval, and statistics tools; model proxy routing is configured separately |
| Codebase Memory | Desktop-managed binary 0.11.0 and user-level Codex registration | Repository graph indexing and queries, architecture views, file outlines, and code snippets |
| Serena | Headroom-managed `serena-agent` 1.7.0 environment and user-level Codex registration | Language-server-backed symbol navigation, selected function reads, and symbol editing |

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
| Development-workspace instructions | `$HOME/code/AGENTS.md` | Apply shared development rules, including Context7, the vexp-first and Codebase Memory-second workflow, Podman, and shell-formatting policy |
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
| Doppler CLI | 3.76.6 | Command-scoped secret injection for local development tools |

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
| uv | 0.12.23 | Python package, runtime, and tool management; supplies Serena's external language-server dependency runner |
| uvx | 0.12.23 (bundled with uv) | Runs isolated Python tools, including Serena's Pyright language server |
| Node.js | 26.4.0 | Markdown and AI CLI tools |
| npm | 12.2.0 | User-level global Node package installation |
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

Installation channels identified from current executable paths, package metadata,
and managed integration records are:

| Channel | Tools |
| --- | --- |
| Ubuntu APT packages | Git, GitHub CLI, pre-commit, ShellCheck, shfmt, Bats, yamllint, jq, Gitleaks, Podman, Skopeo |
| Vendor APT repositories | PowerShell, Terraform, Trivy, Doppler |
| Global npm under NVM | Copilot, LikeC4, Mermaid CLI, Erode, vexp, markdownlint-cli2, markdown-link-check |
| pipx | check-jsonschema, Ansible Core |
| Go build in `~/.local/bin` | Mike Farah yq v4, actionlint |
| User-local upstream binaries | Codex, CodeRabbit, TFLint, terraform-docs; uv and uvx through Astral's standalone installer |
| Snap | Ollama 0.34.0, published as `mz2` |
| Ubuntu `.deb` plus desktop-managed artifacts | ExtraHeadroom Desktop; self-contained Headroom Python runtime, Serena environment, RTK, Codebase Memory, and Chisle integration |

Avoid similarly named packages from unrelated projects, especially the
Python/jq-wrapper package named `yq`.

## Repository validation coverage

The October 4 local survey read hook IDs, workflow files, and shared workflow
references from eleven checkouts. Each configures ShellCheck, shfmt,
markdownlint-cli2, yamllint, actionlint, GitHub issue-form and Compose schema
validation, JSON parsing, and Gitleaks. A hook runs only when its file filters or
stage apply. All eleven configure the shared baseline validation workflow.

`bash-bcs-workspace` is not present in this workspace, so no current repository
coverage is claimed for it. The installed BCS 2.0.1 executable remains inventoried.
The table records configured coverage; it does not claim every repository's
complete test suite was executed.

| Repository | Primary content | Additional tools and validation |
| --- | --- | --- |
| `frame-and-sample` | Markdown documentation and templates | Baseline workflow and new-repository template |
| `homelab-dns` | Bash, service configuration, Markdown | Shell validation; architecture-drift workflow |
| `homelab-docs` | Markdown, GitHub YAML, LikeC4, and Mermaid | LikeC4, Mermaid, baseline, and governance workflows; manual Erode drift analysis; owns this inventory |
| `homelab-monitoring-observability` | Apache and Munin configuration documentation | Shared checks plus the Munin scaffold hook |
| `homelab-network` | Network documentation and repository scaffolding | Shared checks for applicable files |
| `homelab-notification` | Bash, Podman Compose YAML, JSON examples, service configuration | Compose schemas, lifecycle/update policy hooks, and manual or scheduled Trivy image scans |
| `homelab-ntp` | NTPsec documentation and configuration scaffolding | Shared checks plus offline NTP baseline validation |
| `homelab-scripts` | PowerShell, registry files, Task Scheduler XML, Markdown | Pester 5 on Windows plus baseline validation |
| `homelab-server-configs` | Server configuration, inventory, and Nautobot automation | Shared checks; shell/deployment policies, Nautobot and Backblaze schemas, offline contract regressions, and Ansible syntax checks |
| `homelab-terraform` | Terraform HCL and Markdown | Terraform, TFLint, terraform-docs, and Trivy CI |
| `personal-codex-skills` | Standalone skill sources, evaluation fixtures, and maintenance helpers | Shared baseline workflow; manual skill metadata and browser lifecycle evaluations |

The PowerShell workflow is intentionally path-filtered to the two Windows tool
directories and its own workflow file. Its job has read-only repository
permissions and uses an immutable `actions/checkout` commit on
`windows-latest`.

## Maintenance

After installing or upgrading tools, verify the complete repository suite:

```bash
pre-commit run --all-files
```

Update this document when a tool is added, removed, or materially changes its
command syntax. Keep repository-specific arguments in that repository's
configuration rather than duplicating them here.
