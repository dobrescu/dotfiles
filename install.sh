#!/bin/bash
########################################################################################################################
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
# ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
########################################################################################################################

set -xe
DOTFILES_DIR="$HOME/dotfiles"
HOME_CONFIG_DIR="$HOME/.config"
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/config"

# shellcheck source=/dev/null
source "$HOME/dotfiles/zsh/utils.sh"

mkdir -p "$HOME/.config"

ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/nvim" "$HOME_CONFIG_DIR/"

for file in "$DOTFILES_DIR/git"/.gitconfig*; do
  ln -sf "$file" "$HOME/$(basename "$file")"
done

mkdir -p "$HOME/.local/bin"

########################################################################################################################
##### node
function installNode() {
  # Install NVM if not installed
  if ! command -v nvm &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi

  # Install latest LTS version of Node.js
  nvm install --lts

  # Use latest LTS version by default
  nvm alias default 'lts/*'
}
checkcommand "node" installNode

########################################################################################################################
##### starship
function installStarship() {
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  ln -sf $DOTFILES_CONFIG_DIR/starship.toml $HOME_CONFIG_DIR
}
checkcommand "fzf" installStarship

########################################################################################################################
##### fzf
function installfzf() {
  [ -d ~/.fzf ] && rm -rf ~/.fzf
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all

  curl -Lo ~/.fzf/fzf-git.sh https://raw.githubusercontent.com/junegunn/fzf-git.sh/master/fzf-git.sh
}
checkcommand "fzf" installfzf

########################################################################################################################
##### fdfind
ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
ln -sf $DOTFILES_DIR/fd/.fdignore $HOME/.fdignore

########################################################################################################################
##### bat
function setupBat() {
  ln -sf /usr/bin/batcat ~/.local/bin/bat

  BAT_THEME_DIR="$(bat --config-dir)/themes"
  mkdir -p "$BAT_THEME_DIR"

  # Download tokyo-night theme
  curl -Lo /tmp/tokyonight.tmTheme https://raw.githubusercontent.com/folke/tokyonight.nvim/refs/heads/main/extras/sublime/tokyonight_night.tmTheme
  cp /tmp/tokyonight.tmTheme "$BAT_THEME_DIR/"
  rm /tmp/tokyonight.tmTheme

  # Rebuild bat's theme cache
  bat cache --build

  ln -sf $DOTFILES_CONFIG_DIR/bat/config $(bat --config-dir)/
}
setupBat

########################################################################################################################
##### Deno
function installDeno() {
  curl -fsSL https://deno.land/install.sh | sh -s -- --yes
}
checkcommand "deno" installDeno

########################################################################################################################
##### Zoxide
function installZoxide() {
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}
checkcommand "zoxide" installZoxide

########################################################################################################################
