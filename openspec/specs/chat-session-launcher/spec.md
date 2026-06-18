# chat-session-launcher Specification

## Purpose

Launch interactive Claude Code sessions configured as a general-purpose question-answering assistant, each confined to its own self-contained, topic-named session folder.

## Requirements

### Requirement: Launch a general-purpose chat session

The `cchat` command SHALL launch an interactive Claude Code session configured as a general-purpose question-answering assistant rather than a coding agent.

#### Scenario: Bare invocation starts a new session

- **WHEN** the user runs `cchat` with no subcommand
- **THEN** the tool prompts for a one-line topic, creates a session folder, and launches an interactive `claude` session whose working directory is that folder

#### Scenario: Claude CLI is missing

- **WHEN** the user runs `cchat` and the `claude` executable is not found on `PATH`
- **THEN** the tool prints an actionable error explaining that Claude Code must be installed and exits non-zero without creating a session folder

### Requirement: Prompt for a topic and create a self-contained session folder

On launch the tool SHALL prompt for a short topic, slugify it, and create a self-contained session folder named `YYYY-MM-DD-HHMM-<topic-slug>` under the configured chats root (default `~/chats/`, overridable via the `CHAT_HOME` environment variable).

#### Scenario: Topic provided

- **WHEN** the user enters a topic such as "Tax deadline questions"
- **THEN** the tool creates `~/chats/2026-06-18-1430-tax-deadline-questions/` and uses it as the session working directory

#### Scenario: Empty topic entered

- **WHEN** the user submits an empty topic at the prompt
- **THEN** the tool falls back to a generic slug (e.g. `untitled`) so the folder name remains well-formed and the session still launches

#### Scenario: Topic provided as an argument

- **WHEN** the user runs `cchat "Tax deadline questions"` with the topic as an argument
- **THEN** the tool skips the interactive prompt and uses the argument as the topic

#### Scenario: Custom chats root

- **WHEN** the `CHAT_HOME` environment variable is set to a directory
- **THEN** the session folder is created under that directory instead of `~/chats/`

### Requirement: Confine session artifacts to the session folder

The tool SHALL run Claude Code with its working directory set to the session folder so that files the assistant creates during the conversation are written inside that folder.

#### Scenario: Assistant writes a file during the session

- **WHEN** the assistant creates a file in response to a request during the chat
- **THEN** that file resides inside the session folder and not in the user's prior working directory
