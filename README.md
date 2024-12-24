# Enhanced Arch Install
**Enhanced Arch Install** simplifies and enhances the original Arch Linux installation process with additional functionalities tailored for personal use.

## 1. Features and Configuration of the Installer
### 1.1. Features
* Interactive CLI to prepare your installation medium with the installer already installed: :heavy_check_mark:
* Interactive CLI installer: :heavy_check_mark:
* Automatic CPU manufacturer detection for downloading and installing required microcode: :heavy_check_mark:
* Support for single and dual boot: :heavy_check_mark:
* Multi-drive support (planned for future updates): :heavy_multiplication_x:

### 1.2. Installer Configuration
* Encrypted partitions: :heavy_check_mark:
* LUKS format: :heavy_check_mark:
* Separate Root and Home partitions: :heavy_check_mark:
* SWAP Partition: :heavy_check_mark:
* Secure Boot for Arch Linux: :heavy_check_mark:
* Linux Kernel: **ZEN**
* Desktop Environment: **KDE Plasma**
* Unix Shell: **ZSH**
* Text Editor: **Neovim**
* Boot Manager: **GRUB**

## 2. System Requirements
### 2.1. Hardware
* Processor Architecture: **x64**
* Recommended Minimum Disk Size: **256GB**
* System Using **UEFI**
* *Currently does not support multiple disk drives*

### 2.2. Windows Configuration (For Dual Boot Mode) :window:
* Extended EFI Partition for GRUB (~2GB)
* 1GB Recovery Partition to recover from installation failures
* Disabled TPM Check
* Disabled RAM Check
* Disabled Secure Boot Check
* Disabled Fast Startup and Hibernation
* Free space on your hard drive (unallocated partition) to install Arch Linux
* Optionally, you can enable BitLocker (no restrictions)

## 3. Preparing BIOS/UEFI
To ensure a smooth Arch Linux installation, I recommend configuring your computer's BIOS/UEFI settings as follows:

* **For Windows and Arch Linux Installation:**
    * Disable Secure Boot and clear certificates
    * Disable VMD (if using an NVMe SSD)

* **Additional Recommendations:**
    * Set a root password to prevent unauthorized changes to BIOS settings
    * Disable boot from network (not commonly used)
    * Re-enable Secure Boot after installing Arch Linux

## 4. Installing Arch Linux :penguin:
(Provide detailed installation steps here in the future.)
Launch a vm on linux
qemu-system-x86_64 -cdrom enhanced_install_archlinux.iso -boot d -m 4G &
vncviewer localhost:5901 (vnc server port) &
In this configuration, the example.sh can be found in /run/archiso/bootmnt in the live env

## 5. Authors
[@sachabarbet](https://github.com/sachabarbet)
