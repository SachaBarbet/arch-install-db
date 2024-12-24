# Arch Forge

## Overview
Arch Forge is a powerful script designed to simplify the process of downloading, verifying (using signatures), and installing Arch Linux ISO files to a drive. Additionally, it allows users to customize the Arch live installation environment by adding custom content such as preset settings or additional packages. This tool is especially useful for beginners, Linux enthusiasts, and anyone looking to streamline the Arch Linux installation process.

## Features
- **Download & Verify**: Automatically download and verify Arch Linux ISOs with their GPG signatures.
- **Install Arch Linux**: Install Arch Linux to a drive with a simple command.
- **Custom Content Integration**: Add custom content (e.g., preset configurations, packages) to the Arch live installation environment.
- **Auto-Run Commands**: Execute commands at shell startup, allowing users to automate Arch Linux installations.

## Prerequisites
- **Required Tools**: `git`, `wget`, `gpg`, `dd`, `genisoimage`, `isohybrid`, `unsquashfs`, `mksquashfs`  
- **Root/Sudo Privileges**: Necessary to run certain commands and scripts.
- **Internet Connection**: Required to fetch Arch Linux ISO and GPG signatures.

## Installation
1. **Clone the Repository**  
   ```bash
   git clone https://github.com/sachabarbet/arch-forge.git
   cd arch-forge
2. **Run the Installation Script**
    ```bash
    chmod +x ./install.sh
    ./install.sh
## Configuration
- **Configuration File:**\
To customize Arch Forge, edit the install.conf file as needed. Check the Arch Linux download page for details on ISO URLs and version specifics.

## Contributing
Feel free to contribute by submitting issues, pull requests, or feature requests.

## License
Arch Forge is released under the **GPL-3.0**. See the [LICENSE](https://github.com/sachabarbet/arch-forge/blob/main/LICENSE) file for more information.
