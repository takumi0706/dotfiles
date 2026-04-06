#!/usr/bin/env bash
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# -----------------------------------------------------------
# 1. Nix のインストール（未インストール時）
# -----------------------------------------------------------
install_nix() {
  if command -v nix &>/dev/null; then
    echo "Nix is already installed."
    return
  fi

  echo "Installing Nix (Determinate Systems installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install

  # インストール直後に nix コマンドを使えるようにする
  # shellcheck disable=SC1091
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

# -----------------------------------------------------------
# 2. nix-darwin の初回ビルド & 適用
# -----------------------------------------------------------
apply_nix_config() {
  echo "Applying nix-darwin configuration..."
  cd "$DOTFILES_DIR"

  if command -v darwin-rebuild &>/dev/null; then
    darwin-rebuild switch --flake . --impure
  else
    # 初回: darwin-rebuild がまだ PATH にない
    # flake.lock で固定された nix-darwin を参照するため、ローカルの flake 入力を使用
    nix run nix-darwin -- switch --flake . --impure
  fi
}

# -----------------------------------------------------------
# 3. シンボリックリンク (.claude/ 等)
# -----------------------------------------------------------
run_setup() {
  echo "Running setup.sh for symlinks..."
  bash "$SCRIPT_DIR/setup.sh"
}

# -----------------------------------------------------------
# メイン
# -----------------------------------------------------------
main() {
  echo "=========================================="
  echo "  dotfiles installer (Nix)"
  echo "=========================================="

  install_nix
  apply_nix_config
  run_setup

  echo ""
  echo -e "\e[1;36m Install completed! \e[m"
  echo "Open a new shell to use the new environment."
}

main "$@"
