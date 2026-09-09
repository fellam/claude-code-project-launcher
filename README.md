# Claude Code Project Launcher

A tiny Windows `.bat` launcher for [Claude Code](https://claude.com/claude-code). Point
it at a project folder and it opens a new terminal running Claude Code in that folder,
as a **named, remote-controllable session** — so you can find and message that exact
session again later (from another Claude Code session, or from
[claude.ai/code](https://claude.ai/code)'s Remote Control) instead of losing track of
which terminal window is which project.

## What it does

1. Takes a project folder — dragged/dropped onto the `.bat` file, passed as the first
   command-line argument, or (if you place a copy of this script directly inside the
   project folder) just left blank: a plain double-click then defaults to the folder the
   script itself lives in, so it starts Claude right there.
2. Names the session — the 3rd argument if given, otherwise the folder's own name. No
   prompt, ever: this has to be able to run fully unattended (e.g. starting a fresh
   session remotely with nobody at the keyboard), and renaming a session after the fact
   works fine from Remote Control or another Claude Code session, so there's nothing to
   gain from blocking on human input here.
3. Opens a new `cmd` window in that folder, running:
   ```
   claude -c --remote-control=my-app --effort medium
   ```
   `-c` continues the most recent conversation in that folder if one exists. On a
   genuinely first-ever run there (no prior conversation), that fails — the script
   automatically falls back to a fresh session instead of just exiting:
   ```
   claude --remote-control=my-app --effort medium
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
session — you end up with a pile of anonymous terminal tabs. `--remote-control=<name>`
fixes that: the session becomes reachable by name from other Claude Code sessions
(`SendMessage`/`ListAgents` in a multi-agent setup) and from the Remote Control view at
claude.ai/code. This launcher just automates picking a sane, consistent name and
re-attaching to that project's existing conversation instead of starting a fresh one
every time.

## Requirements

- Windows.
- [Claude Code](https://claude.com/claude-code) installed and on your `PATH` (the `claude`
  command must work from any terminal).

Windows Terminal is **not** used even if installed — `wt.exe` re-parses its own
command-line argument before handing it to the inner `cmd.exe`, which was found to
silently drop the `--remote-control` value in testing. A plain `cmd` window is used
instead, unconditionally, to avoid that.

## Usage

**Double-click, folder-local copy**: place a copy of this script directly inside a
project folder and double-click it — it just starts Claude there, named after that
folder.

**Drag and drop**: drag a project folder onto `ClaudeProjectLauncher.bat`.

**Command line**:
```
ClaudeProjectLauncher.bat "C:\path\to\your\project"
ClaudeProjectLauncher.bat "C:\path\to\your\project" medium "custom-session-name"
```

Each project folder always gets the same session name (its own folder name) unless you
pass a 3rd argument explicitly, so running this again for the same project resumes that
project's conversation rather than starting a new one.

## License

MIT — see [LICENSE](LICENSE).
