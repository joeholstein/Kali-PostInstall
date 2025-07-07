#!/bin/zsh
#
# Install RustDesk
echo "## Installing RustDesk..."
RUSTDESK_LATEST=\$(curl -s "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" | grep -o "https.*amd64.deb")
wget \$RUSTDESK_LATEST -O /tmp/rustdesk.deb
apt-get install -y /tmp/rustdesk.deb
rm /tmp/rustdesk.deb