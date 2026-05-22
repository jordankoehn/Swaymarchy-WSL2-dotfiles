#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

cd /tmp

# Define variables
VERSION="5.10.0"
URL="https://github.com/Qalculate/libqalculate/releases/download/v${VERSION}/qalculate-${VERSION}-x86_64.tar.xz"
ARCHIVE="qalculate-${VERSION}-x86_64.tar.xz"
EXTRACTED_DIR="qalculate-${VERSION}"

echo "Downloading Qalculate! v${VERSION}..."
wget -q --show-progress $URL

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Error: Download failed."
    exit 1
fi

echo "Extracting archive..."
tar -xJf $ARCHIVE

# Navigate into the extracted folder
# The binary is usually named 'qalc'
cd $EXTRACTED_DIR
./install