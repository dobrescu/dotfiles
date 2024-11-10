sudo locale-gen en_US en_US.UTF-8
sudo dpkg-reconfigure locales
sudo apt-get install -y wslu # For WSL2
sudo apt-get install -y fd-find
sudo apt install bat
sudo apt-get install eza
sudo apt-get install git-delta

sudo apt-get install -y git jq curl wget

sudo apt-get install xdg-utils

sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
