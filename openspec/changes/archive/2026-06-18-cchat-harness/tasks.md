## 1. Scaffolding & dependency checks

- [x] 1.1 Create the `cchat` bash script at the repo root with `#!/usr/bin/env bash`, `set -euo pipefail`, and a subcommand dispatcher (`search` → search path; anything else / empty → launch path)
- [x] 1.2 Add a `require_cmd` helper and pre-flight check for `claude` on the launch path; print an actionable error and exit non-zero if missing
- [x] 1.3 Resolve the chats root from `CHAT_HOME` (default `~/chats/`) and create it if absent

## 2. Session folder creation

- [x] 2.1 Read the topic: use `$1` if passed as an argument, otherwise prompt interactively
- [x] 2.2 Implement a `slugify` helper (lowercase, non-alphanumeric → `-`, collapse repeats, trim, truncate to a sane length, fall back to `untitled` when empty)
- [x] 2.3 Compose the folder name `YYYY-MM-DD-HHMM-<topic-slug>` and create the session folder under the chats root

## 3. Launch Claude Code in the session folder

- [x] 3.1 Record a pre-launch epoch timestamp (used by the archival fallback)
- [x] 3.2 Verify the installed `claude` flag for general-purpose system-prompt framing; launch `claude` with working directory set to the session folder and the framing applied (omit framing gracefully if the flag is unavailable)
- [x] 3.3 Confirm assistant-created files land inside the session folder (cwd is correct)

## 4. Transcript archival (runs after `claude` exits)

- [x] 4.1 Derive the project dir slug from the session folder's absolute path (`/` and `.` → `-`); select the newest `*.jsonl` in `~/.claude/projects/<slug>/`
- [x] 4.2 Fallback: if that dir is missing/empty, scan all of `~/.claude/projects/` for the newest `*.jsonl` modified at/after the pre-launch timestamp
- [x] 4.3 Copy the located JSONL into the session folder as `transcript.jsonl`; if none found, print a warning naming the folder and exit without hard-failing
- [x] 4.4 Render `transcript.md` from `transcript.jsonl` with `jq`: keep user/assistant text turns in order, prefix each turn with a stable delimiter line (`## [<role>] <iso-timestamp>`), skip tool/thinking events
- [x] 4.5 Write `meta.json` with topic, slug, ISO-8601 creation timestamp, and the resolved source JSONL path

## 5. Search subcommand

- [x] 5.1 Implement `cchat search <query>`: require `rg`; print usage and exit non-zero when no query is given
- [x] 5.2 Run ripgrep across all `transcript.md` files under the chats root with surrounding context, grouped/labeled by session folder
- [x] 5.3 Handle the no-match case (report no sessions matched, exit zero)

## 6. Documentation & install

- [x] 6.1 Write `README.md`: what it is, dependencies (`claude`, `rg`, `jq`), install (symlink onto `PATH`, `chmod +x`), usage (`cchat`, `cchat "topic"`, `cchat search <query>`), `CHAT_HOME`, and the on-disk layout
- [x] 6.2 Document the SQLite-FTS5-later path: the stable `transcript.md` delimiter and `meta.json` fields a future indexer relies on

## 7. Manual verification

- [x] 7.1 Run an end-to-end session: launch, ask a question, have the assistant write a file, exit; verify the session folder contains the artifact, `transcript.jsonl`, `transcript.md`, and `meta.json` — verified live: session `~/chats/2026-06-18-1626-smoke-test/` contains `scratch.txt` (assistant artifact), `transcript.jsonl`, `transcript.md`, and `meta.json`
- [x] 7.2 Run `cchat search` for a phrase from that session and confirm it returns the session with context
- [x] 7.3 Verify dependency-missing and empty-topic edge cases behave per spec
