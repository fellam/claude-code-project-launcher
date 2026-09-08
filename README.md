# Claude Code Project Launcher

A tiny Windows `.bat` launcher for [Claude Code](https://claude.com/claude-code). Point
it at a project folder and it opens a new terminal running Claude Code in that folder,
as a **named, remote-controllable session** — so you can find and message that exact
session again later (from another Claude Code session, or from
[claude.ai/code](https://claude.ai/code)'s Remote Control) instead of losing track of
which terminal window is which project.

## What it does

1. Takes a project folder — either dragged/dropped onto the `.bat` file, or typed in
   when it prompts you.
2. Names the session after the folder (e.g. `C:\dev\my-app` → session name `my-app`).
3. Opens a new [Windows Terminal](https://aka.ms/terminal) tab (or a plain `cmd` window
   if Windows Terminal isn't installed) in that folder, running:
   ```
   claude -c --remote-control "my-app" --effort medium
   ```
   `-c` continues the most recent conversation in that folder if one exists. On a
   genuinely first-ever run there (no prior conversation), that fails — the script
   automatically falls back to a fresh session instead of just exiting:
   ```
   claude --remote-control "my-app" --effort medium
   ```

## Reasoning effort

Claude Code's own default reasoning effort is `high`. This launcher starts sessions at
`medium` instead, to reduce token/credit usage — useful if you run several
long-lived agent sessions in parallel and don't need `high` for most of their work.
Override it by passing a second argument:
```
ClaudeProjectLauncher.bat "C:\path\to\your\project" high
```
Valid values (per `claude --effort`): `low`, `medium`, `high`, `xhigh`, `max`.

## Why

If you regularly work across several project folders with Claude Code, plain
`claude` in a terminal doesn't give you a memorable, addressable name for that
session — you end up with a pile of anonymous terminal tabs. `--remote-control "<name>"`
fixes that: the session becomes reachable by name from other Claude Code sessions
(`SendMessage`/`ListAgents` in a multi-agent setup) and from the Remote Control view at
claude.ai/code. This launcher just automates picking a sane, consistent name (the folder
itself) and re-attaching to that project's existing conversation instead of starting a
fresh one every time.

## Requirements

- Windows.
- [Claude Code](https://claude.com/claude-code) installed and on your `PATH` (the `claude`
  command must work from any terminal).
- [Windows Terminal](https://aka.ms/terminal) recommended (falls back to a plain `cmd`
  window automatically if not installed).

## Usage

**Drag and drop**: drag a project folder onto `ClaudeProjectLauncher.bat`.

**Double-click**: run it directly, then paste the project path when prompted.

**Command line**:
```
ClaudeProjectLauncher.bat "C:\path\to\your\project"
```

Each project folder always gets the same session name (its own folder name), so running
this again for the same project resumes that project's conversation rather than starting
a new one.

## License

MIT — see [LICENSE](LICENSE).
