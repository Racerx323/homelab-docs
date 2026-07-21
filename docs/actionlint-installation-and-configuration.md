# actionlint Installation and Configuration

This guide installs `actionlint` as the shared static checker for GitHub
Actions workflows. `yamllint` continues to enforce general YAML syntax and
style. `actionlint` adds workflow-aware checks for events, jobs, expressions,
action inputs, reusable workflows, runner labels, permissions, and scripts in
`run` steps.

## Install the pinned release

Install actionlint 1.7.12 with the workstation's Go toolchain. User-local Go
executables belong in `~/.local/bin`:

```bash
GOBIN="$HOME/.local/bin" \
    go install github.com/rhysd/actionlint/cmd/actionlint@v1.7.12
actionlint -version
```

Confirm that `~/.local/bin` is present in `PATH` if the command is not found.

## Run workflow validation

From a repository root, validate every workflow under `.github/workflows/`:

```bash
actionlint
```

Validate a specific workflow while troubleshooting:

```bash
actionlint .github/workflows/example.yml
```

actionlint uses ShellCheck automatically when `shellcheck` is available. This
extends the existing shell validation into inline GitHub Actions `run` steps.

## Configure pre-commit

Repositories containing GitHub Actions workflows use this local hook:

```yaml
- id: actionlint
  name: Validate GitHub Actions workflows
  entry: actionlint
  language: system
  files: ^\.github/workflows/.*\.ya?ml$
  pass_filenames: false
```

The file filter avoids running actionlint for unrelated YAML changes.
`pass_filenames: false` makes actionlint inspect the complete workflow set so it
can validate references between reusable workflows.

Add the hook when a repository gains its first file under
`.github/workflows/`. Repositories without workflows do not need the hook.

## Upgrade

Review the actionlint changelog, install the selected release explicitly, and
validate all managed repositories that contain workflows:

```bash
GOBIN="$HOME/.local/bin" \
    go install github.com/rhysd/actionlint/cmd/actionlint@NEW_VERSION
actionlint -version
pre-commit run actionlint --all-files
```

Update the pinned version in the development tool inventory and this guide in
the same change.
