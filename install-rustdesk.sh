#!/bin/bash

echo "Starting RustDesk .deb package download and installation for Kali Linux..."

# Fetch the entire JSON response from GitHub's latest release API
# -s makes curl silent, avoiding progress meters and error messages for cleaner output.
RUSTDESK_LATEST_JSON=$(curl -s "https://api.github.com/repos/rustdesk/rustdesk/releases/latest")

# ---
## Step 1: Validate GitHub API Response
# ---

# Check if curl command was successful and returned content.
if [ -z "$RUSTDESK_LATEST_JSON" ]; then
    echo "Error: Failed to retrieve release information from GitHub. Check your internet connection or the GitHub API status."
    exit 1
fi

# ---
## Step 2: Extract Download URL
# ---

# *** CORRECTION HERE: Changed 'amd64.deb' to 'x86_64.deb' in the regex. ***
# Also, filtering by 'name' first is more precise than just looking in the URL.
RUSTDESK_DOWNLOAD_URL=$(echo "$RUSTDESK_LATEST_JSON" | \
  grep -oP '"name": "rustdesk-[^"]*x86_64\.deb",.*?"browser_download_url": "\K[^"]*' | head -n 1)

# Explanation of the new grep regex:
# '"name": "rustdesk-[^"]*x86_64\.deb",': This looks for the asset name field
#                                         that contains 'rustdesk-' followed by anything,
#                                         then 'x86_64.deb'. This is more robust as it
#                                         directly targets the name field.
# '.*?"browser_download_url": "': Matches any characters non-greedily (.*?) until it finds
#                                  the 'browser_download_url' key.
# '\K': Resets the match, so only what follows is captured.
# '[^"]*': Captures the URL itself, which is any character not a double quote.


# Check if a URL was successfully extracted
if [ -z "$RUSTDESK_DOWNLOAD_URL" ]; then
    echo "Error: Could not find the RustDesk x86_64.deb download URL in the GitHub API response."
    echo "The naming convention might have changed, or grep -P is not available/working as expected."
    echo "For a more robust solution, consider installing 'jq' (sudo apt install jq) for JSON parsing."
    exit 1
fi

echo "Successfully identified RustDesk download URL: $RUSTDESK_DOWNLOAD_URL"

# ---
## Step 3: Download the .deb Package
# ---

# Download the .deb package to the /tmp directory.
# -O: Specifies the output filename and location.
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
# -i: Installs the package.
# --skip-same-version: Useful if you run the script multiple times to avoid re-installing the same version.
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