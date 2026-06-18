## Why

ChatGPT and the Claude web/desktop apps trap conversations inside a vendor UI: transcripts are hard to search, impossible to grep, and any files the assistant produces are stuck behind a download button. Claude Code already runs in the terminal and writes files locally — what's missing is a thin harness that turns it into a general "ask anything" replacement where every conversation is a durable, self-contained, locally-searchable artifact.

## What Changes

- Add a single bash entry-point script (`cchat`) that launches an interactive Claude Code session pre-configured as a general-purpose Q&A assistant (not a coding agent).
- On launch, prompt for a one-line topic and create a self-contained session folder under `~/chats/` named `YYYY-MM-DD-HHMM-<topic-slug>/`.
- Run Claude Code with its working directory set to that session folder, so any artifacts the assistant writes land inside the session folder.
- On session end, persist a durable transcript inside the session folder in two forms: the raw Claude Code session JSONL (source of truth) and a clean, greppable `transcript.md`.
- Add a `cchat search <query>` subcommand that runs ripgrep across all session transcripts and reports matching sessions with context.
- Design the transcript format and on-disk layout so a future SQLite FTS5 index can be layered on without reformatting existing transcripts (search is ripgrep now, SQLite-ready later).
- Ship a short README documenting install (symlink onto `PATH`), usage, and the storage layout.

## Capabilities

### New Capabilities
- `chat-session-launcher`: Launching a configured, general-purpose Claude Code session inside a freshly created, topic-named, self-contained session folder under `~/chats/`.
- `chat-transcript-archival`: Persisting each conversation as a durable raw JSONL transcript plus a clean greppable markdown transcript inside the session folder, with a layout amenable to later indexing.
- `chat-transcript-search`: Searching across all archived transcripts from the CLI (ripgrep-based now), reporting matching sessions with enough context to recall facts from prior chats.

### Modified Capabilities
<!-- None — this is a greenfield tool in an empty directory. -->

## Impact

- **New files**: `cchat` (bash entry point), supporting script(s)/helpers, and `README.md` at the repo root.
- **Dependencies**: requires the `claude` CLI (Claude Code) and `ripgrep` (`rg`) on `PATH`; `jq` for parsing the session JSONL into markdown. No paid APIs — search is fully local and free.
- **Filesystem**: creates and writes under `~/chats/` (configurable via an env var); reads Claude Code's session storage under `~/.claude/projects/` to locate the JSONL for the just-ended session.
- **No existing code affected** — greenfield tool in a previously empty directory.
