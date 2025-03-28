#!/bin/bash
########################################################################################################################
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
# ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
########################################################################################################################

# Set up locales
sudo locale-gen en_US en_US.UTF-8
sudo dpkg-reconfigure --frontend=noninteractive locales

# Install utilities
sudo apt-get install -y wslu # For WSL2
sudo apt-get install -y fd-find
sudo apt-get install -y bat
sudo apt-get install -y eza
sudo apt-get install -y git-delta
sudo apt-get install -y xdg-utils
sudo apt-get install -y build-essential
sudo apt-get install -y unzip

# Install development tools
sudo apt-get install -y git jq curl wget

# Install Neovim
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install -y neovim

# Install zsh
sudo apt-get install -y zsh
sudo chsh -s "$(which zsh)"
