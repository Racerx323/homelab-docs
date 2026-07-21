# Development Tool Stack

This document records the shared development and validation tools used across
the homelab repositories. The primary workstation baseline is Ubuntu 24.04
under WSL2, with PowerShell 7 installed in both Ubuntu and on the Windows host.
Versions were last verified on July 21, 2026.

The version table is an inventory, not a lock file. Repository configuration,
such as `.pre-commit-config.yaml`, remains the source of truth for required
checks and arguments.

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
| PowerShell | 7.6.3 | Runs cross-platform PowerShell and validates Windows automation |
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
| markdownlint-cli2 | 0.23.1 | Markdown style and consistency checks |
| markdown-link-check | 3.14.2 | Checks links in Markdown documents |
| yamllint | 1.33.0 | YAML syntax and style validation |
| actionlint | 1.7.12 | Static analysis for GitHub Actions workflows |
| check-jsonschema | 0.37.4 | Schema validation for Compose and GitHub issue YAML |
| jq | 1.7.1 | JSON queries and syntax validation |
| Mike Farah `yq` | 4.53.3 | Native YAML queries and edits using `yq eval` syntax |
| Mermaid CLI (`mmdc`) | 11.16.0 | Validates Mermaid files and exports SVG, PNG, or PDF |

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
| Trivy | 0.72.0 | Scans Terraform configuration and container images |
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
| Terraform | 1.15.8 | Formats, validates, plans, and applies infrastructure |
| TFLint | 0.63.1 | Finds Terraform errors and provider-specific problems |
| terraform-docs | 0.24.0 | Generates module input and output documentation |
| Trivy | 0.72.0 | Scans infrastructure-as-code configuration |

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

## AI-assisted development

| Tool | Version or model | Purpose |
| --- | --- | --- |
| Codex CLI | 0.142.4 | Repository-aware implementation and troubleshooting |
| GitHub Copilot CLI | 1.0.72 | Command-line development assistance |
| CodeRabbit CLI | 0.6.5 | AI review of local changes and committed ranges |
| BCS | 2.0.1 | AI-assisted Bash code review |
| Ollama | 0.24.0; `qwen3.5:9b` | Local inference backend and model used by BCS |
| vexp CLI | 2.2.3 | Indexed repository context and impact analysis |
| LikeC4 CLI and MCP | 1.59.1 | Architecture-as-code modeling, validation, previews, and model queries |
| LikeC4 DSL skill | Current global installation | LikeC4 syntax and workflow guidance for Codex |
| Erode CLI | 0.9.4 | AI-assisted comparison of code changes with the LikeC4 model |

LikeC4 is installed globally under the active NVM Node.js version. See
[LikeC4 Installation and Configuration](likec4-installation-and-configuration.md)
for the workstation, Codex, VS Code, repository, and CI setup.

Playwright Chromium is intentionally excluded from the core tool inventory.
It is an on-demand runtime used only when LikeC4 publishes PNG or JPEG exports;
the standard formatting, validation, MCP, preview, build, JSON, and DrawIO
workflows remain browser-free. The LikeC4 guide records the version-matched
installation command and storage implications. Generating Mermaid source does
not add a browser requirement unless a separate Mermaid renderer is used to
produce image or PDF artifacts.

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

## Secrets and credentials

| Tool | Version | Purpose |
| --- | --- | --- |
| Doppler CLI | 3.76.0 | Command-scoped secret injection for local development tools |

Erode uses Doppler project `homelab-dev` and config `dev_personal` for its AI
provider credential. GitHub CLI remains the source of its GitHub token. See
[Erode Installation and Configuration](erode-installation-and-configuration.md)
and [Doppler Secrets Management](doppler-secrets-management.md) for the
credential-scoped wrapper and security boundaries.

## Supporting runtimes and package managers

| Tool | Version | Current use |
| --- | --- | --- |
| Python | 3.12.3 | pre-commit, yamllint, and Python-based CLI tooling |
| pipx | 1.4.3 | Isolated installation of check-jsonschema |
| Node.js | 26.4.0 | Markdown and AI CLI tools |
| npm | 12.0.1 | User-level global Node package installation |
| Go | 1.26.4 | User-level installation of Go CLIs such as `yq` |
| NVM | 0.40.5 | Selects the active Node.js toolchain |

User-level executables are installed in `~/.local/bin`, which must appear on
`PATH`. Node-based tools are installed under the active NVM version.

Examples of the current installation channels are:

```bash
pipx install check-jsonschema
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
| pipx | check-jsonschema |
| Go build in `~/.local/bin` | Mike Farah yq v4, actionlint |
| User-local upstream binaries | Codex, CodeRabbit, TFLint, terraform-docs |
| Snap | Ollama 0.24.0, published as `mz2` |

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
| `homelab-server-configs` | Webmin and watchdog configuration scaffolding | Shared checks for applicable files |
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
