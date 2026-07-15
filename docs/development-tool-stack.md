# Development Tool Stack

This document records the shared development and validation tools used across
the homelab repositories. The workstation baseline is Ubuntu 24.04 under WSL2.
Versions were last verified on July 15, 2026.

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

Hooks configured with the `manual` stage, including container image scans, run
only when explicitly requested:

```bash
pre-commit run --hook-stage manual --all-files
```

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

## Documentation and structured data

| Tool | Version | Purpose |
| --- | --- | --- |
| markdownlint-cli2 | 0.23.0 | Markdown style and consistency checks |
| markdown-link-check | 3.14.2 | Checks links in Markdown documents |
| yamllint | 1.33.0 | YAML syntax and style validation |
| check-jsonschema | 0.37.4 | Schema validation for Compose and GitHub issue YAML |
| jq | 1.7.1 | JSON queries and syntax validation |
| Mike Farah `yq` | 4.53.3 | Native YAML queries and edits using `yq eval` syntax |

Common direct checks include:

```bash
markdownlint-cli2 '**/*.md'
markdown-link-check README.md
yamllint --strict .
check-jsonschema --builtin-schema vendor.compose-spec compose.yaml
jq empty path/to/file.json
yq eval '.services' compose.yaml
```

The active `yq` implementation must be Mike Farah v4. Confirm it with:

```bash
yq --version
```

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
| GitHub Copilot CLI | 1.0.68 | Command-line development assistance |
| BCS | 2.0.1 | AI-assisted Bash code review |
| Ollama | `qwen3.5:9b` | Local inference backend used by BCS |
| vexp CLI | 2.1.7 | Indexed repository context and impact analysis |

BCS is maintained in `bash-bcs-workspace`. Its configured model name must match
an installed Ollama model:

```bash
ollama list
bcs check path/to/script.sh
```

## Supporting runtimes and package managers

| Tool | Version | Current use |
| --- | --- | --- |
| Python | 3.12.3 | pre-commit, yamllint, and Python-based CLI tooling |
| pipx | 1.4.3 | Isolated installation of check-jsonschema |
| Node.js | 26.4.0 | Markdown and AI CLI tools |
| npm | 12.0.1 | User-level global Node package installation |
| Go | 1.26.4 | User-level installation of Go CLIs such as `yq` |
| NVM | Current user installation | Selects the active Node.js toolchain |

User-level executables are installed in `~/.local/bin`, which must occur once
in `PATH`. Node-based tools are installed under the active NVM version.

Examples of the current installation channels are:

```bash
pipx install check-jsonschema
npm install --global markdownlint-cli2 markdown-link-check vexp-cli
GOBIN="$HOME/.local/bin" go install github.com/mikefarah/yq/v4@latest
```

Terraform, TFLint, terraform-docs, Trivy, Gitleaks, Skopeo, Ollama, and Codex
should be installed from their official release channels. Avoid similarly named
packages from unrelated projects, especially the Python/jq-wrapper package
named `yq`.

## Repository validation coverage

All managed repositories use the common pre-commit checks for ShellCheck,
shfmt, markdownlint-cli2, yamllint, JSON validation, applicable GitHub issue
schemas, applicable Compose schemas, and Gitleaks.

Additional checks are enabled where relevant:

| Repository | Additional validation |
| --- | --- |
| `homelab-notification` | Manual Trivy scans of Apprise API and Mailrise images |
| `homelab-terraform` | Trivy Terraform configuration scan |

## Maintenance

After installing or upgrading tools, verify the complete repository suite:

```bash
pre-commit clean
pre-commit run --all-files
```

Update this document when a tool is added, removed, or materially changes its
command syntax. Keep repository-specific arguments in that repository's
configuration rather than duplicating them here.
