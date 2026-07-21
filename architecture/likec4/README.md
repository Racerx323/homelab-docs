# Homelab LikeC4 model

This project is the canonical architecture model for the repositories in the
workspace. It separates repository ownership from runtime architecture and
deployment topology.

## Included views

- `index`: repository landscape
- `other-projects`: optional and adjacent repositories
- `homelab-context`: runtime system context
- `network-topology`: physical and logical network structure
- `dns-ha`: Pi-hole, Unbound, Keepalived, and Nebula-Sync
- `notification-platform`: Apprise API and Mailrise
- `observability`: Prometheus, Grafana, Alertmanager, exporters, and Munin
- `provisioning-and-operations`: Terraform, server configuration, scripts, and sync automation
- `deployment-homelab`: physical deployment nodes and named service instances
- `dns-ha-dot-query`, `dns-ha-upgrade`, `dns-failover`, `alert-delivery`, and `pi-hole-sync`: sequence views
- `unbound-pihole-v6-reference`: clean single-node Pi-hole v6 deployment
- `unbound-recursive-query`: full recursive DNS sequence for the clean deployment

## Local usage

Run the interactive viewer from this directory:

```bash
likec4 start .
```

Validate syntax and semantics without layout checks:

```bash
likec4 validate --json --no-layout .
```

The NTP deployment and the boundary between `homelab-terraform` and
`homelab-server-configs` are intentionally described conservatively because
their current READMEs do not contain a concrete topology. Alertmanager is
modeled with its documented direct receiver integrations; no Alertmanager to
Apprise relationship is asserted without configuration evidence.
