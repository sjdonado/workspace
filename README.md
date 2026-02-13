# workspace

A tmux session manager and git worktree tool. Quickly switch between projects with fzf, or manage parallel branch development with git worktrees -- all backed by tmux sessions with configurable pane layouts.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/sjdonado/tmux-workspace/main/install.sh | sh
```

This will:
- Install the `workspace` binary to `/usr/local/bin` (or `~/.local/bin`)
- Install the man page (`man workspace`)
- Set up a **Ctrl-F** keybinding in fish and/or zsh to quickly open projects

To update, run the same command again.

### Requirements

- [tmux](https://github.com/tmux/tmux)
- [git](https://git-scm.com)
- [fzf](https://github.com/junegunn/fzf) (optional, for interactive project selection)

## Usage

### Sessionizer mode (default)

Open a project by picking from git repos in the current directory (up to 3 levels deep):

```sh
workspace open
```

Or open a specific directory:

```sh
workspace open ~/projects/myapp
```

Close the current tmux session:

```sh
workspace close
```

Kill the tmux session and remove the worktree for the current branch:

```sh
workspace remove
```

Or specify a branch:

```sh
workspace remove feature/old-feature
```

### Worktree mode

Create a worktree for a feature branch:

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
# Tmux layout for new sessions
# Format: <count><direction>,... where direction is v (vertical), h (horizontal), g (grid)
export WORKSPACE_INTERNAL_LAYOUT="2v,4g"

# Command to run after creating a worktree with --setup
export WORKSPACE_INTERNAL_SETUP_CMD="bun install && bun build"

# Variables forwarded to tmux sessions (worktree_ prefix is stripped)
export worktree_API_URL="http://localhost:3000"
export worktree_NODE_ENV="development"
```

### Layout examples

| Layout | Description |
|--------|-------------|
| `1v` | Single pane (default) |
| `2v` | Two side-by-side panes |
| `3h` | Three stacked panes |
| `4g` | 2x2 grid |
| `2v,3h` | Two windows: first with 2 vertical panes, second with 3 horizontal |

## Commands

```
workspace open [path]                        Open directory in tmux session (fzf picker if no path)
workspace close [session_name]               Kill tmux session
workspace remove [branch_name]               Kill tmux session and remove git worktree
workspace worktree create [--setup] <branch> Create git worktree + tmux session
workspace worktree remove [branch_name]      Remove git worktree
workspace worktree prune [--force]           Remove all unused worktrees
workspace help                               Show usage
workspace --version                          Show version
```

## Documentation

```sh
man workspace
```
