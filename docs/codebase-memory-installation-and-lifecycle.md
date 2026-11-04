# Codebase Memory installation and lifecycle for Codex

Codebase Memory (CBM) supplies local code graphs to Codex. Use vexp for initial
orientation, CBM for unresolved structural questions, and Serena for targeted
symbol reads and edits. Current source remains authoritative when an index has
missing or stale coverage.

## Installed state

On November 4, 2026, the owner authorized migration from Headroom-managed CBM
0.11.0 to standalone upstream 0.12.1. GitHub's latest stable release was checked
again immediately before installation. The Linux amd64 portable archive and
published checksum file matched GitHub's release-asset SHA-256 values; the
extracted executable was checked after installation. The checksum signature
bundle was retained but was not cryptographically verified.

| Component | Selection |
| --- | --- |
| Executable | `$HOME/.local/bin/codebase-memory-mcp`, a symlink to the selected release |
| Release directory | `$HOME/.local/share/codebase-memory-mcp/releases/0.12.1` |
| Updater and notices | Release-owned `install.sh`, `LICENSE`, and `THIRD_PARTY_NOTICES.md` beside the executable |
| Codex registration | Existing `codebase-memory` server in `$HOME/.codex/config.toml` |
| Cache and settings | `$HOME/.cache/codebase-memory-mcp`; directory mode `0700` |
| Personal skill | `$HOME/.agents/skills/codebase-memory`; complete bundle deployed from `personal-codex-skills` |
| Workspace instructions | `$HOME/code/AGENTS.md`; existing discovery order retained |
| Shell selection | User-owned `user:standalone_cbm` blocks after Headroom's blocks in `.bashrc` and `.profile` |
| Rollback snapshot | Private `$HOME/.local/share/codebase-memory-mcp/maintenance/20261104-upgrade/backup` |
| Qualification evidence | Private `$HOME/code/.local-evidence/codebase-memory-upgrade-2026-11-04` |

The dated release's portable archive SHA-256 is
`8c3d0341064301e78ecc84cf7348d4e2c6562a0f57448243ea560aaa34de36c1`.
Its installed executable SHA-256 is
`77745491f0a9c346d6da23eed4d92b5feaa31a27a883c9faa4fa9f47c8183705`.
These identify this installation, not future approved releases.

The private rollback directory contains the previous binary, complete cache,
Codex configuration, hooks, instruction files, shell files, and Headroom CBM
records. It is outside the indexed development workspace. The qualification
directory holds release verification and test logs. These files can contain
private source or credentials; do not copy them into a commit or share raw logs.

## Headroom ownership

The owner attempted to disable CBM in Headroom, which remained at
`unregistering Codebase-Memory MCP server`, and disabled the server in Codex.
Inspection found no active CBM process. Headroom's CBM state still said enabled,
and its Codex ownership ledger still contained the old registration.

After backing up those files, migration completed the CBM-only reconciliation:

- Set Headroom's `tools/codebase-memory.json` to `enabled: false`, preserving
  its version field and retained binary/cache.
- Removed only Codex's `codebase-memory` entry from
  `$HOME/.headroom/mcp_installs.json`.
- Replaced the disabled Codex entry with the standalone registration below.

Headroom's proxy, MCP server, managed binaries, and unrelated ledger entries
were preserved. The owner subsequently confirmed that Headroom's interface
shows CBM disabled. No Headroom uninstall was performed; the retained managed
copy is outside the standalone installation's maintenance scope. A future
recurrence should be diagnosed from current records and processes before
editing files again.

The inspected Headroom Python graph watcher resolves CBM through PATH and can
invoke fast-mode indexing. Its presence does not establish that it is active.
After Headroom updates or configuration regeneration, check for unexpected CBM
callers and ownership drift. Do not run a Headroom watcher alongside the native
CBM watcher without deliberately qualifying the shared configuration.

Claude is unused and was not configured. This integration targets Ubuntu/WSL
Codex; native Windows Codex configuration was not changed.

## Codex and runtime configuration

