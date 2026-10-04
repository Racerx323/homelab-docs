# ExtraHeadroom in Ubuntu WSL2

This guide covers ExtraHeadroom Desktop and its managed Headroom CLI in the
Windows 11 and Ubuntu WSL2 environment recorded in
[Development Tool Stack](development-tool-stack.md).

Verification date: October 4, 2026. The owner confirmed that Ubuntu Headroom
should serve OpenAI Codex CLI, invoked as `codex`, and WSL VS Code/Codex, while
Windows Headroom should serve the native Windows ChatGPT app in Codex mode
independently. The owner reports
using these installations together. Simultaneous operation and request routing
through both installations were not independently qualified by this investigation.

The checks for this guide were read-only. No software was installed or updated,
no settings were changed, no application was started or stopped, and no dedicated
model test was sent. Ordinary requests during the investigation were not an
isolated routing experiment. Evidence below excludes credentials, private
prompts, response content, and raw runtime logs.

## Evidence and limits

**Observed** means inspected locally during this investigation.
**Documented** means stated by the linked vendor documentation, without a local
behavior test. **Recommended** means an operating practice for the confirmed
arrangement, rather than a completed configuration change.

### Verified installation and runtime inventory

| Component | Observed version or state | Evidence |
| --- | --- | --- |
| Windows | Windows 11, build 26340 | Owner context; Windows OS version query |
| Ubuntu | 24.04.5 LTS | `/etc/os-release` |
| WSL | 2.9.13.0; WSLg 1.0.79 | Windows `wsl.exe --version` |
| Running Ubuntu kernel | `6.18.40.1-microsoft-standard-WSL2` | Kernel release query |
| Ubuntu ExtraHeadroom Desktop | 0.9.32, package `headroom` | Installed Debian package metadata |
| Windows ExtraHeadroom Desktop | 0.9.32 | Windows per-user uninstall registry metadata |
| Ubuntu and Windows managed Headroom engine/CLI | 0.39.0 | Each managed Python environment's package metadata; Ubuntu health responses agree |
| WSL Codex extension | `openai.chatgpt` 26.930.41038 | Installed extension manifest |
| WSL Codex app-server | 0.160.0 release location | Running executable paths; not a new CLI session |
| Ubuntu Headroom | Desktop and worker running | Host process and listener inspection |
| Windows Headroom | No running Headroom process or listener on 6767–6769 found | Windows process and TCP listener inspection |

These are installed or running observations, not claims that the versions are
the newest releases. The Linux package version and running engine version were
checked separately. The Windows installer signature and release provenance were
not verified in this investigation.

### Locations and configuration ownership

| Purpose | Ubuntu | Windows |
| --- | --- | --- |
| Desktop executable | `/usr/bin/headroom-desktop` | Installation directory `%LOCALAPPDATA%\Headroom` |
| Desktop configuration/state | `$HOME/.local/share/Headroom/config` | `%LOCALAPPDATA%\Headroom\config` |
| Managed runtime | `$HOME/.local/share/Headroom/headroom/runtime/venv` | `%LOCALAPPDATA%\Headroom\headroom\runtime\venv` |
| Managed CLI | Runtime `bin/headroom` | Runtime `Scripts\headroom.exe` |
| Managed auxiliary binaries | `$HOME/.local/share/Headroom/headroom/bin` | Headroom-managed tools directory; individual Windows tools not inventoried here |
| Engine state and metrics | `$HOME/.headroom` | Windows engine state not inventoried here |
| Codex user configuration | `$HOME/.codex/config.toml` for the WSL VS Code backend | `%USERPROFILE%\.codex\config.toml` for the observed Windows-home client |

The bootstrap receipts in both installations identify Headroom as the manager
and the runtime as self-contained. Bare `headroom` was absent from the audited
Ubuntu shell PATH; its managed executable exists at the path above. Auxiliary
tools on PATH do not establish that the Headroom CLI itself is on PATH.

Ubuntu's `client-setup.json` records `codex_cli` as configured and remembered,
with setup version 0.9.32 and managed shell files `.bashrc` and `.profile`.
Windows records a remembered `codex_cli` client but no currently configured
client. Its Codex configuration selects no Headroom provider. These are setup
records and configuration observations; the application's connector UI was not
inspected, and a setup record alone does not establish routed traffic.

