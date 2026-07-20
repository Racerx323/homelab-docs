# 🚀 My Homelab Documentation

![License](https://badgen.net/github/license/Racerx323/homelab-docs)
![last commit](https://badgen.net/github/last-commit/Racerx323/homelab-docs)
[![Open Issues](https://badgen.net/github/open-issues/Racerx323/homelab-docs)](https://github.com/Racerx323/homelab-docs/issues?q=is%3Aissue%20state%3Aopen)

A central index for the documentation, configuration, automation, and
infrastructure repositories that make up my personal homelab. The lab provides
a maintainable environment for learning, testing infrastructure changes, and
self-hosting services without losing sight of recovery and security.

## 📜 Table of Contents

- [🚀 My Homelab Documentation](#-my-homelab-documentation)
  - [📜 Table of Contents](#-table-of-contents)
  - [🔬 Lab Overview](#-lab-overview)
  - [📦 Software \& Services](#-software--services)
    - [Core Infrastructure](#core-infrastructure)
    - [Services and Workloads](#services-and-workloads)
  - [🌐 Network Architecture](#-network-architecture)
  - [🗃️ Repository Ecosystem](#️-repository-ecosystem)
  - [📁 Repository Structure](#-repository-structure)
  - [🛠️ Development Tooling](#️-development-tooling)
  - [🗺️ Future Goals \& Roadmap](#️-future-goals--roadmap)
  - [📄 License](#-license)

## 🔬 Lab Overview

This homelab is built with a focus on low power consumption, reliability,
repeatable configuration, and ease of maintenance. Current platform choices
and implementation status are:

- **Hypervisor:** Not currently chosen
- **Containers:** Podman, with rootful and rootless systemd deployment patterns
- **Reverse proxy:** Caddy
- **Storage:** No managed storage platform currently documented
- **Networking:** UniFi Dream Machine SE with segmented VLANs
- **DNS:** Highly available Pi-hole, Unbound, and Keepalived design
- **Notifications:** Apprise API with optional Mailrise SMTP relay
- **Time synchronization:** NTPsec server and client scaffolding
- **Automation:** Terraform, Bash, PowerShell 7, Windows registry files, and
  Task Scheduler templates

<!--- ## 💻 Hardware Inventory

| Component         | Model/Spec                               | Role/Notes                                      |
| ----------------- | ---------------------------------------- | ----------------------------------------------- |
| **Compute Host**    | Dell OptiPlex 7070 Micro                 | Candidate host; final role not chosen            |
| **NAS / Storage**   | Custom Build (JONSBO N1 Case)            | Intel i3-12100, 32GB RAM, 4x 8TB IronWolf (ZFS)  |
| **Network Switch**  | UniFi Switch Lite 8 PoE                  | 8-port GbE Switch                               |
| **Router/Firewall** | UniFi Dream Machine Pro (UDM-Pro)        | Gateway, Firewall, and UniFi Network Controller |
| **UPS**             | CyberPower CP1500PFCLCD                  | Provides ~30 minutes of runtime for all gear    |

--- --->

## 📦 Software & Services

This is a non-exhaustive list of selected platforms and services. A repository
may contain a production-ready deployment, documentation, or scaffolding for
future implementation; the repository ecosystem table identifies that scope.

### Core Infrastructure

- **Hypervisor:** Not currently chosen or documented.
- **Terraform:** Provides infrastructure-as-code environments and reusable
  modules.
- **[Podman](https://podman.io/):** Runs containers without requiring a central
  daemon and supports rootful or rootless systemd-managed services.
- **[Caddy](https://caddyserver.com/):** Provides reverse proxying and automatic
  HTTPS for internal services.
- **[Pi-hole](https://pi-hole.net/):** Provides network-wide filtering and local
  DNS management.
- **[Unbound](https://unbound.net/):** Supplies recursive, caching DNS resolution.
- **[Keepalived](https://www.keepalived.org/):** Manages the highly available DNS
  virtual IP.
- **NTPsec:** Provides the planned server and client time-synchronization layer.

### Services and Workloads

- **[Apprise API](https://github.com/caronc/apprise-api):** Central notification
  API deployed with Podman.
- **[Mailrise](https://github.com/YoRyan/mailrise):** Optional SMTP-to-Apprise
  relay for services that only support email notifications.
- **Monitoring and observability:** Apache and Munin configuration scaffolding,
  with room for additional metrics, dashboards, and alerting services.
- **Windows and WSL utilities:** DNS client tuning, an elevated system-repair
  context menu, repository synchronization, and Apprise completion notices.

## 🌐 Network Architecture

The UniFi network is segmented into Management, Main, and IoT VLANs for
security and traffic management. The UDM-SE provides gateway, firewall, DHCP,
and controller functions, with additional UniFi switching and wireless access
infrastructure documented in the network repository.

A network diagram can be found here: [Network Diagram](https://github.com/Racerx323/homelab-network?tab=readme-ov-file#topology)

The canonical cross-repository architecture model is maintained in
[LikeC4](../architecture/likec4/README.md). It describes the homelab platforms,
repository portfolio, deployment topology, and major relationships as
version-controlled architecture data.

## 🗃️ Repository Ecosystem

| Repository | Scope | Current status |
| --- | --- | --- |
| [`homelab-docs`](https://github.com/Racerx323/homelab-docs) | Central documentation and development-tool inventory | Active |
| [`homelab-network`](https://github.com/Racerx323/homelab-network) | UniFi topology, hardware, VLANs, and LoRaWAN notes | Documented |
| [`homelab-dns`](https://github.com/Racerx323/homelab-dns) | Pi-hole, Unbound, Keepalived, and DNS support tools | Configuration and guides |
| [`homelab-notification`](https://github.com/Racerx323/homelab-notification) | Podman deployment of Apprise API and optional Mailrise | Deployable |
| [`homelab-ntp`](https://github.com/Racerx323/homelab-ntp) | NTPsec server and client configuration | Scaffolded |
| [`homelab-monitoring-observability`](https://github.com/Racerx323/homelab-monitoring-observability) | Monitoring service configuration | Scaffolded |
| [`homelab-server-configs`](https://github.com/Racerx323/homelab-server-configs) | Webmin, watchdog, and server configuration | Scaffolded |
| [`homelab-terraform`](https://github.com/Racerx323/homelab-terraform) | Infrastructure-as-code environments and reusable modules | Scaffolded |
| [`homelab-scripts`](https://github.com/Racerx323/homelab-scripts) | Windows and WSL administration and automation | Active |

## 📁 Repository Structure

This repository is intentionally small and serves as the entry point to the
specialized repositories above.

```text
homelab-docs/
├── .github/
│   ├── README.md                 # This repository overview
│   ├── CONTRIBUTING.md          # Contribution guidance
│   ├── SECURITY.md              # Vulnerability reporting policy
│   └── ISSUE_TEMPLATE/          # Structured support and change requests
├── architecture/
│   └── likec4/
│       ├── deployment/           # Deployment model fragments
│       ├── model/                # Logical architecture model fragments
│       ├── views/                # Architecture view definitions
│       ├── likec4.config.json    # LikeC4 workspace configuration
│       └── specification.c4      # Shared model specification
├── docs/
│   ├── development-tool-stack.md # Authoritative tooling inventory
│   ├── doppler-secrets-management.md
│   ├── erode-installation-and-configuration.md
│   └── likec4-installation-and-configuration.md
├── .pre-commit-config.yaml       # Local validation and manual checks
├── AGENTS.md                     # Automation and review instructions
└── LICENSE.md                    # GNU GPL v3 license
```

## 🛠️ Development Tooling

The primary workstation is Ubuntu 24.04 under WSL2, with PowerShell 7 available
in both Ubuntu and Windows. NVM supplies the Node.js toolchain used by the
documentation, architecture, and AI-assisted CLIs. User-level standalone
executables are available through `~/.local/bin`.

The shared development workflow includes:

- **Source and validation:** Git, GitHub CLI, and pre-commit.
- **Shell and documentation:** ShellCheck, shfmt, Bats, markdownlint-cli2,
  yamllint, check-jsonschema, jq, and Mike Farah yq.
- **Security and containers:** Gitleaks, Trivy, Podman, and Skopeo.
- **Infrastructure:** Terraform, TFLint, and terraform-docs.
- **Architecture:** LikeC4 formatting and validation, with manual advisory
  Erode drift analysis.
- **AI-assisted development:** Codex, Copilot, CodeRabbit, BCS with Ollama, and
  vexp.
- **Secrets:** Doppler provides command-scoped provider credentials;
  GitHub CLI remains the GitHub credential source.
- **Windows testing:** PowerShell 7 and Pester, with Pester 5 authoritative in
  GitHub Actions.

Install the repository hook and run the deterministic validation suite from
the repository root:

```bash
pre-commit install
pre-commit run --all-files
likec4 validate --json --no-layout architecture/likec4
```

Run Erode explicitly when architecture-relevant staged changes need advisory
analysis:

```bash
pre-commit run erode-architecture-drift --hook-stage manual
```

> [!WARNING]
> The Erode hook sends selected code changes and LikeC4 model context to the
> configured AI provider and can consume API quota.

Erode remains advisory until the relevant LikeC4 components have complete
repository mappings. Do not invoke every manual-stage hook as a group unless
all networked and AI-backed checks are intentionally in scope.

The [Development Tool Stack](../docs/development-tool-stack.md) is the source
of truth for installed versions, package channels, and cross-repository
validation coverage. Detailed setup is documented in:

- [LikeC4 Installation and Configuration](../docs/likec4-installation-and-configuration.md)
- [Erode Installation and Configuration](../docs/erode-installation-and-configuration.md)
- [Doppler Secrets Management](../docs/doppler-secrets-management.md)

## 🗺️ Future Goals & Roadmap

- [ ] Select and document the hypervisor platform.
- [ ] Replace the empty Terraform environments and modules with reviewed,
  environment-specific infrastructure definitions.
- [ ] Add version-controlled Caddy configuration and deployment guidance.
- [ ] Expand Podman deployment patterns to additional suitable services.
- [ ] Populate the NTPsec, monitoring, and server-configuration scaffolds.
- [ ] Keep recovery, validation, and rollback guidance alongside every deployed
  service.

## 📄 License

The contents of this repository are licensed under the GNU General Public License v3.0. See the LICENSE.md file for details.
