#!/bin/zsh
#
# Post-installation setup script for Kali Linux
# This script configures the system, installs essential tools, and sets up the user environment.

# --- System Variables ---
HOSTNAME="kali-00"
KALI_USER="kali"
KALI_HOME="/home/$KALI_USER"

# Create a .config directory if it doesn't exist
mkdir -p $KALI_HOME/.config

# Update and upgrade the system
apt-get update -y || { echo "apt-get update failed"; exit 1; }
apt-get upgrade -y || { echo "apt-get upgrade failed"; exit 1; }
apt-get dist-upgrade -y || { echo "apt-get dist-upgrade failed"; exit 1; }
