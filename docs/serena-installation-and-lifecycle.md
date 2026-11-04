# Serena installation, repository onboarding, and lifecycle

Serena supplies language-server-backed symbol navigation and editing to Codex.
Use vexp for initial orientation, Codebase Memory for unresolved structural
questions, and Serena for targeted symbol reads, references, and edits.

## Installed state

On November 3, 2026, the owner authorized the upstream upgrade. uv installed
`serena-agent==2.1.0` with Python 3.13.16 into its separate tool environment.
GitHub and PyPI were checked again immediately before installation; both still
identified 2.1.0 as latest stable. Headroom's 1.7.0 environment was retained.

| Component | Current selection |
| --- | --- |
| Serena executable | `$HOME/.local/bin/serena`, supplied by uv's `serena-agent` tool |
| Environment | `$HOME/.local/share/uv/tools/serena-agent` |
| Codex registration | Existing `serena` entry in `$HOME/.codex/config.toml`; context `codex`, interface `REPL` |
| Timeouts | `startup_timeout_sec = 60`, `tool_timeout_sec = 180` |
| Python runner | Existing explicit `UVX=/home/aaron/.local/bin/uvx` retained |
| Agent rules | User-owned Serena block in `$HOME/.codex/AGENTS.md` and workspace `/home/aaron/code/AGENTS.md` |
| Recovery material | Private `$HOME/.local/share/serena-maintenance/20261103-upgrade-3676879e` |

The backup contains 95 files, including all 11 working repositories' project
configurations and 70 memory files, the parent/worktree registrations, Codex
configuration and hooks, agent instructions, and Headroom ownership records.
Logs and protocol evidence stay in that private directory, outside Git.

A fresh MCP client using the saved Codex registration established a 2.1.0
session exposing `activate_project`, `initial_instructions`, and `serena_repl`.
All 11 working repositories activated, reported ready language servers, and
recognized their existing 70 memories. No onboarding was repeated.

Representative LSP tests passed for Bash, YAML, Markdown, Python, and PowerShell.
Overview and symbol-body lookup passed for the first four; PowerShell returned
the expected variable overview from an existing script. A separate Bash reference
query also returned references to a known function. This qualifies those operations,
not every source file, language-server feature, or cross-file reference.

All 70 memory files remained byte-for-byte unchanged. Serena migrated 14
registered `project.yml` files by adding `agent_interface: null`,
`included_apis: []`, and `excluded_apis: []`; all pre-existing project settings
and all four local override files were preserved. Global migration added API
settings, `auth_secret`, and `agent_interface: tools`, retaining the classic
interface for the existing configuration. The explicit Codex command-line
`--agent-interface REPL` overrides that global value. Existing registered paths,
trust settings, other MCP registrations, provider settings, and hooks were retained.

Existing Codex sessions keep their already-running MCP process. Restart or
reconnect Codex's Serena connection to load the new executable and tool schema.
Independent fresh-process qualification does not establish that an existing IDE
session has reconnected.

After the owner reloaded the IDE on November 3, its actual Serena MCP connection
reported 2.1.0, REPL, and the `codex` context. Startup selected the parent `code`
project; the agent activated `/home/aaron/code/homelab-docs` using its new Serena
session ID and confirmed ready Bash, YAML, and Markdown servers. Existing project
memories, symbol overview, function-body lookup, and a reference query succeeded
through that IDE connection. The Bash reference result included the expected
call sites plus same-name matches in another script, so it does not prove exact
cross-file reference binding. No source or memory edits were used in this test.

The initial post-reload hook check found no registered Serena hooks, and
`hooks.json` still matched its pre-upgrade checksum. The owner subsequently
authorized the two adapted reminders documented below. The upstream
`serena-hooks` executable remains installed but is not used by those reminders.

## Before migration

The November 3, 2026 inspection found:

