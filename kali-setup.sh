#!/bin/zsh
#
# Post-installation setup script for Kali Linux
# This script configures the system, installs essential tools, and sets up the user environment.

# --- System Variables ---
HOSTNAME="kali-00"
KALI_USER="kali"
KALI_HOME="/home/$KALI_USER"

# --- User Environment Setup ---
echo "##"
echo "## Setting up the user environment for 'kali'..."
echo "##"

# Aliases
grep -qxF "alias ll='ls -alF'" "$ZSHRC" || echo "alias ll='ls -alF'" >> "$ZSHRC"
grep -qxF "alias la='ls -A'" "$ZSHRC" || echo "alias la='ls -A'" >> "$ZSHRC"
grep -qxF "alias l='ls -CF'" "$ZSHRC" || echo "alias l='ls -CF'" >> "$ZSHRC"
grep -qxF "alias update='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y'" "$ZSHRC" || echo "alias update='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y'" >> "$ZSHRC"
grep -qxF "alias openvpn='sudo openvpn'" "$ZSHRC" || echo "alias openvpn='sudo openvpn'" >> "$ZSHRC"

# Create a .config directory if it doesn't exist
mkdir -p $KALI_HOME/.config

# Create a directory for OpenVPN configurations
mkdir -p $KALI_HOME/vpn-configs

# Create a directory for your git repositories
mkdir -p $KALI_HOME/git-repos

# Create a share directory
mkdir -p $KALI_HOME/shares

# Set correct permissions
chown -R kali:kali /home/kali/.config
chown -R kali:kali /home/kali/vpn-configs
chown -R kali:kali /home/kali/git-repos
chown -R kali:kali /home/kali/shares

# Disable screensaver and lock screen
xfconf-query -c xfce4-session -p /general/LockCommand -s ""
xfconf-query -c xfce4-session -p /general/LockScreen -s false

# Disable light-locker
xfconf-query -c xfce4-session -p /general/LockCommand -s "xflock4" # Set it back to default first if it was changed
xfconf-query -c light-locker -p /lock-on-suspend -s false
xfconf-query -c light-locker -p /lock-after-screensaver -s false
xfconf-query -c light-locker -p /idle-delay -s 0

# Disable Power Manager
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0 # Disable screen blanking
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-timeout -s 0 # Disable DPMS timeout
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -s 0 # Do nothing when lid closed on AC
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -s 0 # Do nothing on inactivity

# Enable and configure firewall
ufw enable
ufw default deny incoming
ufw default allow outgoing

# Update and upgrade the system
apt-get update -y || { echo "apt-get update failed"; exit 1; }
apt-get upgrade -y || { echo "apt-get upgrade failed"; exit 1; }
apt-get dist-upgrade -y || { echo "apt-get dist-upgrade failed"; exit 1; }

# Install essential packages
apt-get install -y \
    qemu-guest-agent \
    spice-vdagent \
    openvpn \
    neofetch \
    unattended-upgrades \
    qemu-kvm \
    gobuster \
    sqlmap \
    john \
    theharvester \
    magic-wormhole \
    libreoffice \
    gimp \
    vlc \
    thunderbird \
    code-oss \
    obsidian \
    rustdesk \
    
# Enable automatic updates
dpkg-reconfigure -plow unattended-upgrades

echo ""
echo "##"
echo "## Post-installation setup complete!"
echo "## Please reboot your system for all changes to take effect."
echo "##"