# Set up locales
sudo locale-gen en_US en_US.UTF-8
sudo dpkg-reconfigure locales

# Install utilities
sudo apt-get install -y wslu # For WSL2
sudo apt-get install -y fd-find
sudo apt-get install -y bat
sudo apt-get install -y eza
sudo apt-get install -y git-delta
sudo apt-get install -y xdg-utils

# Install development tools
sudo apt-get install -y git jq curl wget

# Install Neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install -y neovim
