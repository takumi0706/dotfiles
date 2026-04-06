#!/usr/bin/env bash
set -ueo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# アーキテクチャに応じた flake attribute を決定
get_flake_attr() {
  if [ "$(uname -m)" = "x86_64" ]; then
    echo "default-x86"
  else
    echo "default"
  fi
}

# -----------------------------------------------------------
# 1. Nix のインストール（未インストール時）
# -----------------------------------------------------------
install_nix() {
  if command -v nix &>/dev/null; then
    echo "Nix is already installed."
    return
  fi

  echo "Installing Nix (Determinate Systems installer)..."
  local installer
  installer="$(mktemp)"
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix -o "$installer"
  sh "$installer" install
  rm -f "$installer"

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

  # flake.nix の dotfilesDir は $HOME/dotfiles 固定のため、
  # リポジトリが別の場所にある場合はエラーにする
  local expected="$HOME/dotfiles"
  if [ "$DOTFILES_DIR" != "$expected" ]; then
    echo "Error: dotfiles must be at $expected (currently at $DOTFILES_DIR)" >&2
    echo "Run: ln -s $DOTFILES_DIR $expected" >&2
    exit 1
  fi

  cd "$DOTFILES_DIR"

  local attr
  attr="$(get_flake_attr)"

  if command -v darwin-rebuild &>/dev/null; then
    darwin-rebuild switch --flake ".#${attr}" --impure
  else
    # 初回: darwin-rebuild がまだ PATH にない
    # .#darwinConfigurations.${attr}.system を build して
    # ローカル flake.lock に固定された nix-darwin を使用
    local tmp_dir out_link
    tmp_dir="$(mktemp -d)"
    out_link="${tmp_dir}/result"
    # shellcheck disable=SC2064
    trap "rm -rf -- '$tmp_dir'" EXIT
    nix build ".#darwinConfigurations.${attr}.system" --impure --out-link "$out_link"
    "$out_link/sw/bin/darwin-rebuild" switch --flake ".#${attr}" --impure
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