The configuration preserves the existing server name and avoids duplicate
`codebase-memory` and `codebase-memory-mcp` registrations:

```toml
[mcp_servers.codebase-memory]
command = "/home/aaron/.local/bin/codebase-memory-mcp"
args = []
enabled = true
startup_timeout_sec = 30
tool_timeout_sec = 300

[mcp_servers.codebase-memory.env]
CBM_CACHE_DIR = "/home/aaron/.cache/codebase-memory-mcp"
CBM_ALLOWED_ROOT = "/home/aaron/code"
```

No global `cwd` is pinned. A session opened inside a repository keeps its own
working directory. A session opened at `$HOME/code` must select the target graph
by canonical repository root and use its returned project name.

The allowed root confines indexing to the development workspace. It does not
exclude private subdirectories within that workspace or sandbox every MCP
operation. Keep repository ignore rules accurate and inspect coverage when
relying on excluded files. Derived indexes stay in the private cache; normal
indexing uses `persistence=false` so it does not export a graph into a repository.

| Runtime setting | Value | Reason |
| --- | --- | --- |
| `auto_index` | `false` | Avoid automatically indexing the multi-repository parent and its evidence directories |
| `auto_watch` | `true` | Watch the active MCP session's repository |
| `watcher_enabled` | `true` | Refresh registered projects after Git working-tree changes |
| `watch_non_git` | `false` | Avoid repeated directory scans for non-Git roots |

New repositories are indexed explicitly. Existing graphs remain queryable, but
querying one does not itself register a watch. Check `index_status` when freshness
matters. Stable 0.12.1 watches only the active MCP session's repository. An
explicit index of a different root refreshes that graph but does not register
its watch: status reports `not_session_project`. Open Codex in the target
repository for auto-watch, or explicitly refresh targets when working from the
parent workspace. Newer main-branch watch behavior must not be assumed to exist
in the installed stable release.

For a CLI refresh, pass the same cache environment as above and an explicit root:

```bash
"$HOME/.local/bin/codebase-memory-mcp" cli index_repository \
    --repo-path "$HOME/code/homelab-docs" --mode full --persistence false
"$HOME/.local/bin/codebase-memory-mcp" cli index_status \
    --project "$HOME/code/homelab-docs" --format json
```

A one-shot CLI refresh is not a long-lived watch owner. Do not use asynchronous
indexing from the sole one-shot client of a temporary daemon; use the connected
MCP session or explicitly manage a permanent daemon when that is actually needed.

The native daemon is session-managed. No permanent daemon or UI startup was
configured. Watches are not a promise of continuous freshness after all owning
sessions close. Recheck generation, source coverage, and watch state in a fresh
session before relying on the graph.

Manual maintenance must address the same cache as Codex:

```bash
export CBM_CACHE_DIR="$HOME/.cache/codebase-memory-mcp"
export CBM_ALLOWED_ROOT="$HOME/code"
"$HOME/.local/bin/codebase-memory-mcp" --version
"$HOME/.local/bin/codebase-memory-mcp" config list
```

No `CBM_RUNTIME_DIR` override was needed. Keep the cache and rendezvous on the
Linux filesystem. If an override becomes necessary, configure it consistently
for the CLI, MCP frontends, and any hooks: cache selection does not relocate
the rendezvous. Native CBM coordination rejects incompatible active versions,
builds, or canonical cache roots.

## Skill and agent instructions

The personal skill adapts upstream graph-query and coverage guidance to this
workspace. Its maintained [source bundle](../../personal-codex-skills/skills/codebase-memory/SKILL.md)
and [skill maintenance guide](../../personal-codex-skills/docs/codebase-memory.md)
live in `personal-codex-skills`, with attribution, the upstream license notice,
sanitized evaluation cases, and deployment hashes. The complete reviewed bundle
is copied to `~/.agents/skills/codebase-memory`, preserving `~/.codex/skills` for
Codex-managed content. It adds no lifecycle hooks or graph agent profiles.
The existing GitKraken, RTK, Serena, Headroom guard, and vexp hooks remain intact.

