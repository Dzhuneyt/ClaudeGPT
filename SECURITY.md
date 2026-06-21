# Security Policy

## Supported versions

`cchat` is distributed from the `main` branch and has not yet cut tagged releases. Security
fixes are applied to `main`; please ensure you are running the latest commit before reporting.

| Version | Supported |
|---------|-----------|
| `main` (latest) | ✅ |
| older commits | ❌ — update to latest `main` |

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, report them privately through GitHub's
[private vulnerability reporting](https://github.com/Dzhuneyt/cchat/security/advisories/new)
("Report a vulnerability" under the repository's **Security** tab). If that is unavailable to
you, contact the maintainer ([@Dzhuneyt](https://github.com/Dzhuneyt)) directly.

When reporting, please include:

- A description of the issue and its impact.
- Steps to reproduce (a minimal proof-of-concept if possible).
- Affected commit / environment (OS, shell, `jq` / `rg` versions).

We aim to acknowledge reports within a few days and to provide a remediation timeline after
triage. We will credit reporters in the fix unless you ask us not to.

## Scope and hardening notes

`cchat` is a thin local wrapper around [Claude Code](https://docs.claude.com/en/docs/claude-code).
A few things worth knowing:

- **Transcripts are stored in plaintext** under `~/chats/` (configurable via `CHAT_HOME`).
  Treat that directory as sensitive: keep it out of any git repository and out of synced/
  shared folders, and don't paste secrets into a chat.
- `cchat` does not transmit data anywhere itself; network/privacy behavior is governed by the
  underlying `claude` CLI.
- Reports about the upstream `claude` CLI should go to Anthropic, not this repo.
