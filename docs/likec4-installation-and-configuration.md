# LikeC4 Installation and Configuration

This guide installs LikeC4 as a shared architecture-as-code tool across the
homelab repositories. It is designed for the development environment described
in [Development Tool Stack](development-tool-stack.md): Ubuntu 24.04 under
WSL2, Node.js managed by NVM, user-level npm tools, Codex CLI, GitHub Copilot,
VS Code, and repository-local pre-commit validation.

The setup uses four layers:

1. A global LikeC4 CLI for interactive use in every repository.
2. A global LikeC4 agent skill that teaches Codex the LikeC4 DSL.
3. A global Codex MCP server that queries the model in the current repository.
4. Repository-local model files and validation hooks.

This avoids adding a `package.json` and `node_modules` directory to every
documentation, shell, PowerShell, configuration, or Terraform repository.

## Prerequisites

The current workstation versions of Node.js and npm are sufficient. Confirm
that the NVM-managed default Node.js installation is active:

```bash
nvm use default
node --version
npm --version
npx --version
```

LikeC4 currently requires Node.js 22.22.3 or newer. The workstation's Node.js
26 installation satisfies this requirement.

Confirm that user-level executables and the active NVM binary directory are
available in `PATH`:

```bash
command -v node
command -v npm
command -v codex
```

Run the remaining Linux commands inside Ubuntu under WSL2, not from Windows
PowerShell.

## Install the LikeC4 CLI globally

Install the full LikeC4 toolchain under the active NVM Node.js version:

```bash
nvm use default
npm install --global likec4
```

Verify the installation:

```bash
command -v likec4
likec4 --version
likec4 --help
```

The `likec4` package includes the preview server, formatter, validator,
exporters, language server, and MCP server. Do not also install
`@likec4/mcp`; that smaller package would duplicate functionality already
provided by the full CLI.

### Preserve the CLI across NVM upgrades

NVM stores global npm packages under each installed Node.js version. Add
LikeC4 to NVM's default package list so that it is installed automatically
when a future Node.js version is installed:

```bash
touch "$NVM_DIR/default-packages"
```

Add this package name as its own line in `$NVM_DIR/default-packages`:

```text
likec4
```

After changing Node.js versions, verify the executable again:

```bash
nvm use default
command -v likec4
likec4 --version
```

## Install the LikeC4 agent skill globally

LikeC4 publishes the `likec4-dsl` skill. It provides syntax, modeling
patterns, examples, and validation guidance to compatible AI coding agents.
Install it once at user scope for Codex:

```bash
npx skills add https://likec4.dev/ \
    --skill likec4-dsl \
    --agent codex \
    --global \
    --yes
```

Verify that the skill is installed and linked to Codex:

```bash
npx skills list --global --agent codex
```

The global installation makes the skill available from every repository and
avoids checking an identical skill into each repository. Restart Codex if the
skill does not appear in an existing session.

Codex can invoke the skill automatically while working with `.c4` and
`.likec4` files. It can also be selected explicitly from the skills menu or by
mentioning `$likec4-dsl` in a prompt.

To install the same skill for another supported agent, rerun the command
without `--agent codex` and select the desired agents interactively.

## Configure the LikeC4 MCP server for Codex

The MCP server lets Codex query actual LikeC4 models instead of relying only on
DSL instructions. Register the globally installed CLI as a user-level Codex
MCP server:

```bash
codex mcp add likec4 -- likec4 mcp --stdio
```

Confirm that Codex registered the server:

```bash
codex mcp list
```

The command writes an entry equivalent to the following in
`~/.codex/config.toml`:

```toml
[mcp_servers.likec4]
command = "likec4"
args = ["mcp", "--stdio"]
enabled = true
required = false
startup_timeout_sec = 20
tool_timeout_sec = 60
```

The timeout settings are optional. Add them if the WSL filesystem or a large
model causes the default startup time to be insufficient.

### Workspace selection

