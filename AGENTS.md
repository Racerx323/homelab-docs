# Repository Agents

This document outlines the various automated agents and services that have access to and interact with this repository. Understanding their roles is key to maintaining a secure and efficient workflow.

---

## GitHub Actions

- **Purpose**: Automates workflows such as testing, building, and deploying code based on triggers like pushes, pull requests, or scheduled events.
- **Configuration**: Workflows are defined in YAML files located in the `.github/workflows` directory.
- **Permissions**: Permissions are granted on a per-workflow basis and are scoped to be as restrictive as possible. See each workflow file for its specific permissions.

---

## Dependabot

- **Purpose**: Automatically keeps dependencies up-to-date by scanning for outdated packages and opening pull requests to update them. This helps to patch vulnerabilities and use the latest features.
- **Configuration**: The configuration for Dependabot is located in the `.github/dependabot.yml` file.
- **Scope**: Currently configured to monitor:
  - GitHub Actions (`.github/workflows/*.yml`)

---

## Code Style Linter

- **Purpose**: To automatically check the codebase against a set of style rules to ensure consistency and readability. This repository adheres to the **Google Style Guides**.
- **Configuration**: This is typically configured as a step within a GitHub Actions workflow (e.g., `.github/workflows/lint.yml`) that runs on pull requests or pushes. It can use tools like `Super-Linter`.
- **Permissions**: Requires read-only permissions to check out and analyze the repository's code.

---

## Codecov

- **Purpose**: To upload code coverage reports to Codecov to track the percentage of the codebase that is tested.
- **Configuration**: This is typically configured within a GitHub Actions workflow (e.g., in a file within `.github/workflows/`) to run after tests and upload the results.
- **Permissions**: It generally requires permissions to read repository contents and, in some configurations, to post comments on pull requests with coverage information.

---

## Security Considerations

- **Least Privilege**: Each automated agent should operate with the minimum permissions necessary to perform its tasks. Review and adjust permissions regularly.
- **Secrets Management**: Sensitive information such as API keys and tokens should be stored securely using GitHub Secrets and not hard-coded in workflows.
- **Dependency Updates**: Regularly review and merge Dependabot pull requests to keep dependencies up-to-date and reduce the risk of vulnerabilities.
- **Monitoring and Alerts**: Set up monitoring for automated workflows to detect and respond to any unusual activity or failures.

---

## Testing instructions

- Fix any test or type errors until the whole suite is green.
- After moving files or changing imports, check that all files or imports adhere to the project's coding standards.
- Add or update tests for the code you change, even if nobody asked.
- Run linters and formatters to ensure code quality.
- Make sure to test edge cases and error handling.
- Document any new features or changes to existing functionality.
- Ensure all changes are backward compatible.
- Update any relevant documentation or comments in the code.

---

## PR instructions

- **Title format**: [&lt;project_name&gt;] &lt;Title&gt;
- **Description**: Provide a clear and concise description of the changes made in the PR.
- **Related Issues**: Link any related issues or pull requests.
- **Checklist**:
  - [ ] Code is well-tested
  - [ ] Documentation has been updated
  - [ ] Changes have been reviewed by at least one other person


## CodeRabbit reviews

CodeRabbit requires external network access. Run all `coderabbit review` commands with network escalation (`sandbox_permissions: "require_escalated"`). Request the reusable approval prefix `["coderabbit", "review"]`.

Do not wait for a sandboxed review to time out. If it stalls while connecting, rerun it immediately with network escalation.

## vexp

### Context strategy

Call `run_pipeline` once at task start when the task does not name the files or
symbols to inspect. Anchor the request on real identifiers or repository paths.
Use the ranked pivots and blast radius to guide targeted inspection.

Skip `run_pipeline` when the task already names the files or symbols to change.
Use repository-native search for literal string sweeps. Call `run_pipeline`
again only when the task moves to another area.

### MCP tools

- `run_pipeline` returns ranked pivot files, line ranges, and blast radius.
- `get_skeleton` describes files that need structural inspection rather than
  editing.
- `verify_done` checks a multi-file change for parse errors, broken imports,
  untouched dependents, documentation drift, and impacted tests. Call it before
  declaring a multi-file task complete, then run the tests it identifies.

### Local workspace

vexp indexes the shared `/home/aaron/code` multi-repository workspace. The VS
Code extension and Ubuntu CLI use the same workspace index when they target
that root. Detailed daemon, refresh, status, and repair commands are documented
in `docs/development-tool-stack.md`.
<!-- /vexp -->


## vexp - Context-Aware AI Coding <!-- vexp v3.3.0 -->

### Context strategy: call run_pipeline ONCE at task start
If the task already names the files/symbols to touch, SKIP vexp. Otherwise one
`run_pipeline({ "task": "..." })` returns ranked pivot files with line ranges and
blast radius. Do NOT open files one by one to find your way around - every extra
tool call costs a turn. Call it again ONLY when the task moves to a new area.
`get_skeleton` for files to understand, not edit. `verify_done` before calling a
multi-file task complete, then RUN the tests it names.

### Query shape (do this)
Anchor the task on real identifiers (ClassName, functionName) or file paths:
`run_pipeline({ "task": "fix JWT expiry in AuthService.validateToken" })`

vexp runs entirely on this machine, index in `.vexp/`;
`run_pipeline` transmits nothing to any external service.
On `status: "degraded"` or 0 pivots the index is still building - use your own tools.
For literal string sweeps use your native search - do NOT route text sweeps through vexp.
Repo SOURCE only: logs, dist/, node_modules/ and files outside the repo are NOT indexed.
<!-- /vexp -->