Workspace rules require selecting the graph by `root_path`, checking status,
batching evidence-path coverage checks, following pagination, and reading source
for incomplete or uncertain coverage. Empty results cannot establish absence,
dead code, or complete impact. Do not repeat orientation already answered by
vexp, and retain required repository checks.

Do not run upstream's broad automatic client integration against the real home
directory. It would add its own server name, place the skill under Codex's
managed skill root, and install hooks and graph agent profiles. The binary
installer uses `--skip-config`; personal integration is maintained explicitly.

Restart or reconnect the Codex MCP client after changing registration. Installing
a skill on disk does not prove an existing conversation discovered it. Confirm
the fresh client's server version, tool availability, and skill discovery.

## Qualification

The migration qualified a fresh MCP process independently of the disabled
connection in the original chat. It reported version 0.12.1 and all 17 tools.
Serena's existing `homelab-docs` project remained ready and returned shell symbols.

### November 4 completion

All ten preserved repository graphs completed full-mode indexing and reported
ready with November 4 generations. The disposable qualification graph was
deleted afterward, leaving the original ten projects. A repository-rooted MCP
session passed the watcher edit and restoration checks. The earlier test from a
different root returned `not_session_project`; that observed stable-release
limitation is reflected in the runtime guidance above.

| Repository | Partially parsed files | Unusable files |
| --- | ---: | ---: |
| frame-and-sample | 0 | 0 |
| homelab-dns | 6 | 7 |
| homelab-docs | 1 | 0 |
| homelab-monitoring-observability | 8 | 3 |
| homelab-network | 1 | 0 |
| homelab-notification | 0 | 0 |
| homelab-ntp | 1 | 1 |
| homelab-scripts | 1 | 0 |
| homelab-server-configs | 15 | 3 |
| personal-codex-skills | 0 | 0 |

These are the first post-upgrade rebuild's coverage counts, not a promise of
complete parsing or a comparison against identical source at the previous
installation date. Exact-path checks confirmed that the server-configs serving
health script remains partially parsed, and its tmpfiles configuration and
Nautobot image-build service template remain unusable to the parser. Read their
source directly when they matter.

A fresh Codex app-server discovered exactly one enabled personal `codebase-memory`
skill at the intended path and initialized the configured server with all 17
tools. Both fresh login and interactive shells selected the standalone binary.
The existing hooks were byte-identical to the backup; parsed Codex configuration
was unchanged outside the CBM table. Headroom's proxy remained running without
its optional `--code-graph` watcher, and its retained CBM binary was unchanged.

The original IDE conversation was not restarted during installation. Reload or
reconnect that client to use the new tools there. Native MCP operation, fresh
Codex discovery, parser coverage, and reconnection of an existing IDE client are
separate acceptance checks.

## Maintenance lifecycle

### Routine use and release review

Before a task relies on graph evidence, inspect the selected project's status
and freshness. Batch exact evidence paths into `check_index_coverage`, then read
current source for flagged ranges or uncertain scope. Reindex the affected
repository when needed; do not rebuild every repository for an unrelated edit.

Review upstream stable releases monthly and after a relevant parser, daemon,
installer, or integration bug. This is a manual maintenance cadence; no scheduled
task or automatic updater was enabled. Use tagged release notes and source, not
main-branch feature descriptions, when deciding whether to upgrade.

After a Headroom update, verify that its CBM state remains disabled, its ledger
does not reclaim the standalone Codex entry, and both fresh login and interactive
shells select the standalone binary. Preserve the rest of Headroom's routing.

### Prepare an upgrade

1. Select an explicit stable release. Read migration notes, configuration changes,
   parser coverage changes, and any required full rebuild. Record its source tag,
   archive digest, extracted executable digest, and available provenance.
2. Download the release and checksum material to a private staging directory.
   Verify bytes and inspect the archive member list before extraction. Never
   substitute the binary digest for the archive digest.
3. Review the tagged installer. Stage and inspect it without activating it.
   Compare the current personal skill with upstream changes; retain the workspace
   discovery order and personal skill destination.