Do not set `LIKEC4_WORKSPACE` in the global MCP configuration. When that
variable is absent, LikeC4 uses the MCP process's current directory. This lets
one configuration work across all repositories.

Launch Codex from the repository root so LikeC4 discovers that repository's
model:

```bash
cd /home/aaron/code/homelab-network
codex
```

Starting Codex in another repository selects that repository automatically:

```bash
cd /home/aaron/code/homelab-terraform
codex
```

Avoid starting Codex from `/home/aaron/code` unless the intent is to expose
models from multiple repositories to one MCP server. Starting from a nested
subdirectory can also hide an `architecture/` directory located at the
repository root.

Restart Codex after adding or changing the MCP configuration. In the Codex
terminal interface, use `/mcp` to confirm that `likec4` is active.

## Install the VS Code extension in WSL

Install the official LikeC4 extension into the **WSL: Ubuntu** VS Code
extension host:

```bash
code --install-extension likec4.likec4-vscode
```

The extension provides validation, semantic highlighting, completion,
navigation, safe renaming, and live previews. Open a `.c4` or `.likec4` file
to activate it.

The extension also registers a server with VS Code's native MCP support. That
registration can serve VS Code-integrated agents such as GitHub Copilot. Keep
the Codex MCP entry because Codex uses its own shared `config.toml`
configuration.

If VS Code offers separate **Install Locally** and **Install in WSL: Ubuntu**
actions, choose the WSL installation for repositories under
`/home/aaron/code`.

## Add a model to a repository

Use a consistent top-level directory in repositories that need an
architecture model:

```text
repository/
└── architecture/
    ├── model.c4
    ├── views.c4
    └── deployment.c4
```

Only create files required by the repository. Do not add empty architecture
directories to repositories that do not yet have a useful model.

Recommended ownership is:

- Store the cross-repository homelab landscape in
  `homelab-docs/architecture/`.
- Store service, deployment, or implementation detail in the repository that
  owns that configuration.
- Use stable element identifiers across related models, such as `dns`, `ntp`,
  `monitoring`, and `notifications`.
- Keep generated exports out of source control unless they are intentionally
  published documentation artifacts.

From a repository root, preview the model with hot reload:

```bash
likec4 dev
```

The preview server listens on `127.0.0.1` by default. Open the displayed URL
from Windows; WSL2 forwards localhost services to the Windows host.

Useful model commands are:

```bash
likec4 validate
likec4 format --check
likec4 format
likec4 build -o ./dist
likec4 export json -o ./likec4-model.json
```

Run `likec4 format` only when intentionally updating source files. Use
`likec4 format --check` in automated validation.

## Add repository-local pre-commit validation

Add the following hooks to `.pre-commit-config.yaml` in each repository that
contains LikeC4 sources:

```yaml
- repo: local
  hooks:
    - id: likec4-format
      name: LikeC4 format
      entry: likec4 format --check
      language: system
      files: '\.(c4|likec4)$'
      pass_filenames: false

    - id: likec4-validate
      name: LikeC4 validate
      entry: likec4 validate
      language: system
      files: '\.(c4|likec4)$'
      pass_filenames: false
```

The file filter prevents the hooks from running in repositories without
LikeC4 sources. `pass_filenames: false` is required because both commands
validate the workspace rather than individual filenames.

Install or refresh the hooks and run the complete suite:

```bash
pre-commit install
pre-commit clean
pre-commit run --all-files
```

Use direct commands when diagnosing a hook failure:

```bash
likec4 format --check
likec4 validate
```

## Configure continuous integration

Hooks with `language: system` expect LikeC4 to exist on the CI runner. Install
an explicit LikeC4 version before invoking pre-commit. Replace `X.Y.Z` with the
version recorded in the development tool inventory:

```yaml
- name: Set up Node.js
  uses: actions/setup-node@v5
  with:
    node-version: '26.4.0'

- name: Install LikeC4
  run: npm install --global likec4@X.Y.Z

- name: Run pre-commit
  run: pre-commit run --all-files
```

