#!/bin/sh
set -e

REPO="sjdonado/workspace"
BINARY_NAME="workspace"
INSTALL_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { printf "${CYAN}[info]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[ok]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[warn]${NC} %s\n" "$1"; }
error() { printf "${RED}[error]${NC} %s\n" "$1"; exit 1; }

detect_os() {
  case "$(uname -s)" in
    Darwin*) OS="macos" ;;
    Linux*)  OS="linux" ;;
    *)       error "Unsupported OS: $(uname -s)" ;;
  esac
}

detect_shells() {
  FISH_CONFIG=""
  ZSH_CONFIG=""

  if [ -d "$HOME/.config/fish" ]; then
    FISH_CONFIG="$HOME/.config/fish/config.fish"
  fi

  if [ -f "$HOME/.zshrc" ]; then
    ZSH_CONFIG="$HOME/.zshrc"
  elif command -v zsh >/dev/null 2>&1; then
    ZSH_CONFIG="$HOME/.zshrc"
  fi
}

pick_install_dir() {
  if [ -w "$INSTALL_DIR" ]; then
    return
  fi

  # Try ~/.local/bin (no sudo needed)
  LOCAL_BIN="$HOME/.local/bin"
  if [ -d "$LOCAL_BIN" ] || mkdir -p "$LOCAL_BIN" 2>/dev/null; then
    INSTALL_DIR="$LOCAL_BIN"
    return
  fi

  # Fallback: use sudo for /usr/local/bin
  INSTALL_DIR="/usr/local/bin"
  USE_SUDO=1
}

download_binary() {
  DOWNLOAD_URL="https://raw.githubusercontent.com/${REPO}/main/bin/${BINARY_NAME}"
  TMP_FILE="$(mktemp)"

  info "Downloading ${BINARY_NAME} from ${REPO}..."

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_FILE" "$DOWNLOAD_URL"
  else
    error "curl or wget is required"
  fi

  chmod +x "$TMP_FILE"

  if [ "${USE_SUDO:-0}" = "1" ]; then
    info "Installing to ${INSTALL_DIR} (requires sudo)..."
    sudo mv "$TMP_FILE" "${INSTALL_DIR}/${BINARY_NAME}"
  else
    mv "$TMP_FILE" "${INSTALL_DIR}/${BINARY_NAME}"
  fi

  success "Installed ${BINARY_NAME} to ${INSTALL_DIR}/${BINARY_NAME}"
}

