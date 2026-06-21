# Contributing to cchat

Thanks for your interest in improving **cchat** — a lightweight bash harness that turns
your terminal into a private, searchable ChatGPT/Claude-desktop replacement. Contributions
of all sizes are welcome: bug reports, documentation, and code.

By participating in this project you agree to abide by our
[Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting bugs

Open a [bug report](https://github.com/Dzhuneyt/cchat/issues/new?template=bug_report.md) and include:

- Your OS and shell (`bash --version`), plus `jq` / `rg` versions if relevant.
- The exact `cchat` command you ran and what you expected to happen.
- What actually happened (copy the terminal output; redact anything private).

Please **do not** paste transcripts or anything sensitive — `cchat` stores chats in
plaintext under `~/chats/`, and the same caution applies to bug reports.

If you think you've found a **security vulnerability**, do not open a public issue — follow
[SECURITY.md](SECURITY.md) instead.

## Requesting features

Open a [feature request](https://github.com/Dzhuneyt/cchat/issues/new?template=feature_request.md).
Describe the problem you're trying to solve before the proposed solution — it helps keep the
tool small and focused.

## Development setup

`cchat` is a single self-contained bash script. There is no build step.

```bash
git clone https://github.com/Dzhuneyt/cchat.git
cd cchat
chmod +x cchat
./cchat --help
```

Runtime dependencies (see the README for details):

| Tool | Needed for |
|------|-----------|
| `claude` | launching sessions |
| `jq`     | rendering `transcript.md` + `meta.json` |
| `rg` (ripgrep) | `cchat search` |

The script is written to be **source-able** for testing without executing `main`
(it guards on `BASH_SOURCE`), so individual helper functions (`slugify`,
`project_slug_for`, `render_markdown`, …) can be unit-tested in isolation:

```bash
# Example: exercise a helper without launching a session
source ./cchat
slugify "Tax deadline questions"   # -> tax-deadline-questions
```

## Linting (matches CI)

CI runs [ShellCheck](https://www.shellcheck.net/) on every push and pull request. Run it
locally before opening a PR:

```bash
shellcheck cchat        # macOS: brew install shellcheck
```

Keep the script clean: if you must suppress a check, add a narrowly-scoped
`# shellcheck disable=SCxxxx` directive with a one-line justification (see the existing
`SC2012` directive for the pattern).

## Pull requests

1. Fork the repo and create a topic branch off `main`.
2. Keep changes focused; one logical change per PR.
3. Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
   (e.g. `fix:`, `feat:`, `docs:`, `ci:`, `chore:`) — this repo already uses them.
4. Make sure `shellcheck cchat` passes.
5. Update the README / docs and `CHANGELOG.md` if your change is user-visible.
6. Fill out the pull request template.

Maintainers review PRs as time permits. Thanks for contributing!
