#!/bin/bash
#
# Post-installation setup script for Kali Linux
# This script configures the system, installs essential tools, and sets up the user environment.

# --- System Variables ---
HOSTNAME="kali-00"
KALI_USER="kali"
KALI_HOME="/home/$KALI_USER"

# --- Basic System Configuration ---
echo "##"
echo "## Configuring basic system settings..."
echo "##"
# Set hostname
hostnamectl set-hostname $HOSTNAME || { echo "Failed to set hostname"; exit 1; }

# Update and upgrade the system
apt-get update -y || { echo "apt-get update failed"; exit 1; }
apt-get upgrade -y || { echo "apt-get upgrade failed"; exit 1; }
apt-get dist-upgrade -y || { echo "apt-get dist-upgrade failed"; exit 1; }

# Install essential packages
apt-get install -y \
    git \
    openvpn \
    seclists \
    terminator \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    curl \
    wget \
    net-tools \
    htop \
    neofetch \
    ufw \
    unattended-upgrades \
    virtualbox \
    qemu-kvm \
    libvirt-daemon-system \
    gobuster \
    sqlmap \
    john \
    theharvester

# --- User Environment Setup ---
echo "##"
echo "## Setting up the user environment for 'kali'..."
echo "##"

# Switch to Zsh for the kali user
chsh -s /usr/bin/zsh kali

# Create a .config directory if it doesn't exist
mkdir -p $KALI_HOME/.config


# Configure Zsh
cat <<EOT >> /home/kali/.zshrc
# Source the default zshrc if not already present
grep -qxF 'if [ -f /etc/zsh/zshrc ]; then' "$ZSHRC" || cat <<'EOT' >> "$ZSHRC"
# Source the default zshrc
if [ -f /etc/zsh/zshrc ]; then
    source /etc/zsh/zshrc
fi
EOT

# Aliases
grep -qxF "alias ll='ls -alF'" "$ZSHRC" || echo "alias ll='ls -alF'" >> "$ZSHRC"
grep -qxF "alias la='ls -A'" "$ZSHRC" || echo "alias la='ls -A'" >> "$ZSHRC"
grep -qxF "alias l='ls -CF'" "$ZSHRC" || echo "alias l='ls -CF'" >> "$ZSHRC"
grep -qxF "alias update='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y'" "$ZSHRC" || echo "alias update='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y'" >> "$ZSHRC"
grep -qxF "alias openvpn='sudo openvpn'" "$ZSHRC" || echo "alias openvpn='sudo openvpn'" >> "$ZSHRC"

# Add /usr/local/bin to PATH
grep -qxF 'export PATH=$PATH:/usr/local/bin' "$ZSHRC" || echo 'export PATH=$PATH:/usr/local/bin' >> "$ZSHRC"
EOT

# --- Tool and Directory Setup ---
echo "##"
echo "## Setting up tools and directories..."
echo "##"

# Create a directory for OpenVPN configurations
mkdir -p $KALI_HOME/vpn-configs

# Create a directory for your git repositories
mkdir -p $KALI_HOME/git-repos

# Create a share directory
mkdir -p $KALI_HOME/shares

# Install RustDesk
echo "## Installing RustDesk..."
RUSTDESK_LATEST=\$(curl -s "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" | grep -o "https.*amd64.deb")
wget \$RUSTDESK_LATEST -O /tmp/rustdesk.deb
apt-get install -y /tmp/rustdesk.deb
rm /tmp/rustdesk.deb

# Install Obsidian
echo "## Installing Obsidian..."
OBSIDIAN_LATEST=\$(curl -s "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" | grep -o "https.*amd64.deb")
wget \$OBSIDIAN_LATEST -O /tmp/obsidian.deb
apt-get install -y /tmp/obsidian.deb
rm /tmp/obsidian.deb

# Set correct permissions
chown -R kali:kali /home/kali/.config
chown -R kali:kali /home/kali/vpn-configs
chown -R kali:kali /home/kali/git-repos
chown -R kali:kali /home/kali/shares
chown kali:kali /home/kali/.zshrc

# --- Quality of Life Improvements ---
echo "##"
echo "## Applying quality of life improvements..."
echo "##"

# Disable screen lock
gsettings set org.gnome.desktop.session idle-delay 0

# Configure power settings to not suspend on AC power
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Enable and configure firewall
ufw enable
ufw default deny incoming
ufw default allow outgoing

# Enable automatic updates
dpkg-reconfigure -plow unattended-upgrades

echo ""
echo "##"
echo "## Post-installation setup complete!"
echo "## Please reboot your system for all changes to take effect."
echo "##"