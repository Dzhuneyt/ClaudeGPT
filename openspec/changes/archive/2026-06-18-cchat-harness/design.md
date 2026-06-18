## Context

Claude Code is an interactive terminal agent that already runs locally and writes files to the working directory. It persists every session as a JSONL event log at `~/.claude/projects/<cwd-slug>/<session-uuid>.jsonl`, where `<cwd-slug>` is the absolute working-directory path with `/` and `.` characters replaced by `-`. This log is the durable record of a conversation but lives in an opaque, global location and is not designed for browsing or search.

We want a thin bash harness that makes Claude Code behave like the Claude desktop app for general questions, while keeping every conversation as a self-contained, locally-searchable folder. The harness owns: choosing the session folder, launching `claude` there, and — after exit — pulling the JSONL back into the folder and rendering a readable transcript. Confirmed decisions: chats live under `~/chats/`; search is ripgrep now with a SQLite-ready format later; the session is named from a topic prompted up front.

## Goals / Non-Goals

**Goals:**
- One command (`cchat`) starts a general-purpose Q&A session in a fresh, topic-named folder under `~/chats/`.
- Every conversation leaves behind a durable raw transcript (`transcript.jsonl`) and a greppable `transcript.md` inside its folder.
- `cchat search <query>` recalls facts from past chats locally and for free.
- Transcript layout stays stable so a SQLite FTS5 index can be added later without reformatting.
- Minimal, readable bash with explicit dependency checks and fail-fast errors.

**Non-Goals:**
- No SQLite indexing in this change (format is prepared, not built).
- No semantic/embedding search, no paid APIs.
- No multi-user, sync, or cloud features.
- No attempt to stream/capture the transcript live mid-session — archival happens at session end.
- No re-implementation of Claude Code's own resume/history; we wrap it, not replace it.

## Decisions

### Decision: Capture the transcript at session end by locating the session JSONL
After `claude` exits, derive the project dir from the session folder's absolute path (`/`+`.` → `-`) and select the newest `*.jsonl` in it as the session's transcript, then copy it in as `transcript.jsonl`.

- **Why**: Each session uses a brand-new, unique working directory, so its project dir contains only this conversation's log(s). Newest-by-mtime is unambiguous for a fresh folder and needs no Claude Code flags.
- **Robustness**: Record an epoch timestamp before launching; if the computed project dir is missing or empty, fall back to scanning all of `~/.claude/projects/` for the newest `*.jsonl` modified at/after that timestamp. If still nothing, warn and leave the folder intact (spec: archival must not hard-fail).
- **Alternatives considered**: (a) `claude --session-id <uuid>` to pin a known filename — rejected as a hard dependency on a flag whose stability we don't want to assume; mtime-in-unique-dir is simpler and version-robust. (b) A Claude Code `SessionEnd`/`Stop` hook to copy the file — rejected as heavier setup (global settings wiring) for a personal tool; revisit if end-of-session capture proves unreliable.

### Decision: Render `transcript.md` from JSONL with `jq`
Parse `transcript.jsonl` with `jq`, keep user and assistant text turns in order, and emit markdown where each turn starts with a stable delimiter line (e.g. `## [<role>] <iso-timestamp>`), followed by the turn's text.

- **Why**: `jq` is the right tool for JSONL and is already a standard tool in this environment. A consistent per-turn heading makes the file both human-readable and splittable by a future indexer.
- **Trade-off**: Tool-call/“thinking” events are skipped to keep transcripts conversational and greppable; the raw `transcript.jsonl` remains the lossless source of truth.

### Decision: General-purpose framing via a per-session system prompt / config
Launch `claude` with an "assistant, not coding agent" framing (via `--append-system-prompt` or an equivalent flag) so the session behaves like a general Q&A chat.

- **Why**: The user wants a ChatGPT replacement, not a code agent, even though artifacts may still be written.
- **Open**: exact flag/config surface is verified during implementation against the installed `claude` version; the framing text is small and lives in the script.

### Decision: Single `cchat` script with subcommands
`cchat` (bare) launches a session; `cchat search <query>` searches; `cchat "topic"` launches with a preset topic. Installation is a symlink onto `PATH`.

- **Why**: One entry point mirrors the simplicity of the desktop app and keeps the surface tiny. Subcommand dispatch in bash is trivial and easy to delete.
- **Alternatives**: separate `cchat` and `cchat-search` scripts — rejected as more files for no benefit.

### Decision: Session folder naming `YYYY-MM-DD-HHMM-<topic-slug>`
Slugify the topic (lowercase, non-alphanumeric → `-`, collapse repeats, trim). Default root `~/chats/`, overridable by `CHAT_HOME`.

- **Why**: Chronological sort, human-scannable, collision-resistant within a minute. Empty topic → `untitled`.

## Risks / Trade-offs

- **JSONL schema drift across Claude Code versions** → `transcript.md` rendering uses defensive `jq` (select known fields, skip unknown event types); raw JSONL is always preserved so nothing is lost even if rendering degrades.
- **Wrong file picked if multiple sessions run concurrently for the same folder** → mitigated by unique-per-session folders plus the start-timestamp fallback filter; acceptable for a single-user personal tool.
- **`claude` framing flag name/behavior may differ by version** → verified at implementation time; framing is non-critical (worst case: a slightly more "coding-agent" tone), so it won't block the core flow.
- **Dependency availability (`claude`, `rg`, `jq`)** → explicit pre-flight checks with actionable errors; `rg`/`jq` only required for the paths that use them.
- **Topic slug edge cases (unicode, very long)** → slug is truncated to a sane length and falls back to `untitled`.

## Migration Plan

Greenfield; nothing to migrate. Rollout is: add the script(s) + README, `chmod +x`, symlink onto `PATH`. Rollback is removing the symlink — archived session folders under `~/chats/` are plain files and remain readable independently.

## Open Questions

- Exact `claude` flag for the general-purpose system-prompt framing on the installed version (resolve during implementation; safe to omit if unavailable).
- Whether to also drop a top-level `index.md`/symlink-by-topic for browsing — deferred; out of scope unless requested.

## Future Improvements

- **Real-time transcript landing in the session folder.** Today the transcript is copied into the session folder at session end (see the archival decision above). A future iteration could have the transcript land in the session folder *live*, in real time, rather than after exit — e.g. by symlinking the session folder's `transcript.jsonl` to (or from) the active `~/.claude/projects/<cwd-slug>/<uuid>.jsonl` so it stays current as the conversation unfolds, or by a tail/sync that incrementally appends to `transcript.md`. Benefits: survives a crash or non-clean exit, and the folder is self-contained mid-session. Open considerations: how Claude Code handles a symlinked log, write-amplification of re-rendering markdown on every turn, and reconciling resumed sessions. Deferred — end-of-session capture is sufficient for the initial version.
