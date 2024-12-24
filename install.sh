#!/bin/bash

# Default configuration file path
CONFIG_FILE="./install.conf"

# Colors for styling
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"  # No Color

# Function to load configuration
load_config() {
    echo -ne "${BLUE}Loading configuration file...${NC}\r"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${RED}Error:${NC} Configuration file $CONFIG_FILE not found."
        exit 1
    fi

    # Load configuration variables
    source "$CONFIG_FILE"
    
    # Ensure DOWNLOAD_DIR is a relative path
    if [[ "$DOWNLOAD_DIR" == /* ]]; then
        echo -e "${RED}Error:${NC} DOWNLOAD_DIR must be a relative path."
        exit 1
    fi

    echo -ne "${GREEN}Configuration file loaded successfully.${NC}\n"
}

# Function to check for necessary commands
check_dependencies() {
    for cmd in wget gpg dd genisoimage isohybrid; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${RED}Error:${NC} $cmd is not installed. Please install it and try again."
            exit 1
        fi
    done
}

# Function to prepare the download directory
prepare_download_dir() {
    if [[ ! -d "$DOWNLOAD_DIR" ]]; then
        echo -e "${BLUE}Creating download directory:${NC} $DOWNLOAD_DIR"
        mkdir -p "$DOWNLOAD_DIR"
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Error:${NC} Failed to create directory $DOWNLOAD_DIR."
            exit 1
        fi
    fi
}

# Function to download Arch Linux ISO
download_iso() {
    if [[ -f "$DOWNLOAD_DIR/archlinux-x86_64.iso" ]]; then
        read -p "The ISO file is already in '$DOWNLOAD_DIR' directory. Do you want to re-download it ? (Y/n): " choice
        if [[ "$choice" != "Y" ]]; then
            echo -e "${GREEN}Using existing ISO file from '$DOWNLOAD_DIR' directory.${NC}"
            return 0
        fi
    fi

    echo -ne "${BLUE}Downloading Arch Linux ISO file to '$DOWNLOAD_DIR' directory...${NC}\r"
    wget -q -N "$ISO_URL" -O "$DOWNLOAD_DIR/archlinux-x86_64.iso"
    echo -ne "${GREEN}Arch Linux ISO file downloaded to '$DOWNLOAD_DIR' directory.   ${NC}\n"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to download ISO file."
        exit 1
    fi
}

# Function to download Arch Linux signature
download_signature() {
    if [[ -f "$DOWNLOAD_DIR/archlinux-x86_64.iso.sig" ]]; then
        read -p "The signature file is already in '$DOWNLOAD_DIR' directory. Do you want to re-download it ? (Y/n): " choice
        if [[ "$choice" != "Y" ]]; then
            echo -e "${GREEN}Using existing signature file from '$DOWNLOAD_DIR' directory.${NC}"
            return 0
        fi
    fi

    echo -ne "${BLUE}Downloading Arch Linux signature file to '$DOWNLOAD_DIR' directory...${NC}\r"
    wget -q -N "$ISO_SIG_URL" -O "$DOWNLOAD_DIR/archlinux-x86_64.iso.sig"
    echo -ne "${GREEN}Arch Linux signature file downloaded to '$DOWNLOAD_DIR' directory.   ${NC}\n"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to download signature file."
        exit 1
    fi
}

# Function to verify the ISO signature
verify_iso() {
    echo -ne "${BLUE}Verifying ISO signature...${NC}\r"
    gpg --quiet --keyserver-options auto-key-retrieve --verify "$DOWNLOAD_DIR/archlinux-x86_64.iso.sig" "$DOWNLOAD_DIR/archlinux-x86_64.iso" &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} ISO signature verification failed."
        exit 1
    fi
    echo -ne "${GREEN}ISO signature verified successfully using gpg.${NC}\n"
}

# Function to list drives and get user selection
select_drive() {
    echo -e "${BLUE}Available drives:${NC}"
    lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -v loop | while read -r line; do
        echo -e "$line"
    done

    while true; do
        read -p "Enter the drive to install Arch Linux (e.g., /dev/sdX): " drive

        # Ajouter le préfixe "/dev/" si nécessaire
        if [[ "$drive" != /dev/* ]]; then
            drive="/dev/$drive"
        fi

        if [[ -b "$drive" ]]; then
            if [[ "$(lsblk -dno RM "$drive")" != "1" ]]; then
                echo -e "${RED}Warning:${YELLOW} The selected drive is not a removable medium.${NC}"
            fi

            read -p "Are you sure you want to write to $drive? This will erase all data. (Y/n): " confirm
            if [[ "$confirm" == "Y" ]]; then
                echo -e "${GREEN}Drive selected:${NC} $drive"
                break
            fi
        else
            echo -e "${RED}Invalid drive. Please try again.${NC}"
        fi
    done
}

# Function to edit the archiso, this add the custom script to it
customize_iso() {
    if [[ -z "${TOINSTALL_PATH// }" ]]; then
        echo "${YELLOW}No path specified to install a script on the installation medium.${NC}"
        return 0
    fi

    if [[ -d "$TOINSTALL_PATH" && -z "$(ls -A "$TOINSTALL_PATH")" ]]; then
        echo -e "${RED}Error:${NC} Folder '$TOINSTALL_PATH' is empty."
        exit 1
    fi

    echo -ne "${BLUE}Extracting ISO...${NC}\r"
    mkdir -p iso_workdir
    mkdir -p /mnt/work_iso
    sudo mount -o loop "$DOWNLOAD_DIR/archlinux-x86_64.iso" /mnt/work_iso &> /dev/null
    cp -r /mnt/work_iso/* iso_workdir/
    sudo umount /mnt/work_iso
    rm -rf /mnt/work_iso
    echo -ne "${GREEN}ISO extracted.      ${NC}\n"

    # Install the script
    echo -ne "${BLUE}Copying '$TOINSTALL_PATH' to the extracted iso...${NC}\r"
    if [[ -f "$TOINSTALL_PATH" ]]; then
        cp "$TOINSTALL_PATH" iso_workdir/
    fi

    if [[ -d "$TOINSTALL_PATH" ]]; then
        cp -r "$TOINSTALL_PATH"/* iso_workdir/
    fi
    echo -ne "${GREEN}'$TOINSTALL_PATH' copied successfully.           ${NC}\n"

    echo -ne "${GREEN}Rebuilding ISO...${NC}\r"
    genisoimage -o "enhanced_install_archlinux.iso" \
        -b boot/syslinux/isolinux.bin \
        -c boot/syslinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -J -R -V "ENHANCED_ARCH_INSTALL" iso_workdir &> /dev/null

    isohybrid "enhanced_install_archlinux.iso" &> /dev/null
    echo -ne "${GREEN}ISO rebuilded (enhanced_install_archlinux.iso).${NC}\n"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to copy '$TOINSTALL_PATH' to the drive."
        sudo umount /mnt/work_iso
        rm -rf /mnt/work_iso
        rm -rf iso_workdir
        exit 1
    fi
}

# Function to write ISO to drive
write_iso_to_drive() {
    echo -ne "${BLUE}Writing ISO to $drive...${NC}\r"
    sudo dd if="enhanced_install_archlinux.iso" of="$drive" bs=4M status=progress oflag=sync &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to write ISO to drive."
        exit 1
    fi
    echo -ne "${GREEN}ISO successfully written to $drive.${NC}\n"
}

echo -e "${BLUE}Welcome in this installer. Let's start preparing your installation medium for Arch Linux!${NC}"
echo -e "${BLUE}There is some parameters in the 'install.conf' file if you need to customize your installation!${NC}"

# Main script execution
load_config
check_dependencies
prepare_download_dir
download_iso
download_signature
verify_iso
select_drive
customize_iso
write_iso_to_drive

echo -e "${GREEN}Creation of your installation medium completed successfully!${NC}"
