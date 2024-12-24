#!/bin/bash

# Echo initial message
echo -ne "Downloading...\r"

# Simulate the download process (replace this with your actual download command)
# Example using wget (uncomment if needed):
# wget https://example.com/file.zip

# Simulating download completion using sleep
sleep 5  # Replace with your actual download command

# Once the download is complete, overwrite the message
echo -ne "Download complete! File has been downloaded.\n"
read -p "Enter to continue" choice