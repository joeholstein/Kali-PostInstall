#!/bin/bash

echo "Starting RustDesk .deb package download and installation for Kali Linux using jq..."

# ---
## Step 0: Check for and install jq
# ---
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Attempting to install jq..."
    sudo apt update
    sudo apt install -y jq
    if ! command -v jq &> /dev/null; then
        echo "Error: Failed to install jq. Please install jq manually (sudo apt install jq) and try again."
        exit 1
    fi
    echo "jq installed successfully."
fi

# ---
## Step 1: Fetch GitHub API Response
# ---

# Fetch the entire JSON response from GitHub's latest release API
RUSTDESK_LATEST_JSON=$(curl -s "https://api.github.com/repos/rustdesk/rustdesk/releases/latest")

# Check if curl command was successful and returned content
if [ -z "$RUSTDESK_LATEST_JSON" ]; then
    echo "Error: Failed to retrieve release information from GitHub. Check your internet connection or the GitHub API status."
    exit 1
fi

# ---
## Step 2: Extract Download URL using jq
# ---

# Use jq to parse the JSON and find the browser_download_url for the x86_64.deb asset.
# .assets[]: iterate over each asset in the 'assets' array.
# select(.name | contains("x86_64.deb")): filter for assets whose 'name' contains "x86_64.deb".
# .browser_download_url: extract the download URL from the selected asset.
# -r: output raw strings (without JSON quotes).
RUSTDESK_DOWNLOAD_URL=$(echo "$RUSTDESK_LATEST_JSON" | jq -r '.assets[] | select(.name | contains("x86_64.deb")) | .browser_download_url')

# Check if a URL was successfully extracted
if [ -z "$RUSTDESK_DOWNLOAD_URL" ]; then
    echo "Error: Could not find the RustDesk x86_64.deb download URL using jq."
    echo "This might mean the naming convention for the Debian package has changed."
    exit 1
fi

echo "Successfully identified RustDesk download URL: $RUSTDESK_DOWNLOAD_URL"

# ---
## Step 3: Download the .deb Package
# ---

# Download the .deb package to the /tmp directory.
wget "$RUSTDESK_DOWNLOAD_URL" -O /tmp/rustdesk.deb

# Check if wget was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download rustdesk.deb using wget."
    echo "Please verify the download URL or your network connection."
    exit 1
fi

echo "RustDesk .deb package downloaded to /tmp/rustdesk.deb"

# ---
## Step 4: Install and Resolve Dependencies
# ---

echo "Attempting to install RustDesk and resolve any missing dependencies..."

# Install RustDesk using dpkg.
sudo dpkg -i /tmp/rustdesk.deb

# After a direct 'dpkg -i' install, dependencies are often not met.
# 'apt --fix-broken install' will automatically download and install any missing dependencies.
echo "Running 'apt --fix-broken install' to resolve any unmet dependencies..."
sudo apt --fix-broken install -y

# Re-run 'dpkg --configure' on the rustdesk package. This ensures the package is fully configured
# now that its dependencies are satisfied.
echo "Re-configuring RustDesk package to complete installation..."
sudo dpkg --configure rustdesk

echo "RustDesk installation process completed successfully."
echo "You should now be able to find RustDesk in your applications menu."

# ---
## Step 5: Clean Up (Optional)
# ---

# Uncomment the line below if you want to automatically remove the downloaded .deb file.
# rm /tmp/rustdesk.deb