install_manpage() {
  MANPAGE_URL="https://raw.githubusercontent.com/${REPO}/main/man/${BINARY_NAME}.1"
  TMP_MAN="$(mktemp)"

  info "Downloading man page..."

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$MANPAGE_URL" -o "$TMP_MAN"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_MAN" "$MANPAGE_URL"
  else
    warn "curl or wget required for man page, skipping"
    return
  fi

  # Pick man page directory
  if [ "$OS" = "macos" ]; then
    MAN_DIR="/usr/local/share/man/man1"
  else
    MAN_DIR="/usr/local/share/man/man1"
  fi

  # Fallback to ~/.local/share/man if no write access
  if ! [ -w "$MAN_DIR" ] && [ "${USE_SUDO:-0}" != "1" ]; then
    MAN_DIR="$HOME/.local/share/man/man1"
  fi

  mkdir -p "$MAN_DIR" 2>/dev/null || true

  if [ "${USE_SUDO:-0}" = "1" ] && ! [ -w "$MAN_DIR" ]; then
    sudo mkdir -p "$MAN_DIR"
    sudo mv "$TMP_MAN" "${MAN_DIR}/${BINARY_NAME}.1"
  else
    mkdir -p "$MAN_DIR"
    mv "$TMP_MAN" "${MAN_DIR}/${BINARY_NAME}.1"
  fi

  success "Installed man page to ${MAN_DIR}/${BINARY_NAME}.1"

  # Ensure ~/.local/share/man is in MANPATH if we used it
  case "$MAN_DIR" in
    "$HOME"/.local/*)
      if [ -n "$FISH_CONFIG" ]; then
        if ! grep -qF 'set -gx MANPATH' "$FISH_CONFIG" 2>/dev/null || ! grep -qF '.local/share/man' "$FISH_CONFIG" 2>/dev/null; then
          printf '\nset -gx MANPATH "$HOME/.local/share/man" $MANPATH\n' >> "$FISH_CONFIG"
        fi
      fi
      if [ -n "$ZSH_CONFIG" ]; then
        if ! grep -qF '.local/share/man' "$ZSH_CONFIG" 2>/dev/null; then
          printf '\nexport MANPATH="$HOME/.local/share/man:$MANPATH"\n' >> "$ZSH_CONFIG"
        fi
      fi
      ;;
  esac
}

configure_fish() {
  if [ -z "$FISH_CONFIG" ]; then
    return
  fi

  FISH_BINDING='bind \cf "workspace open; commandline -f repaint"'

  if [ -f "$FISH_CONFIG" ] && grep -qF 'bind \cf "workspace open' "$FISH_CONFIG" 2>/dev/null; then
    warn "Fish binding already configured, skipping"
    return
  fi

  info "Configuring fish shell keybinding (Ctrl-F)..."

  mkdir -p "$(dirname "$FISH_CONFIG")"

  cat >> "$FISH_CONFIG" << 'EOF'

# workspace - tmux session manager (Ctrl-F to open)
if command -q workspace
    bind \cf "workspace open; commandline -f repaint"
end
EOF

  success "Fish keybinding added to ${FISH_CONFIG}"
}

configure_zsh() {
  if [ -z "$ZSH_CONFIG" ]; then
    return
  fi

  if [ -f "$ZSH_CONFIG" ] && grep -qF 'workspace-open-widget' "$ZSH_CONFIG" 2>/dev/null; then
    warn "Zsh binding already configured, skipping"
    return
  fi

  info "Configuring zsh keybinding (Ctrl-F)..."

  cat >> "$ZSH_CONFIG" << 'EOF'

# workspace - tmux session manager (Ctrl-F to open)
workspace-open-widget() {
  workspace open
  zle reset-prompt
}
zle -N workspace-open-widget
bindkey '^F' workspace-open-widget
EOF

  success "Zsh keybinding added to ${ZSH_CONFIG}"
}

ensure_path() {
  case ":$PATH:" in
    *":${INSTALL_DIR}:"*) return ;;
  esac

  warn "${INSTALL_DIR} is not in your PATH"

  if [ -n "$FISH_CONFIG" ]; then
    if ! grep -qF "fish_add_path ${INSTALL_DIR}" "$FISH_CONFIG" 2>/dev/null; then
      printf '\nfish_add_path %s\n' "$INSTALL_DIR" >> "$FISH_CONFIG"
      success "Added ${INSTALL_DIR} to fish PATH"
    fi
  fi

  if [ -n "$ZSH_CONFIG" ]; then
    if ! grep -qF "export PATH=\"${INSTALL_DIR}" "$ZSH_CONFIG" 2>/dev/null; then
      printf '\nexport PATH="%s:$PATH"\n' "$INSTALL_DIR" >> "$ZSH_CONFIG"
      success "Added ${INSTALL_DIR} to zsh PATH"
    fi
  fi
}

main() {
  info "Installing ${BINARY_NAME}..."

  detect_os
  detect_shells
  pick_install_dir
  download_binary
  install_manpage
  ensure_path
  configure_fish
  configure_zsh

  success "Installation complete!"
  printf "\n"
  info "Restart your shell or run:"

  if [ -n "$FISH_CONFIG" ]; then
    info "  source ${FISH_CONFIG}"
  fi
  if [ -n "$ZSH_CONFIG" ]; then
    info "  source ${ZSH_CONFIG}"
  fi
}

main
