# workspace

A terminal session manager and Git worktree tool with fzf switching, automatic .env copying, and configurable setup commands for fast parallel worktrees. Supports tmux and Ghostty with automatic detection.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/sjdonado/workspace/main/install.sh | sh
```

This will:
- Install the `workspace` binary to `/usr/local/bin` (or `~/.local/bin`)
- Install the man page (`man workspace`)
- Set up a **Ctrl-F** keybinding in fish and/or zsh to quickly open projects

To update, run the same command again.

### Requirements

- [git](https://git-scm.com)
- [tmux](https://github.com/tmux/tmux) or [Ghostty](https://ghostty.org) (at least one)
- [fzf](https://github.com/junegunn/fzf) (optional, for interactive project selection)

## Usage

### Open mode (default)

Open a project by picking from git repos in the current directory (up to 3 levels deep):

```sh
workspace open
```

When run inside a git worktree, lists existing worktree branches and remote branches via fzf, switching to or creating the selected worktree.

Or open a specific directory:

```sh
workspace open ~/projects/myapp
```

Close the current session:

```sh
workspace close
```

Close the session and remove the worktree for the current branch:

```sh
workspace remove
```

Or specify a branch:

```sh
workspace remove feature/old-feature
```

### Worktree mode

Create a worktree for a feature branch (opens in a new tmux session or Ghostty tab):

```sh
workspace worktree create feature/user-auth
```

Create with automatic setup (runs `$WORKSPACE_INTERNAL_SETUP_CMD`):

```sh
workspace worktree create --setup feature/api-refactor
```

Clean up all unused worktrees:

```sh
workspace worktree prune
workspace worktree prune --force  # also removes worktrees with uncommitted changes
```

### Ctrl-F keybinding

After installation, press **Ctrl-F** in your terminal to run `workspace open` -- a quick fuzzy finder for all your projects.

## Configuration

Set these environment variables in your shell configuration:

```sh
# Tmux layout for new sessions (tmux mode only)
# Format: <count><direction>,... where direction is v (vertical), h (horizontal), g (grid)
export WORKSPACE_INTERNAL_LAYOUT="2v,4g"

# Command to run after creating a worktree with --setup
export WORKSPACE_INTERNAL_SETUP_CMD="bun install && bun build"

# Variables forwarded to tmux sessions (worktree_ prefix is stripped, tmux mode only)
export worktree_API_URL="http://localhost:3000"
export worktree_NODE_ENV="development"
```

### Layout examples (tmux mode)

| Layout | Description |
|--------|-------------|
| `1v` | Single pane (default) |
| `2v` | Two side-by-side panes |
| `3h` | Three stacked panes |
| `4g` | 2x2 grid |
| `2v,3h` | Two windows: first with 2 vertical panes, second with 3 horizontal |

## Terminal modes

Workspace auto-detects the terminal backend:

| Mode | Detection | Features |
|------|-----------|----------|
| **tmux** | Inside a tmux session (`$TMUX` set) | Sessions, layouts, panes, env forwarding |
| **Ghostty** | Ghostty terminal (`$TERM_PROGRAM`) | Opens new tabs via `open -a Ghostty` (macOS) or `ghostty` CLI (Linux) |

## Commands

```
workspace open [path]                        Open directory in new session/tab (fzf picker if no path)
workspace close [session_name]               Close session/tab
workspace remove [branch_name]               Close session and remove git worktree
workspace worktree create [--setup] <branch> Create git worktree + session/tab
workspace worktree remove [branch_name]      Remove git worktree
workspace worktree prune [--force]           Remove all unused worktrees
workspace help                               Show usage
workspace --version                          Show version
```

## Documentation

```sh
man workspace
```
