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
