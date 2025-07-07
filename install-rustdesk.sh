#!/bin/bash

echo "Starting RustDesk .deb package download and installation for Kali Linux..."

# Fetch the entire JSON response from GitHub's latest release API
# -s makes curl silent, avoiding progress meters and error messages for cleaner output.
RUSTDESK_LATEST_JSON=$(curl -s "https://api.github.com/repos/rustdesk/rustdesk/releases/latest")

# ---
## Step 1: Validate GitHub API Response
# ---

# Check if curl command was successful and returned content.
# If RUSTDESK_LATEST_JSON is empty, something went wrong with fetching the data.
if [ -z "$RUSTDES_LATEST_JSON" ]; then
    echo "Error: Failed to retrieve release information from GitHub."
    echo "Please check your internet connection or verify the GitHub API status."
    exit 1
fi

# ---
## Step 2: Extract Download URL
# ---

# Attempt to extract the download URL for the amd64.deb file using grep with Perl-compatible Regular Expressions (PCRE).
# -o: Only output the matched part.
# -P: Enable PCRE. This is crucial for \K.
# "\K": Resets the starting point of the match, so only what follows is included in the output.
# "[^"]*": Matches any character that is NOT a double quote, zero or more times, effectively capturing the URL until the next quote.
# "\amd64\.deb": Ensures we only target the correct architecture and file type.
RUSTDESK_DOWNLOAD_URL=$(echo "$RUSTDESK_LATEST_JSON" | grep -oP '"browser_download_url": "\K[^"]*amd64\.deb' | head -n 1)

# Check if a URL was successfully extracted.
if [ -z "$RUSTDESK_DOWNLOAD_URL" ]; then
    echo "Error: Could not find the RustDesk amd64.deb download URL in the GitHub API response."
    echo "The naming convention might have changed, or the 'grep -P' command didn't find a match."
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

# Check if wget was successful (exit code 0 means success).
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