| Component | Observed state |
| --- | --- |
| Headroom Desktop | Ubuntu package 0.9.55 |
| Serena | `serena-agent` 1.7.0, installed by pip in `$HOME/.local/share/Headroom/headroom/serena-venv` |
| Python | Managed environment uses Python 3.12 |
| Codex registration | `$HOME/.codex/config.toml`, server name `serena`, absolute managed `bin/serena` command |
| Launch arguments | `start-mcp-server --project-from-cwd --context codex --open-web-dashboard False` |
| Language-server runner | Registration sets `UVX=/home/aaron/.local/bin/uvx`; standalone uv/uvx 0.12.23 |
| Bundled uv | Not installed in the existing Serena environment |
| Headroom receipt | `$HOME/.local/share/Headroom/headroom/tools/serena.json`: enabled, version 1.7.0 |
| Global configuration | `$HOME/.serena/serena_config.yml`; registered projects and language-server settings |
| Repository configuration | `.serena/project.yml`; homelab-docs selects `bash`, `yaml`, and `markdown` |
| Project data | `.serena` under each repository; includes memories and generated caches |

This installation is upstream Serena with Headroom-managed integration, rather
than a modified Serena fork. All 205 installed files under `serena/` and
`solidlsp/` matched the official PyPI 1.7.0 wheel byte for byte, with no missing
or additional non-bytecode files. All 222 hashed installed RECORD entries also
matched. No direct-URL/editable-install metadata was present. This comparison
covers Serena's package files, not every third-party dependency or live process.

The reference wheel's SHA-256 was
`6dbf1459670d96fb0595f84932adef34260a6fe14ba5135b901fdb3c8c76e891`,
verified against PyPI metadata before comparison.

GitHub's latest-release API and PyPI both identified **2.1.0** as latest stable,
published October 19, 2026. The 2.1.0 package accepts Python `>=3.11,<3.15`;
the upstream installation guide selects Python 3.13. The reference 2.1.0 wheel
matched PyPI SHA-256
`cc6ae542c39b4de5d98cdf35a4ceb0b551f316c5f22e9d0f0b0c5f35d6b95d87`.
Recheck releases at each upgrade; these are dated observations.

