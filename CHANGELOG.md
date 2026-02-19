# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-02-19

### Added

- Kitty terminal support with near-full functionality via `kitten @` remote control (requires `allow_remote_control` in kitty.conf)
- Kitty tab creation via `kitten @ launch --type=tab` with working directory, tab title, and environment variables
- Kitty tab queries via `kitten @ ls`, tab close via `kitten @ close-tab`, send-text via `kitten @ send-text`
- Kitty environment variable forwarding: `worktree_*` variables are set via `--env` flags at tab launch time
- Kitty limitation: no pane layout support (WORKSPACE_INTERNAL_LAYOUT is ignored; only single-pane tabs are created)
- Alacritty terminal support: auto-detected via `$TERM_PROGRAM` or `$ALACRITTY_SOCKET` environment variables
- New window creation via `alacritty msg create-window` (IPC, same process) when socket is available, falling back to launching a new `alacritty` process
- Alacritty mode has the same limitations as Ghostty mode: no pane layouts, no environment variable forwarding, no send-keys, no programmatic window queries or close

## [1.1.0] - 2026-02-18

### Added

- Ghostty terminal support: auto-detected when running outside tmux in Ghostty
- New tab creation via `open -a Ghostty` on macOS, `ghostty` CLI on Linux
- Automatic mode detection: tmux mode (inside tmux), Ghostty mode (Ghostty terminal), or unsupported
- `workspace open` inside a git worktree now lists worktree branches and remote branches via fzf, switching to or creating the selected worktree
- `workspace worktree setup` command to run `$WORKSPACE_INTERNAL_SETUP_CMD` in the current worktree

### Changed

- `open`, `close`, `remove`, `worktree create`, and `worktree prune` commands now adapt to the detected terminal mode
- tmux is no longer a hard requirement when using Ghostty

## [1.0.0] - 2026-02-11

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
