# Homelab LikeC4 model

This project is the canonical architecture model for the repositories in the
workspace. It separates repository ownership from runtime architecture and
deployment topology.

## Included views

- `index`: repository landscape
- `other-projects`: optional and adjacent repositories
- `homelab-context`: runtime system context
- `network-topology`: physical and logical network structure
- `dns-ha`: coupled Pi-hole v5, Unbound, Caddy, Keepalived, and synchronization platform
- `reverse-proxy-ha`: accepted Node A MASTER and Node B BACKUP steady state
- `reverse-proxy-failover`: coupled DNS and Proxy failure, continuity, and preferred-owner recovery
- `protocol-v2-publication`: immutable publication, transfer, finalization, reconciliation, and activation
- `notification-flow`: persistent local enqueue and at-least-once Apprise delivery
- `notification-platform`: remote Apprise API and Mailrise platform
- `observability`: Prometheus, Grafana, Alertmanager, exporters, and independent optional Munin
- `provisioning-and-operations`: Terraform, server configuration, scripts, and sync automation
- `deployment-homelab`: complete physical deployment
- `reverse-proxy-deployment`: both HA nodes, Caddy and lsyncd instances, coupled VIPs, and Apprise API
- `dns-ha-dot-query`, `dns-ha-upgrade`, `dns-failover`, `alert-delivery`, and `pi-hole-sync`: supporting sequence views
- `unbound-pihole-v6-reference`: separate clean single-node Pi-hole v6 reference, not the production HA deployment
- `unbound-recursive-query`: full recursive DNS sequence for the separate reference deployment

## Production provenance

The coupled DNS and Proxy model is derived from these accepted sources in
`homelab-server-configs`:

- `Caddy/docs/caddy_plan-v1.1.md`
- `Caddy/docs/ARCHITECTURE.md`
- `Caddy/manifests/deployment.yaml`
- `Caddy/manifests/current-live-state.tsv`
- `Caddy/manifests/synchronization-protocol-v2.yaml`
- `Caddy/manifests/durable-apprise-production.tsv`
- `Caddy/manifests/serving-health-production.tsv`
- `Caddy/manifests/dns-records.yaml`
- `Caddy/manifests/dependencies.yaml`
- `Caddy/manifests/reproducibility-production.yaml`

The accepted inventory records Pi-hole Core `v5.18.3`, Web `v5.21`, and FTL
`v5.25.2`. The separate Pi-hole v6 files and views are reference material and
do not imply a production migration.

Repository sources define configuration ownership. Accepted-live manifests
remain authoritative when repository source differs from installed production.
TLS secret bytes, SSH private keys and host trust, firewall enforcement, and
Apprise provider configuration remain external inputs.

## Validation provenance

CI installs LikeC4 `1.59.1`. From the repository root, validate all sources:

```bash
likec4 format --check
likec4 validate
pre-commit run --all-files
```

For a focused semantic check, repeat `--file` for every edited `.c4` source:

```bash
likec4 validate --json --no-layout \
    --file architecture/likec4/model/dns.c4 \
    --file architecture/likec4/model/repositories.c4 \
    --file architecture/likec4/deployment/homelab.c4 \
    --file architecture/likec4/views/runtime.c4 \
    --file architecture/likec4/views/dynamic.c4 \
    architecture/likec4
```

Require `valid=true` and `filteredErrors=0`. LikeC4 1.59.1 and 1.59.2 compute
`filteredFiles` from distinct files that contain reported errors, so a valid
filtered run reports `filteredFiles=0`. The repeated `--file` arguments record
the edited source set.

Generated PNG, JPEG, JSON, Mermaid, and site exports stay out of Git unless
the repository adopts them as published artifacts. The `.c4`
sources and successful validation are the generated-view provenance.

Run the interactive viewer from the project directory:

```bash
likec4 start .
```

The NTP deployment and the boundary between `homelab-terraform` and
`homelab-server-configs` remain conservative because their current READMEs do
not provide a complete topology. Alertmanager retains its documented direct
receiver integrations; no Alertmanager-to-Apprise relationship is asserted
without configuration evidence.