Pinning CI while recording the workstation version preserves repeatable
validation without turning every repository into an npm project. Update the
pin deliberately when the shared workstation tool is upgraded.

## Verify the complete integration

Run this checklist after the initial installation or a major upgrade:

```bash
nvm use default
node --version
likec4 --version
npx skills list --global --agent codex
codex mcp list
code --list-extensions
```

Then, from a repository containing a LikeC4 model:

```bash
likec4 format --check
likec4 validate
pre-commit run --all-files
```

Start a new Codex session from that repository root and ask it to list the
LikeC4 projects or summarize an element. A successful response using the MCP
tools confirms that the server is reading the correct workspace.

## Upgrade and maintenance

Upgrade the global CLI under the active default Node.js version:

```bash
nvm use default
npm update --global likec4
likec4 --version
```

Update the global skill separately:

```bash
npx skills update likec4-dsl --global
npx skills list --global --agent codex
```

After an upgrade:

1. Update the LikeC4 version in `development-tool-stack.md`.
2. Update pinned CI versions in repositories containing LikeC4 models.
3. Restart Codex and VS Code so they reload the MCP server and extension.
4. Run `pre-commit clean` and `pre-commit run --all-files` in each affected
   repository.

## Troubleshooting

### `likec4: command not found`

Confirm that the expected NVM Node.js version is active and that LikeC4 is
installed under it:

```bash
nvm use default
npm list --global --depth=0
command -v likec4
```

If the package disappeared after installing a new Node.js version, reinstall
it and confirm that `likec4` is listed in `$NVM_DIR/default-packages`.

### Codex cannot start the MCP server

Run the exact server command manually from a repository root:

```bash
likec4 mcp --stdio
```

Stop it with `Ctrl+C` after confirming that it starts without an error. Then
check the Codex registration:

```bash
codex mcp list
```

If the Codex IDE extension cannot resolve `likec4` but the shell can, restart
VS Code from a WSL shell so it inherits the NVM-managed `PATH`:

```bash
cd /home/aaron/code
code .
```

Avoid hard-coding an NVM version-specific executable path in
`~/.codex/config.toml` unless restarting the host does not solve the problem.
Such a path must be updated whenever the Node.js version changes.

### The MCP server finds no projects

Confirm all of the following:

- Codex was started from the repository root.
- The repository contains at least one `.c4` or `.likec4` file.
- The files are below the current working directory.
- `LIKEC4_WORKSPACE` is not globally pinned to another repository.
- `likec4 validate` succeeds from the same directory.

### The skill is installed but does not appear

Check its global status:

```bash
npx skills list --global --agent codex
```

Restart Codex after installing or updating the skill. If the skills CLI reports
that the skill is not linked, rerun the installation interactively and confirm
Codex as the target agent.

### VS Code does not activate the extension

Open a `.c4` or `.likec4` file and confirm that the extension is installed in
the WSL extension host. Reload the VS Code window if the extension was
installed while the workspace was already open.

## Remove LikeC4

Remove the MCP registration first:

```bash
codex mcp remove likec4
```

Remove the skill and global CLI:

```bash
npx skills remove likec4-dsl --global --agent codex --yes
npm uninstall --global likec4
```

Also remove `likec4` from `$NVM_DIR/default-packages` and uninstall the VS Code
extension if it is no longer needed. Removing the tools does not delete any
repository `.c4` or `.likec4` source files.

## References

- [LikeC4 AI tools](https://likec4.dev/tooling/ai-tools/)
- [LikeC4 CLI](https://likec4.dev/tooling/cli/)
- [LikeC4 editor integrations](https://likec4.dev/tooling/editors/)
- [LikeC4 VS Code extension](https://marketplace.visualstudio.com/items?itemName=likec4.likec4-vscode)
- [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp)
- [Agent Skills CLI](https://github.com/vercel-labs/skills)
