# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2025-02-11

### Added

- Sessionizer mode: open directories in tmux sessions with fzf project discovery
- Worktree mode: full git worktree lifecycle management (`create`, `remove`, `prune`)
- Configurable tmux pane layouts via `WORKSPACE_INTERNAL_LAYOUT` (vertical, horizontal, grid)
- Smart pull with safety checks when reusing existing worktrees (fast-forward, divergence detection)
- Automatic `.env` and `.pem` file copying from parent worktree
- Environment variable forwarding (`worktree_*` prefix) to tmux sessions
- Post-creation setup commands via `WORKSPACE_INTERNAL_SETUP_CMD` and `--setup` flag
- `remove` command to kill tmux session and remove git worktree in one step
- `prune --force` to remove worktrees with uncommitted changes
- Protected branches (main, master, _main, _master) cannot be removed
- Automatic stray process cleanup during worktree removal
- Install script with curl pipe support (`curl ... | sh`)
- Ctrl-F keybinding setup for fish and zsh
- Man page (`man workspace`)
- `--version` / `-v` flag
