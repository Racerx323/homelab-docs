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
