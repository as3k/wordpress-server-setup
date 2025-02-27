#!/bin/bash

# Make sure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (or use sudo)"
  exit 1
fi

# Update package list and install required packages
echo "Updating package list..."
apt-get update

echo "Installing nginx, MariaDB, PHP, and required PHP extensions..."
apt-get install -y nginx mariadb-server php-fpm php-mysql php-cli php-curl php-gd php-xml php-mbstring curl unzip

echo "Installing additional utilities: neovim, zsh, git, and certbot with nginx plugin..."
apt-get install -y neovim git certbot python3-certbot-nginx

# Setup custom MOTD
echo "Setting up custom MOTD..."
cp motd_update.sh /etc/update-motd.d/99-custom
chmod +x /etc/update-motd.d/99-custom

# Determine the non-root user (if running via sudo, use SUDO_USER; otherwise, current user)
if [ -n "$SUDO_USER" ]; then
  USERNAME="$SUDO_USER"
else
  USERNAME="$(whoami)"
fi

# Setup new ssh keys
echo "Setting up new SSH keys..."
ssh-keygen -t rsa -b 4096 -C "$USERNAME@$(hostname)" -f ~/.ssh/id_rsa -N ""
echo "New SSH keys have been generated."
echo ""

# Setup Global Git Config
echo "Setting up global git configuration..."
read -p "Enter your name: " GIT_NAME
read -p "Enter your email: " GIT_EMAIL
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"
echo "Global git configuration set."
echo ""

# Secure MariaDB with a basic non-interactive process
echo "Let's secure your MariaDB installation."
read -s -p "Enter new password for MariaDB root user: " MYSQL_ROOT_PASS
echo ""

echo "Securing MariaDB..."
mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASS') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# Setup ZSH and oh-my-zsh if desired
read -p "Do you want to install and configure zsh and oh-my-zsh? (y/N): " ZSH
if [[ "$ZSH" =~ ^[Yy] ]]; then
  USE_ZSH=true
  echo "zsh and oh-my-zsh setup will proceed."
  echo "Installing zsh..."
  apt-get install -y zsh
  echo "zsh installed."

  # Install oh-my-zsh non-interactively for the current user
  echo "Installing oh-my-zsh..."

  export RUNZSH=no
  export CHSH=no
  sudo -u "$USERNAME" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # Set zsh as the default shell for the non-root user
  echo "Setting zsh as the default shell for $USERNAME..."
  chsh -s "$(which zsh)" "$USERNAME"
else
  USE_ZSH=false
  echo "Skipping zsh and oh-my-zsh setup."
fi
export USE_ZSH

echo "Server setup complete! Next, run the wordpress_setup.sh script to install WordPress."
echo ""