4. Close or disconnect actual CBM frontends and stop any permanent daemon or
   extra watcher. Inspect processes to establish quiescence. The Headroom proxy
   and other MCP servers do not need to be stopped.
5. Back up the selected executable, complete cache, Codex entry, skill, shell
   blocks, and relevant Headroom records. Copy SQLite files only after writers
   stop, including WAL/SHM files; use SQLite backup APIs for an unavoidable live
   backup. Keep the prior cache sealed for rollback.

### Activate the selected release

Use an application-specific release directory. The following template assumes
the installer and selected release were already reviewed and verified; replace
the version placeholder before execution:

```bash
export CBM_CACHE_DIR="$HOME/.cache/codebase-memory-mcp"
export CBM_ALLOWED_ROOT="$HOME/code"
cbm_version=X.Y.Z
CBM_DOWNLOAD_URL="https://github.com/DeusData/codebase-memory-mcp/releases/download/v${cbm_version}" \
    bash /private/staging/install.sh \
    --dir="$HOME/.local/share/codebase-memory-mcp/releases/$cbm_version" \
    --skip-config
```

The installer downloads and verifies the selected archive before activation.
It can stop account-wide CBM sessions even with `--skip-config`. That flag skips
agent configuration, but does not prevent a shell PATH addition; inspect the
resulting shell diff and remove only a redundant version-specific entry. Preserve
the user-owned standalone block and all unrelated shell configuration.

Atomically switch `~/.local/bin/codebase-memory-mcp` to the verified installed
executable. Confirm that the installed updater and notices belong to the same
release. Keep the generic updater filename inside its application directory.
Preserve one Codex registration with the same canonical cache and allowed root.

Do not run an in-place update from an ordinary coding session. The `update`
command points to the installation script; running that script performs the
maintenance transaction. Do not assume a package manager owns this installation.

### Accept or roll back

First qualify a small repository. Confirm a fresh MCP version and tool listing,
a known symbol and call relationship against source, a source snippet,
architecture output, and exact-path coverage. In a disposable Git repository,
confirm that a controlled source edit and its restoration both reach the graph.
Delete only the disposable project's index afterward.

If release notes require rebuilding existing graphs, process the known roots
individually and record completion, generation, duration, resource problems, and
parser gaps. Check previously partial or unusable files explicitly. Count changes
alone do not establish improvement or regression. Recheck Codex after a fresh
connection, verify skill discovery, and compare unrelated configuration and hooks
with the backup.

For rollback, close the new frontends and daemon, switch the executable and Codex
entry back, and restore the previous cache as a unit. Do not open upgraded indexes
with an older binary. Restore Headroom's integration only as an explicit rollback
choice; do not enable both installations concurrently. Verify an old-version
handshake and a source-backed query before declaring recovery complete.

### Retention and removal

Retain the preceding release and its matching cache backup until the new release
passes native MCP checks and a fresh Codex session, then through at least one
normal development cycle. Review backup retention at the next maintenance event.
Delete old caches and binaries deliberately, after confirming which executable
the launcher selects; do not prune active SQLite files or private logs by name
pattern alone.

To remove standalone CBM, disable its Codex entry first and disconnect its
frontends. Remove only the owned personal skill, standalone shell blocks, launcher
symlink, and inactive release directories. Preserve graph caches by default.
Re-enabling Headroom is a separate integration decision. Upstream's broad
uninstaller does not define ownership of this manually adapted configuration.

## Sources

- [Upstream v0.12.1 release and rebuild requirement](https://github.com/DeusData/codebase-memory-mcp/releases/tag/v0.12.1)
- [Tagged installer](https://github.com/DeusData/codebase-memory-mcp/blob/v0.12.1/install.sh)
- [Tagged runtime configuration](https://github.com/DeusData/codebase-memory-mcp/blob/v0.12.1/docs/CONFIGURATION.md)
- [Tagged Codex integration and skill](https://github.com/DeusData/codebase-memory-mcp/blob/v0.12.1/src/cli/cli.c)
- [Official Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)
