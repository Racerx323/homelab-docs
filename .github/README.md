# 🚀 My Homelab Documentation

![License](https://badgen.net/github/license/Racerx323/homelab-docs)
![last commit](https://badgen.net/github/last-commit/Racerx323/homelab-docs)
[![Open Issues](https://badgen.net/github/open-issues/Racerx323/homelab-docs)](https://github.com/Racerx323/homelab-docs/issues?q=is%3Aissue%20state%3Aopen)

A central repository for all documentation, diagrams, configurations, and notes related to my personal homelab setup. The goal of this lab is to provide a stable and powerful environment for learning, experimenting with new technologies, and self-hosting various services.

## 📜 Table of Contents

- [🚀 My Homelab Documentation](#-my-homelab-documentation)
  - [📜 Table of Contents](#-table-of-contents)
  - [🔬 Lab Overview](#-lab-overview)
  - [📦 Software \& Services](#-software--services)
    - [Core Infrastructure](#core-infrastructure)
    - [Self-Hosted Applications](#self-hosted-applications)
  - [🌐 Network Architecture](#-network-architecture)
  - [📁 Repository Structure](#-repository-structure)
  - [🛠️ Development Tooling](#️-development-tooling)
  - [🗺️ Future Goals \& Roadmap](#️-future-goals--roadmap)
  - [📄 License](#-license)

## 🔬 Lab Overview

This homelab is built with a focus on low power consumption, reliability, and ease of maintenance. It serves as the backbone for a variety of self-hosted applications, from media streaming to home automation.

- **Hypervisor:** Proxmox VE
- **Containerization:** Docker & Kubernetes (k3s)
- **Storage:** None currently
- **Networking:** UniFi Dream Machine SE
- **Core Services:** DNS (Pi-hole), Reverse Proxy (Nginx Proxy Manager), Home Automation (Home Assistant)

<!--- ## 💻 Hardware Inventory

| Component         | Model/Spec                               | Role/Notes                                      |
| ----------------- | ---------------------------------------- | ----------------------------------------------- |
| **Hypervisor Host** | Dell OptiPlex 7070 Micro                 | 1x Intel i7-9700T, 64GB RAM, 1TB NVMe           |
| **NAS / Storage**   | Custom Build (JONSBO N1 Case)            | Intel i3-12100, 32GB RAM, 4x 8TB IronWolf (ZFS)  |
| **Network Switch**  | UniFi Switch Lite 8 PoE                  | 8-port GbE Switch                               |
| **Router/Firewall** | UniFi Dream Machine Pro (UDM-Pro)        | Gateway, Firewall, and UniFi Network Controller |
| **UPS**             | CyberPower CP1500PFCLCD                  | Provides ~30 minutes of runtime for all gear    |

--- --->

## 📦 Software & Services

This is a non-exhaustive list of the key software and services running in the lab.

### Core Infrastructure

- **[Proxmox VE](https://www.proxmox.com/en/proxmox-ve):** Open-source virtualization platform for running VMs and LXC containers.
- **[Docker](https://www.docker.com/):** For running containerized applications on a dedicated VM.
- **[Pi-hole](https://pi-hole.net/):** Network-wide ad-blocking and local DNS resolution.
- **[Nginx Proxy Manager](https://nginxproxymanager.com/):** Easy-to-use reverse proxy for exposing services securely.

### Self-Hosted Applications

- **[Home Assistant](https://www.home-assistant.io/):** Open-source home automation.
- **[Uptime Kuma](https://github.com/louislam/uptime-kuma):** A fancy monitoring tool.

## 🌐 Network Architecture

The network is segmented into multiple VLANs for security and traffic management (e.g., Main, IoT, Management).

A network diagram can be found here: [Network Diagram](https://github.com/Racerx323/homelab-network?tab=readme-ov-file#topology)

<!--- *(You can create diagrams using tools like draw.io / diagrams.net and export them as PNG/SVG)* --->

## 📁 Repository Structure

This repository is organized to keep documentation and configurations easy to find.

```text
├── .github/          # Github community files
|   ├── README.md         # This file
├── LICENSE.md        # The license for this repository
├── diagrams/         # Network diagrams, rack layouts, etc.
├── docs/             # Detailed guides, how-tos, and notes
│   ├── development-tool-stack.md # Shared development and validation tools
│   ├── setup/        # Initial setup guides for hardware/software
│   └── services/     # Documentation for specific services
```

## 🛠️ Development Tooling

The shared local development, validation, security, container, Terraform, and
AI-assisted tooling is documented in the
[Development Tool Stack](../docs/development-tool-stack.md).

## 🗺️ Future Goals & Roadmap

- [ ] Set up a Kubernetes (k3s) cluster for more complex applications.
- [ ] Migrate more services to containers.

## 📄 License

The contents of this repository are licensed under the GNU General Public License v3.0. See the LICENSE.md file for details.
