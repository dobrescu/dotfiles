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

ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/nvim" "$HOME_CONFIG_DIR/"
ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

mkdir -p "$HOME/.local/bin"

########################################################################################################################
##### fzf
function installfzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install

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
  curl -Lo /tmp/tokyonight.tmTheme https://raw.githubusercontent.com/folke/tokyonight.nvim/master/extras/sublime/tokyonight.tmTheme
  cp /tmp/tokyonight.tmTheme "$BAT_THEME_DIR/"
  rm /tmp/tokyonight.tmTheme

  # Rebuild bat's theme cache
  bat cache --build

  ln -sf $DOTFILES_CONFIG_DIR/bat/config $(bat --config-dir)/
}
setupBat

########################################################################################################################
##### starship
function installStarship() {
  curl -sS https://starship.rs/install.sh | sh
  ln -sf $DOTFILES_CONFIG_DIR/starship.toml $HOME_CONFIG_DIR
}
checkcommand "fzf" installStarship

########################################################################################################################
##### Deno
function installDeno() {
  curl -fsSL https://deno.land/install.sh | sh
}
checkcommand "deno" installDeno

########################################################################################################################
##### Zoxide
function installZoxide() {
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}
checkcommand "zoxide" installZoxide

########################################################################################################################
