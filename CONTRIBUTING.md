# Contributing to cchat

Thanks for your interest in improving **cchat**. Contributions of all sizes are welcome:
bug reports, documentation, and code.

By participating you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Before you start

Setup, dependencies, and local linting are documented once in the README — please follow
those rather than a duplicated copy here:

- **Install & dependencies:** [README → Dependencies](README.md#dependencies) and
  [README → Install](README.md#install)
- **Dev setup, source-for-tests, and the `shellcheck` lint command:**
  [README → Development](README.md#development)

CI runs ShellCheck on every push and pull request, so run `shellcheck cchat` locally first.

## Reporting bugs

Open a [bug report](https://github.com/Dzhuneyt/cchat/issues/new?template=bug_report.md) with
your OS/shell, the exact command, and what you expected vs. what happened.

Please **do not** paste transcripts or anything sensitive — `cchat` stores chats in plaintext
under `~/chats/`, and the same caution applies to bug reports.

Think you've found a **security vulnerability?** Don't open a public issue — follow
[SECURITY.md](SECURITY.md).

## Requesting features

Open a [feature request](https://github.com/Dzhuneyt/cchat/issues/new?template=feature_request.md).
Describe the problem before the proposed solution — it helps keep the tool small and focused.

## Pull requests

1. Fork the repo and create a topic branch off `main`.
2. Keep changes focused; one logical change per PR.
3. Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
   (e.g. `fix:`, `feat:`, `docs:`, `ci:`, `chore:`) — this repo already uses them.
4. Make sure `shellcheck cchat` passes.
5. Update the README / docs and `CHANGELOG.md` if your change is user-visible.
6. Fill out the pull request template.

Maintainers review PRs as time permits. Thanks for contributing!
