# Contributing to homelab-docs

[code-of-conduct]: CODE_OF_CONDUCT.md
[security-policy]: SECURITY.md
[license]: LICENSE.md
[new-issue]: https://github.com/Racerx323/homelab-docs/issues/new/choose
[pull-requests]: https://github.com/Racerx323/homelab-docs/pulls
[style-guide]: https://google.github.io/styleguide/

First off, thank you for considering contributing to `homelab-docs`. It's people like you that make this project a great tool. Your help is essential to keeping it active and improving it continuously.

⚠️ **Note**: This project is maintained in my spare time, so your patience and understanding are greatly appreciated.

## Community Standards

We value respectful, inclusive, and constructive communication. All contributors are expected to follow our [Contributor Code of Conduct][code-of-conduct]. By participating, you agree to abide by these guidelines to help us maintain a welcoming and supportive environment.

## How Can I Contribute?

There are many ways to contribute, from writing code to improving documentation and reporting bugs. Every contribution is welcome and appreciated!

- **Reporting Bugs**: If you find a bug, please report it by [opening an issue][new-issue].
- **Suggesting Enhancements**: Have an idea for a new feature or an improvement? [Open an issue][new-issue] to discuss it.
- **Pull Requests**: If you're ready to contribute code or documentation, you can open a [pull request][pull-requests].
- **Answering Questions**: You can help other users by looking through existing issues and offering your help.
- **Code Refactoring and Cleanup**: Know a better way? Make a suggestion!

If you're unsure about your idea, feel free to [Open an issue][new-issue] first and discuss it!

## Getting Started

To set up the project locally for development:

1. **Fork** this repository to your GitHub account.
2. **Clone** your fork locally:

   ```bash
   git clone https://github.com/your-username/project-name.git
   ```

3. **Navigate** into the project directory:

   ```bash
   cd project-name
   ```

4. **Install** any required dependencies (if applicable, provide command or instructions).
5. **Run** the project (if applicable, provide command or instructions).

Encountering issues? Please [open an issue][new-issue] with details.

## Reporting Bugs

Before creating a bug report, please check existing issues to see if someone has already reported it.

When creating a bug report, please include as many details as possible. Fill out the required template, which will help me understand and reproduce the problem. Include details about your environment, the steps to reproduce the bug, and what you expected to happen.

## Suggesting Enhancements

If you have an idea for an enhancement, we'd love to hear about it. Please [open an issue][new-issue] and use the "Feature request" template. Provide a clear and detailed explanation of the feature, why it's needed, and how it should work.

## Before Submitting a PR

To maximize the likelihood of acceptance, please:

- Follow existing style guidelines and conventions.
- Keep your pull requests focused and concise.
- Ensure your code builds and passes any existing tests.
- Add or update tests to cover your changes if applicable.
- Update documentation accordingly.

Work-in-progress (WIP) pull requests are also acceptable. Please indicate clearly in the PR title or description that it's a WIP.

## Submitting a Pull Request

Pull Requests (PRs) are very welcome! If you're planning a large or significant change, please [open an issue][new-issue] first to discuss your proposal.

### Steps for submitting a PR

1. Fork this repository to your GitHub account. Ensure your local repository is up-to-date.
2. Create a new branch from `main` with a descriptive name:

   ```bash
   git checkout -b descriptive-branch-name
   ```

3. Make your changes, keeping your commits clear and organized.
   1. Follow existing style guidelines and conventions. [Google style guides][style-guide] are used for this project.
   2. `shellcheck` is used to maintain script quality. Please ensure your changes generate no new warnings.
4. Test your changes.
5. Update documentation accordingly.
6. Commit your change using clear and concise commit messages.
7. Push your branch to your fork:

   ```bash
   git push -u origin descriptive-branch-name
   ```

8. Open a pull request on the GitHub repository against the `main` branch and provide a detailed description of your changes.

## Security Vulnerability Reporting

Your security is a top priority. If you discover a security vulnerability, please **do not** open a public issue. Instead, please follow the instructions in our [Security Policy][security-policy].

## License Agreement

This project is licensed under the GPL-3.0 License. By contributing, you agree that your contributions will be licensed under its terms. You can find the full license text in the [LICENSE][license] file.

## Resources

- [Git Cheat Sheets](https://training.github.com/)
- [Using Pull Requests](https://docs.github.com/articles/about-pull-requests/)
- [GitHub Help](https://docs.github.com/)
