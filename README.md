# claude-chat — a local ChatGPT / Claude-desktop replacement

A lightweight bash harness around [Claude Code](https://docs.claude.com/en/docs/claude-code).
Run `claude-chat` and you get a terminal Q&A session that behaves like the Claude desktop app or
ChatGPT — but every conversation is saved as a **self-contained, locally-searchable folder**
on your machine. No web UI, no export buttons, no paid search.

## What you get

Each session lives in its own folder under `~/chats/`:

```
~/chats/2026-06-18-1430-tax-deadline-questions/
├── transcript.jsonl   # raw Claude Code session log — lossless source of truth
├── transcript.md      # clean, greppable conversation (user/assistant text turns)
├── meta.json          # topic, slug, creation timestamp, source log path
└── <any files the assistant created during the chat>
```

Because the session runs *inside* this folder, anything the assistant writes lands here too.

## Dependencies

| Tool | Needed for | Install |
|------|-----------|---------|
| `claude` | launching sessions | <https://docs.claude.com/en/docs/claude-code> |
| `jq`     | rendering `transcript.md` + `meta.json` | `brew install jq` |
| `rg` (ripgrep) | `claude-chat search` | `brew install ripgrep` |

`jq` and `rg` are only required for rendering and search respectively; the raw
`transcript.jsonl` is always preserved even if `jq` is missing.

## Install

The command is named `claude-chat` on purpose. The name `chat` is already taken by
the system PPP utility `chat(8)` at `/usr/sbin/chat`, which sits ahead of `/usr/local/bin`
on a default macOS `PATH` — so a tool named `chat` gets silently shadowed and never runs.

```bash
chmod +x claude-chat
ln -s "$PWD/claude-chat" /usr/local/bin/claude-chat   # or any directory already on your PATH
```

If you previously symlinked an earlier version as `chat`, remove it: `rm /usr/local/bin/chat`.

## Usage

```bash
claude-chat                   # prompts: "Topic for this chat:" then opens the session
claude-chat "tax deadline"    # skip the prompt — topic preset from the argument
claude-chat search "deadline" # ripgrep across every transcript, grouped by session
```

End the session the way you normally exit Claude Code; the transcript is archived
automatically on exit, and the saved folder path is printed.

### Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `CHAT_HOME` | `~/chats` | Where session folders are created |
| `CLAUDE_PROJECTS_DIR` | `~/.claude/projects` | Where Claude Code stores its session logs |

## How recall works

`claude-chat search <query>` runs `ripgrep` over every `transcript.md` under `CHAT_HOME`,
printing matching lines with two lines of context, grouped under each session's path.
That's enough to recall a fact from a past chat and then open the full transcript or folder.

## Storage layout & the path to SQLite full-text search

Search is ripgrep today, but the on-disk format is deliberately **index-ready** so a
SQLite FTS5 index can be layered on later **without reformatting any existing transcripts**.
A future indexer can simply walk `CHAT_HOME` and, for each session folder:

- **Discover** the session by its folder (and read attributes from `meta.json` — keys:
  `topic`, `slug`, `created` (ISO-8601), `source_jsonl`).
- **Ingest** `transcript.md` turn-by-turn using its stable delimiter: every turn begins
  with a line of the form

  ```
  ## [<role>] <ISO-8601-timestamp>
  ```

  where `<role>` is `user` or `assistant`. Splitting on this heading yields one indexable
  record per turn, with role and timestamp already parsed — no need to touch the JSONL.

Because that delimiter and the `meta.json` schema are fixed, adding the index is purely
additive: already-archived sessions remain valid input unchanged.

## Notes

- Transcripts are archived **at session end**, not streamed live. A future improvement
  (tracked in the design doc) is to land the transcript in the folder in real time.
- `transcript.md` intentionally omits tool calls and the model's internal "thinking" to stay
  conversational and greppable. The raw `transcript.jsonl` keeps everything if you need it.
