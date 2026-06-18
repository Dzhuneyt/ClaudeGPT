# Demo assets

This repo ships two demo clips. One is fully reproducible; the other you record yourself
(only a human can drive the live `claude` TUI).

## 1. Surface demo — `docs/demo.gif` (reproducible, via VHS)

Shows install → self-contained folder layout → plain-markdown transcript → `search` recall.
It runs against the committed fixture in [`demo-home/`](demo-home/), so the render is
deterministic and needs **no live Claude session**.

**How VHS works:** [`demo.tape`](demo.tape) is a plain-text script (`Type`, `Enter`, `Sleep`,
`Output`). `vhs` executes those steps in a headless terminal and renders a GIF. Edit the tape,
re-run, get an updated GIF — nothing is captured by hand.

```bash
brew install vhs ffmpeg ttyd     # one-time
vhs docs/demo.tape               # writes docs/demo.gif
```

Then embed it at the top of the root `README.md`:

```markdown
![cchat demo](docs/demo.gif)
```

## 2. Live-session clip — record it yourself (via asciinema + agg)

This is the part that can't be automated: an actual interactive chat. Capture a real session.

**How asciinema + agg work:** `asciinema rec` records your real terminal (keystrokes + output,
in real time) into a JSON `.cast`; `agg` converts that cast into a GIF.

```bash
brew install asciinema agg                       # one-time

asciinema rec docs/live.cast                      # starts recording
#   ... in the recording, run:  cchat "demo question"
#   ... ask a couple of things, maybe have it write a file, then exit Claude Code
#   ... press Ctrl-D to stop recording

agg docs/live.cast docs/live.gif                  # convert to GIF
```

Keep it short (~20–30s). Then embed `docs/live.gif` in the README under the surface demo.

> Tip: set a clean prompt and a normal-size window before recording. `agg --cols 100 --rows 28`
> controls the output dimensions if the default looks off.