**Recommended:** let each desktop installation manage its own runtime, connector
blocks, and backups. Do not share the runtime or point the WSL VS Code backend
at the Windows-home configuration merely because both apps are installed.

## Install and update

The [official quickstart](https://www.extraheadroom.com/docs/quickstart) and
[agent runbook](https://www.extraheadroom.com/docs/for-agents) document these
methods. They are instructions for a future maintenance action; none was
executed for this guide.

- **Windows desktop:** download the Windows x64 setup executable from the
  official download page, run the installer, and open Headroom. This is the
  owner's reported installation method; registry metadata confirms an installed
  per-user app.
- **Ubuntu desktop:** download and install the Linux x86_64 `.deb` using Ubuntu's
  package manager. The installed package here is `headroom`, and its launcher is
  named **Headroom**. The vendor also offers an AppImage; this environment uses
  the `.deb`.
- **First launch:** complete the user's Headroom sign-in, allow managed runtime
  and model downloads to finish, and enable the intended Codex connector. The
  desktop installation does not install or sign in to Codex for the user.

The Linux build documents glibc 2.39 or newer, a graphical session, and a running
secret-service keyring for sign-in. This Ubuntu host has graphical-session
environment variables and a running `gnome-keyring-daemon`. Those observations
do not test credential storage or a fresh sign-in.

The [official update guide](https://www.extraheadroom.com/docs/update) says to
open **Settings > Check for updates** on Windows and Linux, install an offered
update, and restart the app. For the `.deb` installation, downloading a newer
official `.deb` and installing it over the existing package is also documented;
settings and savings history are retained. No Headroom APT repository or
unattended package update mechanism was established here. Check the installed
app's update result rather than assuming an AppImage update mechanism applies
to the `.deb`.

The desktop updates its engine and enabled add-ons itself. **Recommended:**
update the desktop-managed CLI through the desktop's update path. Do not run
`pip install -U headroom-ai` or `headroom update` inside its managed environment
as a substitute. The vendor's pip update instructions apply to a separately
installed open-source CLI in its own Python environment, not this installation.

For a version check, use **Settings > Tools status**, installed package metadata,
or the managed CLI's documented version option:

```bash
dpkg-query -W -f='${Package} ${Version}\n' headroom
"$HOME/.local/share/Headroom/headroom/runtime/venv/bin/headroom" --version
```

The CLI version command was not run here; package metadata supplied the runtime
version. Its installed command source confirms `--version` exists. Other CLI
commands can initialize settings or perform update checks, so they should not
be treated as universally read-only diagnostics.

## Start, stop, and use the Ubuntu app

**Observed:** the package installs `/usr/share/applications/Headroom.desktop`
with `Exec=headroom-desktop`. The running desktop owns `127.0.0.1:6767`; its
managed worker owns `127.0.0.1:6768`. Both `/health` and `/readyz` endpoints returned
HTTP 200 with `ready: true` and engine version 0.39.0.

For a future start, choose the installed Ubuntu **Headroom** application launcher
or run this from a graphical Ubuntu terminal:

```bash
headroom-desktop
```

Start it once, finish setup, and confirm readiness before using the WSL Codex
extension. Do not launch `headroom proxy` alongside the desktop: that would
start a separate proxy rather than the desktop-managed service observed here.

Use the app's normal **Quit** control to stop it. Use its documented tray
**Pause Headroom / Resume Headroom** controls for temporary pause/resume, where
available in the installed UI. These controls were not exercised here. Closing
the main window is not evidence that the tray app or proxy has stopped; check
the owning process and listeners.

After connector setup or routing changes, open a fresh Ubuntu terminal and
restart the relevant Codex session. The vendor's compatibility guide also
recommends restarting the editor so extensions pick up changed settings. Do
this during an appropriate interruption window, not while a task is active.

[Microsoft's WSL GUI guidance](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps)
supports Linux GUI applications under WSL2 but explicitly does not provide a
full Linux desktop experience. A launcher appearing in Windows is not evidence
of a functioning Linux tray or secret-service integration. No Headroom-specific
autostart entry was found in Ubuntu's user autostart or systemd directories;
other startup mechanisms were not exhaustively checked.

## How WSL VS Code Codex finds its configuration

[OpenAI's configuration documentation](https://developers.openai.com/codex/config-basic)
says the CLI and IDE extension share configuration layers. The extension's gear
menu exposes **Codex Settings > Open config.toml**. Codex normally uses
`$HOME/.codex`; `CODEX_HOME`, when supplied to its backend, selects a different
state/configuration directory.

**Observed:** the WSL extension's app-server runs from the Linux extension
directory, has `HOME=/home/aaron`, has no `CODEX_HOME` override, and inherited
`OPENAI_BASE_URL=http://127.0.0.1:6767/v1`. Its user configuration is therefore
`/home/aaron/.codex/config.toml`. The inspected workspace and `homelab-docs`
directories had no project `config.toml`.

Codex also loads applicable system, profile, runtime, and trusted project
configuration. Current OpenAI documentation describes runtime overrides and
trusted project layers as higher precedence than user defaults. User/global
configuration and hooks can still load when a project is untrusted. Diagnose
the effective client configuration, not just a repository file or the shell
from which a diagnostic command happens to run.

Another observed Windows-home Codex app-server runs inside WSL but has
`CODEX_HOME=/mnt/c/Users/aaron/.codex`. It therefore uses Windows-home state even
though the executable runs in Linux. Its configuration and routing must be
examined separately from the WSL VS Code extension.

### Provider, exports, guard registration, and trust

The following is a sanitized excerpt of the **observed Ubuntu user
configuration**, not a replacement file or an instruction to paste it:

```toml
model_provider = "headroom"
openai_base_url = "http://127.0.0.1:6767/v1"

[model_providers.headroom]
name = "Headroom persistent proxy"
base_url = "http://127.0.0.1:6767/v1"
requires_openai_auth = true
supports_websockets = false
```

Headroom owns marked connector blocks in that file. The installed block does
not explicitly set `wire_api`; do not add settings copied from a different
release without checking the installed connector and
[OpenAI's provider documentation](https://developers.openai.com/codex/config-advanced).
No provider credentials are needed in this documentation.

**Observed shell behavior:** matching Headroom-managed blocks in `.bashrc` and
`.profile` check TCP availability on 6767. They conditionally export the proxy
`OPENAI_BASE_URL`, preserve another existing base URL, and register a `codex`
shell function when no alias/function already exists. That wrapper removes the
Headroom environment variable for a CLI invocation if the listener is down.
It does not edit the persistent provider or update an already-running VS Code
backend's environment. Unsetting a shell variable alone is not a verified
bypass of the persistent provider.

The Ubuntu guard is registered once in `$HOME/.codex/hooks.json` as a command
`SessionStart` hook for `startup|resume|clear|compact`. Its command invokes
`/usr/bin/python3 $HOME/.codex/hooks/headroom-codex-guard.py`, with a ten-second
timeout. A trust-hash entry for that hook source exists in user configuration.
A saved verdict dated October 4 at 16:45:41 CDT contains no issues. Neither the
trust entry nor that saved verdict proves invocation in every IDE task.

[OpenAI's hook documentation](https://developers.openai.com/codex/hooks) says
hooks from active layers load together, and non-managed hooks require review
and trust of their current definition. Review Headroom's hook using `/hooks`
in the intended Codex CLI; changed definitions need review again. A hook
described as “managed by Headroom” is not thereby an OpenAI policy-managed hook
exempt from trust review. Do not duplicate it in each repository or bypass
trust to make a warning disappear.

The installed guard source checks the user provider URL and TCP connectivity,
records a verdict, and returns zero even when it finds issues. It reports
problems; it does not repair routing, enforce a route, or prove a successful
model request. Its notification helper attempts a macOS-specific command and
ignores errors; Linux desktop notifications were not demonstrated. Automatic
guard execution in a fresh IDE session was not independently requalified here.

## Windows Headroom and WSL networking

**Observed:** Windows `.wslconfig` requests `networkingMode=Mirrored`, with
`hostAddressLoopback=true` and `bestEffortDnsParsing=true` under its experimental
section. A host-visible `wslinfo --networking-mode` query returned `mirrored`.
No WSL networking setting was changed.

[Microsoft's networking documentation](https://learn.microsoft.com/en-us/windows/wsl/networking)
distinguishes NAT from mirrored networking. Mirrored mode permits Linux-to-
Windows localhost connections. Thus `127.0.0.1:6767` does not, by itself,
identify which installation receives a request. Inspect listener ownership on
both systems and correlate requests at the intended proxy.

The owner's intended independent roles do not establish that two proxies can
bind the same ports concurrently or that a WSL-backed Windows client reaches
the Windows app. At this observation, only Ubuntu had Headroom listeners.
Concurrent startup order, port behavior, and routing have not been tested.

**Owner-confirmed scope:** Windows Headroom is for the native Windows ChatGPT
app in Codex mode. Ubuntu Headroom serves OpenAI Codex CLI (`codex`) and the
Codex extension in WSL VS Code.
The WSL-backed Windows-home Codex process is outside the recommended Windows
setup. Its observed configuration does not establish the route of a backend
executing natively on Windows, and process ancestry did not establish which
desktop interface launched it. Do not treat its remembered connector record
as a currently enabled or verified Windows route. ChatGPT chat mode itself is not covered by
Headroom's Codex connector; the vendor's compatibility claim is for Codex mode,
the Codex CLI, and the Codex IDE extension.

## Verify readiness, routing, and savings separately

### 1. Proxy readiness

Run these from the intended client's environment. Listener inspection and
health probes do not send a model request:

```bash
ss -lntp 'sport = :6767 or sport = :6768'
curl --fail --silent --show-error --max-time 5 \
    http://127.0.0.1:6767/readyz | jq '{status, ready, version}'
```

In native Windows PowerShell, inspect Windows listener ownership separately:

```powershell
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in 6767, 6768 } |
    Select-Object LocalAddress, LocalPort, OwningProcess
```

Resolve an owning PID to its process before taking action. A healthy proxy is
ready to receive requests; it does not prove the client selected it.

### 2. Actual model routing

First confirm the target client's effective provider, configuration home, and
inherited environment. Then use a separately authorized fresh task that reads
non-sensitive project content or runs an existing test. Keep other clients idle
where practical, and note the test interval and client identity.

The [official runbook](https://www.extraheadroom.com/docs/for-agents) uses
`requests.total` before and after a request. This filtered command retains only
aggregate numeric metrics from the observed 0.39.0 endpoint:

```bash
curl --fail --silent --show-error --max-time 5 \
    http://127.0.0.1:6767/stats |
    jq '{requests_total: .requests.total,
         api_requests: .summary.api_requests,
         requests_compressed: .summary.compression.requests_compressed,
         tokens_removed: .summary.compression.total_tokens_removed}'
```

For native Windows PowerShell use `curl.exe`, not its `curl` alias. A counter
increase supports traffic during the interval, but concurrent sessions,
automatic review requests, or retries prevent attributing the whole delta to
one task. Confirm a matching provider-side completion and client usage metadata
when available. Preserve only times, client/provider identity, completion state,
and token counts; do not copy raw logs or message bodies into the guide.

**Current evidence:** existing worker completion metadata includes OpenAI-family
requests with nonzero output-token counts. This establishes existing proxy
traffic, without attributing those records to a particular fresh VS Code task.
No isolated new-task routing test was performed for this guide.

The toolstack retains an earlier October 4, 14:39:08 CDT controlled VS Code
observation with matching client and proxy input counts. That is historical
evidence, not a new qualification of the present session. MCP availability,
generated instructions, connector setup records, hook trust, TCP availability,
and health responses each answer different questions.

### 3. Measured savings

[Headroom's measurement guide](https://www.extraheadroom.com/docs/how-savings-are-measured)
distinguishes input removed, provider cache reads, output estimates, and
API-equivalent dollar values. A routed request can save zero tokens.

For a matched request with a token-removal basis, calculate:

```text
input reduction (%) = removed input tokens / pre-compression input tokens × 100
```

The historical toolstack sample removed 214 of 27,503 input tokens, approximately
0.78%, leaving 27,289. No comparable new per-request measurement was made here.
Current proxy aggregate savings are accumulated across requests and cannot be
assigned to this documentation task.

For dashboard periods, record the indicator's own baseline and units. The
documented new-input basis excludes re-sent cached prefixes; the fallback
billable-input basis uses API-equivalent dollars and excludes cache reads.
Output shaping can be estimated or measured depending on coverage, and has a
different baseline. Do not combine those percentages or infer subscription
billing reductions from token compression or API-equivalent dollars.

## What happens when Headroom exits

**Documented:** the
[compatibility guide](https://www.extraheadroom.com/docs/compatibility) says a
normal Quit restores connected agents' direct settings and the next launch
restores Headroom routing. From desktop version 0.9.29, it also documents
restoration after unexpected closure. Already-open agent sessions can retain
the proxy address and fail with `ECONNREFUSED`; start a new session afterward.
Manually configured tools are not automatically restored.

**Observed limits:** neither graceful nor unexpected exit was tested here.
The shell wrapper's environment fallback and the guard's success exit code
are not tests of desktop cleanup. After a future exit, inspect the effective
configuration and listener state, restart the affected client when appropriate,
and qualify the resulting route before relying on fallback.

Normal Quit retains runtime files and saved data. For removal, the
[uninstall guide](https://www.extraheadroom.com/docs/uninstall) documents the
app's **Settings > Uninstall Headroom** cleanup before Linux package removal.
Deleting the executable or clearing one environment variable is not equivalent
to that cleanup.

## Troubleshooting

Use [official troubleshooting](https://www.extraheadroom.com/docs/troubleshooting)
and the observations above to narrow the symptom before changing anything.

| Symptom | Evidence to inspect | Next step |
| --- | --- | --- |
| Bare `headroom` is not found | Managed executable location; PATH | Use the observed absolute managed path; do not install another runtime to solve PATH discovery |
| Connection refused | Owning process, listener, and readiness in the target environment | Confirm the intended desktop is running; after a documented exit, start a fresh client session with restored configuration |
| Port in use | Linux and Windows listener owners | Identify the duplicate or other application; do not terminate an unidentified process or assume both installations coexist |
| Ready proxy but no attributable requests | Effective Codex home/provider, runtime overrides, test interval | Test the intended client independently; MCP tools and health do not establish model routing |
| Requests but zero savings | Matching requests, compressible content, indicator basis | Treat zero as a possible valid result; compare similar work and periods |
| Changed connector but old behavior | Existing terminal and backend environment | Restart the relevant session/editor when safe; changing a shell export does not update a running backend |
| Hook warning or absent verdict | Exact source, current trust review, verdict timestamp | Inspect `/hooks`; do not infer IDE execution from registration or an old verdict |
| Initial Linux setup/sign-in fails | App's reported error, GUI session, keyring process, download progress | Check the documented prerequisites; no Linux keyring repair or fresh-sign-in procedure was qualified here |
| Windows desktop and WSL VS Code disagree | Each backend's `CODEX_HOME`, provider, and listener destination | Treat them as separate clients; executable location alone does not determine config ownership |

When contacting support, provide sanitized versions, symptom, error category,
and time zone. Exclude credentials, full configurations, private project
content, and raw runtime logs. The
[vendor security page](https://www.extraheadroom.com/docs/security) documents
release verification and the local proxy's trust implications; the signature
and data-handling claims were not independently audited here.

## Remaining qualification questions

- Both installations running concurrently, their port ownership, and the
  actual destination of each client's requests remain unqualified.
- No isolated current-session routing or savings experiment was performed;
  the earlier controlled toolstack sample remains historical.
- Current hook trust acceptance and automatic invocation in a fresh IDE task
  were not independently established by this guide's checks.
- Normal Quit, pause/resume, unexpected closure, update retention, autostart,
  tray interaction, and fresh keyring sign-in were not exercised.

Recheck this inventory after a desktop, managed-runtime, Codex, or WSL update.
Review changed guard definitions and repeat readiness, routing, and savings
checks separately before extending the accepted setup.