The initial inspection downloaded reference artifacts into `/tmp` and compared
source and metadata. The later authorized upgrade is recorded above. The earlier 1.7.0
Python symbol-query qualification is recorded in the
[development tool inventory](development-tool-stack.md#serena-installation-and-wsl-ipv4-workaround).

## Ownership and update choice

Headroom Desktop's tagged 0.9.55 installer source still pins Linux Serena to
1.7.0 and bundled uv to 0.12.23. Its install/update path retires the old
environment, creates a clean environment, installs those pins, runs `--help`,
refreshes registration, and applies dashboard/global Git-ignore integration.
An Update action can therefore repair the missing bundled uvx while retaining
Serena 1.7.0. It does not provide upstream 2.1.0.

For latest stable, use a separate user-owned uv tool installation and switch
the existing Codex registration after qualification. Retain Headroom's managed
environment as a rollback target. Installing packages directly into that
environment creates drift that a Headroom update can replace.

Headroom's registration helper uses an ownership ledger: it force-replaces or
removes an entry only when the current command, arguments, and environment
match a recorded Headroom installation. A changed user-owned registration is
intended to be preserved. This is source-level evidence from tag 0.9.55, not a
live regeneration test. Check the registration after Headroom updates, addon
toggles, or repair; a GUI receipt alone does not identify Codex's selected server.

## Prepare and install a standalone release

Run installation from a normal WSL terminal with network access and permission
to write the user tool/configuration directories. The November 3 installation
used the pinned uv command below and a targeted Codex configuration update.

1. Close clients using Serena before changing shared configuration. Create a
   private dated backup outside Git of Codex `config.toml`, global
   `serena_config.yml`, the Headroom receipt and MCP ownership ledger, and each
   repository's `.serena/project.yml`, optional `project.local.yml`, and memories.
   Record the original command, arguments, environment, and managed package version.
   Treat backups as private: configuration can contain authentication material.
2. Review the selected release notes. Inspect `uv tool list` and
   `uv tool dir --bin`, and check for existing `serena`, `serena-agent`, and
   `serena-hooks` executables before installing. Resolve any ownership conflict;
   do not use `--force` to overwrite an unrelated installation.
3. Install the reviewed release into uv's separate tool environment:

   ```bash
   "$HOME/.local/bin/uv" tool install --python 3.13 'serena-agent==2.1.0'
   "$HOME/.local/bin/uv" tool dir --bin
   "$HOME/.local/bin/serena" --help
   "$HOME/.local/bin/serena" start-mcp-server --help
   ```

   uv can provision Python 3.13 if needed. The commands below assume the tool
   executable directory is `$HOME/.local/bin`; substitute the actual output if
   it differs. The managed Headroom path remains separate.
4. Review the configuration changes introduced by v2 before its first launch.
   Adopt its `REPL` interface together with the agent instructions described
   below. Use `--agent-interface tools` only for a temporary compatibility
   session or rollback investigation. v2 can also generate and persist
   `auth_secret` in the global configuration.
5. Review `trusted_project_path_patterns`: the existing configuration trusts
   `**`, while new v2 configurations default to trusting no projects. Carrying
   the existing file forward retains broad trust. Choose explicit repository
   paths if narrowing this setting; do not silently change it during upgrade.
   Trust affects activation commands, language-server overrides, project-local
   TypeScript loading, and symlink handling. Compare the saved global and
   project configuration after first use.

The existing environment already has global configuration. Avoid running broad
setup/registration generators over Codex's configuration. For a genuinely new
installation, upstream documents `serena init` to initialize the LSP backend;
review its effects before running it.

## Codex registration and acceptance

### Agent instructions

The upgrade updated the global user-owned Serena instructions and the workspace
rules in `/home/aaron/code/AGENTS.md`. Sessions exposing `serena_repl` prefer it;
an older connection or an explicitly selected compatibility session can still
use individual tools. Repository agent/instruction files were searched for
Serena-specific rules; no other conflicting rules were found in working repos.

The rules preserve vexp-first discovery, Codebase Memory follow-up, repository
activation, readiness checks, and required validation. Their v2 additions are:

- Read `initial_instructions` and retain its session identifier. In 2.1.0 the
  argument is `session`, including for `activate_project` and `serena_repl`.
- Request facade documentation with `s.info` before using its operations;
  use `s.cfg.get_current_config()` for configuration and `s.lsp` for symbols.
- Return bounded results as the cell's final expression rather than using
  `print`; keep useful intermediate results inside the REPL.
- Apply the task's read/write scope to REPL code, which executes with the
  Serena process's permissions. Tool/API inclusion lists are steering settings,
  not an operating-system sandbox.

Review any repository-specific instructions that hard-code individual tool
names before onboarding that repository to REPL. Rollback sessions must use the
interface exposed by their older server. Do not paste a future-only instruction
block over the working 1.7.0 rules.

### Registration

Edit only the existing Serena table in `$HOME/.codex/config.toml`, preserving
the other servers, hooks, model-provider settings, and unrelated Serena options.
The installed registration for this user's default uv executable directory is:

```toml
[mcp_servers.serena]
command = "/home/aaron/.local/bin/serena"
args = ["start-mcp-server", "--project-from-cwd", "--context", "codex", "--agent-interface", "REPL", "--open-web-dashboard", "False"]
startup_timeout_sec = 60
tool_timeout_sec = 180

[mcp_servers.serena.env]
UVX = "/home/aaron/.local/bin/uvx"
```

Keep the server name `serena`; a second parallel registration creates duplicate
tools. Keep `UVX` explicit for Python language servers rather than depending on
the IDE's inherited PATH. The dashboard flag prevents automatic browser opening;
it does not disable the dashboard server.

Official OpenAI documentation identifies `config.toml` as shared by Codex's
CLI and IDE extension. Serena's separate VS Code instructions describe the
Copilot MCP client and use `--context=vscode`; they are not the configuration
for Codex running inside VS Code. Per-client registration and per-session project
activation do not replace or invalidate stored repository onboarding.

### Optional hooks

After the upgrade, the owner authorized two user-maintained Serena reminders.
They were appended to `$HOME/.codex/hooks.json`, preserving the existing
GitKraken, Headroom route-guard, and RTK definitions and existing trust records.
The helper is installed at `$HOME/.codex/hooks/serena-codex-hooks.py`; its source
is [scripts/serena-codex-hooks.py](../scripts/serena-codex-hooks.py).
It uses only the system Python standard library and does not import or patch
Serena, start MCP processes, inspect repositories, or write session state.

| Event | Matcher | Helper action | Behavior |
| --- | --- | --- | --- |
| `SessionStart` | `startup\|resume\|clear\|compact` | `activate` | Reminds the agent to preserve discovery order, obtain the Serena session ID before activation, select the actual repository, check readiness, and retain onboarding |
| `UserPromptSubmit` | All prompts | `plan-context` | Emits guidance only when `permission_mode` is exactly `plan`; permits read-only REPL analysis and prohibits edits, memory writes, configuration changes, refactors, and mutating commands |

Both definitions invoke `/usr/bin/python3` and the helper's absolute path, with
an explicit five-second timeout. They return only event-specific
`hookSpecificOutput.additionalContext`. They never emit an allow/deny decision,
change permissions, or enforce a read-only sandbox. They do not echo untrusted
prompt or CWD strings into the reminder. Malformed or mismatched events produce
no output and exit successfully, so a guidance hook does not block normal work.

No reminder-counter, reset, plan-guard, auto-approval, or cleanup hooks were added.
The two installed reminders are stateless, so they need no cleanup event. The
global user-owned Serena instructions explain their advisory behavior.

The installation backup is private:
`$HOME/.local/share/serena-maintenance/20261103-hooks-bcb8e1d4`. It contains the
prior hook file, global agent instructions, Codex configuration, and the
installation result with the helper's checksum.

#### Install or reinstall the adapted hooks

Run these steps in an ordinary WSL terminal. This installs the local helper;
it does not run `serena setup codex` or install the upstream hook bundle.
The documented installation is user-global, so do not duplicate the definitions
in each repository's `.codex/hooks.json`.

First test the repository source, create a private backup, and copy the helper.
The subshell stops if a test, backup, or installation command fails:

```bash
(
    set -eu
    cd /home/aaron/code/homelab-docs
    python3 -B -m unittest discover -s scripts/tests -p test_serena_codex_hooks.py

    umask 077
    mkdir -p "$HOME/.local/share/serena-maintenance"
    serena_hooks_backup="$(mktemp -d "$HOME/.local/share/serena-maintenance/hooks-XXXXXXXX")"
    cp -p "$HOME/.codex/hooks.json" "$HOME/.codex/AGENTS.md" \
        "$HOME/.codex/config.toml" "$serena_hooks_backup/"
    if [ -f "$HOME/.codex/hooks/serena-codex-hooks.py" ]; then
        cp -p "$HOME/.codex/hooks/serena-codex-hooks.py" "$serena_hooks_backup/"
    fi
    mkdir -p "$HOME/.codex/hooks"
    install -m 600 scripts/serena-codex-hooks.py \
        "$HOME/.codex/hooks/serena-codex-hooks.py"
    cmp scripts/serena-codex-hooks.py "$HOME/.codex/hooks/serena-codex-hooks.py"
    printf 'Backup: %s\n' "$serena_hooks_backup"
)
```

After the tests succeed, edit `$HOME/.codex/hooks.json` to merge the following
two definitions into its existing `hooks` object. Each event contains an array
of groups, and each group contains a `hooks` array. Append one group to each
listed event. If a matching helper/action is already registered, review that
entry instead of appending a duplicate.

| Setting | Startup reminder | Plan-mode reminder |
| --- | --- | --- |
| Event array | `hooks.SessionStart` | `hooks.UserPromptSubmit` |
| Group `matcher` | `startup\|resume\|clear\|compact` | Omit; inspect all prompt events |
| Hook `type` | `command` | `command` |
| Hook `command` | `/usr/bin/python3 /home/aaron/.codex/hooks/serena-codex-hooks.py activate` | `/usr/bin/python3 /home/aaron/.codex/hooks/serena-codex-hooks.py plan-context` |
| Hook `timeout` | `5` | `5` |
| Hook `statusMessage` | `Serena project reminder` | `Serena read-only plan reminder` |

These paths match this user's installation. For another account, substitute its
absolute helper path; do not place an unexpanded `$HOME` placeholder in a JSON
command. Retain every unrelated event, group, hook, and its existing order.
Validate the edited JSON with `python3 -m json.tool "$HOME/.codex/hooks.json"`
and compare it with the backup to confirm that only the intended entries changed.

Retain the Serena session, repository selection, onboarding-preservation, and
read-only rules in the global user-owned `user:serena` block of
`$HOME/.codex/AGENTS.md` and the workspace rules in `/home/aaron/code/AGENTS.md`.
The global block also records that the hooks supply reminders without activating
projects, enforcing permissions, or changing the discovery order. Keep that note
when installing the helper in another configuration.

Review and trust the two definitions as described below, then verify a fresh
startup/resume and a plan-mode prompt. Installing the file and passing tests
alone does not establish that the IDE has invoked either hook.

#### Trust and qualification

Use Codex's `/hooks` review interface to inspect and trust the two new hook
definitions before relying on them. Newly added definitions require review;
existing trust records were not rewritten or synthesized by the installer.
For clients without that interface, use their hook review/trust UI. The helper
and registrations are installed; actual IDE hook execution remains pending
trust and the next matching lifecycle event.

Six subprocess contract tests cover startup/resume context, instruction ordering,
plan-only output, non-plan silence, malformed/wrong-event handling, rejection of
unknown actions, and exclusion of untrusted payload text. Run them with:

```bash
python3 -B -m unittest discover -s scripts/tests -p test_serena_codex_hooks.py
```

The tests validate stdin/stdout JSON behavior and successful exits within the
configured timeout. They do not establish that Codex has trusted or invoked a
hook. After trust, inspect a fresh startup/resume and a plan-mode prompt to
confirm that Codex injects the corresponding reminder. Keep vexp-first discovery
and the existing repository checks in place.

#### Maintenance and removal

Before updating the helper or registrations, back up the installed helper,
`hooks.json`, and the user-owned agent instruction block. Review source changes,
run the contract tests, install the reviewed helper, and compare its checksum
with the repository source. Review changed hook definitions again in Codex.
Do not replace the complete hook file with the upstream example or a backup
without comparing intervening changes.

To disable or remove this integration, remove only the two entries whose commands
invoke `serena-codex-hooks.py`, then remove the helper and its explanatory agent
instruction bullet if no longer used. Preserve the other hooks, their order and
trust state, and the Serena MCP registration. No session data needs cleanup.

#### Adaptations from the upstream hooks

The local helper deliberately changes these Serena 2.1.0 behaviors:

- The activation hook asks the agent to activate a project before reading the
  manual and to do so before other work. In v2, `initial_instructions` supplies
  the `session` ID needed for activation. Read it first and retain this workspace's
  vexp-first discovery order. The local reminder specifies that order, requires
  the actual repository rather than the parent workspace, and retains readiness
  and onboarding checks without repeating them on every call.
- The upstream plan-context wording prohibits edit-capable tools. The local
  reminder explicitly permits read-only REPL queries while prohibiting repository
  edits, memory writes, configuration changes, refactors, and mutating commands.
  It returns guidance only for a `UserPromptSubmit` event with
  `permission_mode: plan`; other modes produce no output.
- The reminder hook nudges agents away from repeated shell searches/reads. It
  can conflict with intentional vexp/Codebase Memory work and required direct
  configuration reads. Review its policy before enabling it here.
- The plan guard classifies `serena_repl` as edit-capable and denies it in plan
  mode, including cells that only read symbols. It does not inspect each cell
  for read-only intent. Preserve read-only task boundaries through instructions
  and actual execution permissions; do not describe API inclusion lists as a sandbox.
- Upstream reminder counters need reset/cleanup integration. The local helper
  retains no counters or session files, so neither hook requires cleanup.
- For an optional hook pilot, use absolute `serena-hooks` paths, short explicit
  timeouts, and one cleanup event. Upstream documents `SessionEnd` for Codex
  0.145.0 or newer; do not also register cleanup on `Stop`.

These are source-level observations from the installed upstream package. The
local helper adapts activation and plan guidance; it does not enable that package's
hook implementation. MCP protocol qualification and synthetic helper tests are
separate from real Codex lifecycle execution.

Restart the Codex/MCP session after the change. Acceptance requires:

1. Confirm the fresh process uses the standalone executable and package 2.1.0.
2. Read Serena's `initial_instructions`, retaining its session identifier.
   Confirm `serena_repl` is exposed, use it to request `s.info("cfg", "lsp")`,
   then inspect `s.cfg.get_current_config()`.
   Confirm the active project corresponds to the intended repository's absolute
   root. If needed, call `activate_project` with that root, then check the
   configuration again through the REPL and require language-server status `ready`.
   Pass the session identifier as `session` when activating the project.
3. Use `s.lsp.get_symbols_overview` on a supported source file, then `s.lsp.find_symbol`
   for a known symbol with its body included. Exercise references where the
   repository has a known cross-file example. An empty references result alone
   does not establish a failure or successful cross-file resolution. Follow
   `s.info` for signatures and return the result as the cell's final expression.
4. Repeat on representative language backends actually used by the workspace.
   A Python success does not qualify Bash, YAML, or Markdown. Inspect configuration
   diffs and confirm other MCP servers and Headroom model routing remain selected.

`--help`, package metadata, and an enabled receipt are preliminary checks. They
do not establish that the restarted client exposes the expected tool schema or
that a language server can answer real queries.

## Repository onboarding

Treat each repository as a project. Do not index the whole `$HOME/code` parent
merely because the MCP server started there. Existing parent-level project
configuration makes checking the activated root especially important.

For a new repository, inspect its languages and exclusions before creation:

```bash
cd /home/aaron/code/REPOSITORY
"$HOME/.local/bin/serena" project create .
# Review .serena/project.yml, then populate the language-server symbol cache.
"$HOME/.local/bin/serena" project index .
```

Creation detects languages; repeated `--language` options can select explicit
backends when needed. Review `language_servers`, ignored paths, generated/vendor
directories, and any activation commands or language-server overrides. Install
the prerequisites for each backend. Python uses the configured uvx runner for
Pyright; other languages have different requirements.

For an existing `.serena/project.yml`, preserve it and its memories. Do not run
`project create` again: it rejects an existing project. Review configuration and
use `project index .` when a cache refresh is needed. That command can create
configuration if none exists, so confirm the current directory first.

Project creation/indexing and agent onboarding are separate. In the MCP session,
confirm the repository and readiness. For REPL, request `s.info("mem")`, then
use `s.mem.list_memories()` to recognize existing onboarding. Call
`s.mem.onboarding()` only when onboarding is actually needed;
in compatibility sessions these are the `check_onboarding_performed` and
`onboarding` tools. Follow the prompt to record durable repository
structure, conventions, and build/test commands. Existing memories normally mark
onboarding as complete; review stale memories instead of deleting them to force
onboarding. Exclude secrets and transient incident evidence from memories.

Check `git status --short --untracked-files=all` and
`git check-ignore -v .serena/project.yml` before deciding whether to commit project
configuration or memories. Headroom manages a global `.serena` ignore, which can
hide files independently of repository `.gitignore`. Commit only deliberately
reviewed project metadata under repository policy; keep caches and logs local.

An optional CLI check is `serena project health-check .`. The 2.1.0 implementation
exercises overview, symbol lookup, and references and writes logs under
`.serena/logs/health-checks`. It can initialize backends, dependencies, caches,
and configuration; it is not a zero-write inspection. Review its log and exit
status, then still qualify the real restarted MCP session.

## Upgrade, rollback, and removal

For each upgrade, recheck the latest stable release and notes, back up configuration
and memories, and record the current uv tool requirement. The exact version pin
above is deliberate: `uv tool upgrade serena-agent` respects its stored constraint
and will not move beyond `==2.1.0`. Change the requirement explicitly using
`uv tool install --python 3.13 'serena-agent==REVIEWED_VERSION'`, then repeat
configuration review, restart, and functional acceptance. Upstream's plain
`uv tool upgrade serena-agent` applies when the installation's constraint allows
the newer version.

To roll back this migration, close active clients and restore only the
saved Serena registration pointing to Headroom's managed executable, including
its original arguments and `UVX`. Restore global/project configuration changed
by the new version after reviewing intervening changes. Preserve newer memories
for review rather than blindly overwriting them. Restart and repeat readiness
and symbol-query checks; changing the executable alone may leave migrated state.

To remove the standalone package, first remove its MCP registration or route it
back to the retained managed installation, then run:

```bash
"$HOME/.local/bin/uv" tool uninstall serena-agent
```

Keep shared configuration, project metadata, and memories unless their deletion
is separately intended. Manage Headroom's addon through Headroom; do not delete
its environment by hand. Recheck registration and global ignore state after
addon removal or repair. Leave the Headroom proxy/provider integration intact.

For the previously observed WSL PyPI IPv6 stall, use the diagnostic and rollback
procedure in the [tool inventory](development-tool-stack.md#serena-installation-and-wsl-ipv4-workaround).
The existing `/etc/gai.conf` workaround is host-wide and separate from Serena
version management; an upgrade is not a reason to change it.

## Sources

- [Latest GitHub release](https://github.com/oraios/serena/releases/latest)
  and [PyPI metadata](https://pypi.org/pypi/serena-agent/json).
- [Version 2.1.0 change log](https://github.com/oraios/serena/blob/v2.1.0/CHANGELOG.md)
  and [CLI source](https://github.com/oraios/serena/blob/v2.1.0/src/serena/cli.py).
- [Installation](https://oraios.github.io/serena/02-usage/010_installation.html),
  [configuration](https://oraios.github.io/serena/02-usage/050_configuration.html),
  [project workflow](https://oraios.github.io/serena/02-usage/040_workflow.html),
  and [memories](https://oraios.github.io/serena/02-usage/045_memories.html).
- [Headroom Desktop 0.9.55 tool manager](https://github.com/gglucass/headroom-desktop/blob/v0.9.55/src-tauri/src/tool_manager.rs):
  `serena_pinned_version`, `install_serena`, and `SERENA_MCP_HELPER`.
- [uv tool lifecycle](https://docs.astral.sh/uv/concepts/tools/).
- [Serena client configuration](https://oraios.github.io/serena/02-usage/030_clients.html)
  and [official OpenAI MCP configuration](https://developers.openai.com/codex/mcp/).
- [Official OpenAI hook configuration and trust](https://learn.chatgpt.com/docs/hooks).
