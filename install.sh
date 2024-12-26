#!/bin/bash
set -euo pipefail # Stop this script if a command fail, a variable is empty or a pipe isn't fully successfull

CONFIG_FILE="./install.conf" # Default configuration file path
ISO_WORKDIR="./iso_workdir" # Default directory to extracted iso
TOINSTALL_DIR="./to_install" # To install path
DOWNLOAD_DIR="./downloads" # Directory for downloaded files (iso and signature)
MNT_ARCHISO="/mnt/archiso" # Mount point to extracted archlinux iso
COMMANDS_DEPENDENCIES=("wget" "gpg" "dd" "genisoimage" "isohybrid" "unsquashfs" "mksquashfs") # Commands dependencies
LOG_FILE="./arch_forge.log"

# Colors for styling
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"  # No Color

log() {
    local level="$1"
    shift
    local message="$@"
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

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

    echo -e "${GREEN}Configuration file loaded successfully.${NC}"
}

# Function to check for necessary commands
check_dependencies() {
    local missing=()
    for cmd in "${COMMANDS_DEPENDENCIES[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    for cmd in "${COMMANDS_DEPENDENCIES[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${RED}Error:${NC} $cmd is not installed. Please install it and try again."
            exit 1
        fi
    done
}

# Function to prepare the download directory
prepare_download_dir() {
    if [[ ! -d "$DOWNLOAD_DIR" ]]; then
        mkdir -p "$DOWNLOAD_DIR"
        echo -e "${GREEN}Download directory created:${NC} $DOWNLOAD_DIR"
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
    echo -e "${GREEN}Arch Linux ISO file downloaded to '$DOWNLOAD_DIR' directory.   ${NC}"

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
    echo -e "${GREEN}Arch Linux signature file downloaded to '$DOWNLOAD_DIR' directory.   ${NC}"

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
    echo -e "${GREEN}ISO signature verified successfully using gpg.${NC}"
}

# Function to list drives and get user selection
select_drive() {
    echo -e "${BLUE}Available drives:${NC}"
    lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -v loop | while read -r line; do
        echo -e "$line"
    done

    while true; do
        read -p "Enter the drive to install Arch Linux (e.g., /dev/sdX): " drive

        # Add "/dev/" prefix if needed
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

# Function to extract the archlinux iso
extract_iso() {
    echo -ne "${BLUE}Extracting ISO...${NC}\r"
    mkdir -p $ISO_WORKDIR
    mkdir -p $MNT_ARCHISO
    sudo mount -o loop "$DOWNLOAD_DIR/archlinux-x86_64.iso" $MNT_ARCHISO &> /dev/null
    cp -r $MNT_ARCHISO/* $ISO_WORKDIR/
    sudo umount $MNT_ARCHISO
    sudo rm -rf $MNT_ARCHISO
    echo -e "${GREEN}ISO extracted.      ${NC}"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to extract iso."
        sudo umount $MNT_ARCHISO
        sudo rm -rf $MNT_ARCHISO
        rm -rf $ISO_WORKDIR
        exit 1
    fi
}

# Function to extract, edit the airootfs and build it
edit_airootfs() {
    # Install the to_install folder in airootfs
    echo -ne "${BLUE}Extract airootfs...${NC}\r"
    sudo unsquashfs -f $ISO_WORKDIR/arch/x86_64/airootfs.sfs &> /dev/null
    echo -e "${GREEN}Airootfs extracted.${NC}"


    echo -ne "${BLUE}Copying '$TOINSTALL_DIR' to the extracted iso...${NC}\r"
    cp -r "$TOINSTALL_DIR"/* squashfs-root/usr/bin
    sudo chroot squashfs-root /bin/bash -c "
        chmod -R +x /usr/bin
        exit
    " &> /dev/null
    echo -e "${GREEN}'$TOINSTALL_DIR' copied successfully.           ${NC}"

    echo -ne "${BLUE}Rebuild airootfs...${NC}\r"
    sudo rm -rf $ISO_WORKDIR/arch/x86_64/airootfs.sfs
    sudo mksquashfs squashfs-root $ISO_WORKDIR/arch/x86_64/airootfs.sfs -comp xz &> /dev/null
    echo -e "${GREEN}Airootfs rebuilt.    ${NC}"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to copy '$TOINSTALL_DIR' to the drive."
        rm -rf $ISO_WORKDIR
        exit 1
    fi
}

# Function to compile airootfs and rebuild iso
build_iso() {
    echo -ne "${BLUE}Rebuilding ISO...${NC}\r"
    genisoimage -o "enhanced_install_archlinux.iso" \
        -b boot/syslinux/isolinux.bin \
        -c boot/syslinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -J -R -V "ENHANCED_ARCH_INSTALL" $ISO_WORKDIR &> /dev/null

    isohybrid "enhanced_install_archlinux.iso" &> /dev/null
    echo -e "${GREEN}ISO rebuilt (enhanced_install_archlinux.iso).${NC}"
}

# Function to write ISO to drive
write_iso_to_drive() {
    echo -ne "${BLUE}Writing ISO to $drive...${NC}\r"
    sudo dd if="enhanced_install_archlinux.iso" of="$drive" bs=4M status=progress oflag=sync &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Failed to write ISO to drive."
        exit 1
    fi
    echo -e "${GREEN}ISO successfully written to $drive.${NC}"
    sudo rm -rf $ISO_WORKDIR
    sudo rm -rf squashfs-root
}

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}This script must be run with privileges. Please use sudo.${NC}"
  exit 1
fi

load_config
check_dependencies

echo -e "${BLUE}Welcome in this installer. Let's start preparing your installation medium for Arch Linux!${NC}"
echo -e "${BLUE}There is some parameters in the 'install.conf' file if you need to customize your installation!${NC}"

# Main script execution
prepare_download_dir
download_iso
download_signature
verify_iso
select_drive

rm $TOINSTALL_DIR/.gitkeep &> /dev/null # Prevent the .gitkeep file to be copied in the new iso file
# If 'To install' folder is empty, we just write iso to drive
if [[ -z "$(ls -A "$TOINSTALL_DIR")" ]]; then
    read -p "Folder '$TOINSTALL_DIR' is empty. Do you want to continue ? (Y/n)" choice
    if [[ "$choice" != "Y" ]]; then
        exit 0
    fi
else
    extract_iso
    edit_airootfs
    build_iso
fi
touch $TOINSTALL_DIR/.gitkeep

write_iso_to_drive

echo -e "${GREEN}Creation of your installation medium completed successfully!${NC}"
