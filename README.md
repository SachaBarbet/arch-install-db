# arch-install-db
A bash script designed to install a predefined environment of the Arch Linux operating system in dual boot with a Windows 10/11 operating system.
This script replace the archinstall command available in an arch live boot environnement (installation media).
This script provides a less customizable but more robust and effective installation for this context.
We can also found an `autounattend.xml` file for an automated installation of Windows with required and recommended configurations to suit a dual boot with Arch Linux.

## Table of contents
1. [Configuration / Features](#1-configurations-and-features)
    1. [Script features](#11-script-features)
    2. [Windows configuration](#12-windows-configuration-window)
    3. [Arch Linux configuration](#13-arch-linux-configuration-penguin)
2. [System requirements](#2-system-requirements)
3. [Prepare BIOS / UEFI](#3-prepare-bios--uefi)
4. [Install Windows 10/11](#4-install-windows-window)
    1. [Installation Media (USB Flash Drive)](#41-installation-media-usb-flash-drive)
    2. [Post-install](#42-post-install)
5. [Install Arch Linux](#5-install-arch-linux-penguin)
6. [Sources](#6-sources)
7. [Authors](#7-authors)

## 1. Configurations and Features
### 1.1. Script features
* Interactive CLI : :heavy_check_mark:
* Auto detect CPU manufacturer to download and install required microcode : :heavy_check_mark:
* Support solo and dual boot : :heavy_check_mark:
* Support multi-drive (for later) : :heavy_multiplication_x:

### 1.2. Windows configuration :window:
* Auto install Windows
* Language : **EN**
* Keyboard layout : **FR**
* Home location (for microsoft store) : **France**
* Extended EFI Partition for GRUB : :heavy_check_mark:
* 1G Recovery Partition to prevent a Windows Bug : :heavy_check_mark:
* Random Computer Name : :heavy_check_mark:
* Disabled TPM Check : :heavy_check_mark:
* Disabled RAM Check : :heavy_check_mark:
* Disabled Secure boot Check : :heavy_check_mark:
* No product key : :heavy_check_mark:
* No bloatware (minimal version, with no commercial software pre-installed) : :heavy_check_mark:
* No need to login with a Microsoft Account : :heavy_check_mark:
* Pre-configured Windows Explorer (Show hidden files and extensions) : :heavy_check_mark:
* Extended right click menu : :heavy_check_mark:
* Disabled Fast Startup and Hibernation (required for Dual Boot) : :heavy_check_mark:
* You can setup BitLocker if you want (no restrictions)
    
### 1.3. Arch Linux configuration :penguin:
* Encrypted partitions : :heavy_check_mark:
* Luks format : :heavy_check_mark:
* Separate Root and Home partitions : :heavy_check_mark:
* SWAP Partition : :heavy_multiplication_x:
* Secure boot for Arch Linux : :heavy_check_mark:
* Linux kernel : **ZEN - LTS**
* Desktop environment : **KDE PLASMA**
* Unix shell : **ZSH**
* Text editor : **NEOVIM**
* Boot manager : **GRUB**

## 2. System requirements
* Processor architecture : **x64**
* Minimum disk size recommended : **256G**
* System using **UEFI**
* *Actually don't support multi disk drive*

## 3. Prepare BIOS / UEFI
To install correctly and efficiently this OS I recommend to prepare the computer BIOS/UEFI with this settings :

* For Windows and Arch Linux install :
    * Disable Secure Boot clear certificate
    * Disable VMD (if using NVME SSD)

* I also recommend this :
    * Set root password (to prevent anyone to change the BIOS settings freely)
    * Disable boot from network (Allow to boot from an Ethernet or wireless connection, not use in most case)
    * Reenable secure boot after installing Arch Linux

## 4. Install Windows :window:
### 4.1. Installation Media (USB Flash Drive)
Be careful this step wipe all data on the disk drive.

Windows can be installed on any computer using an USB Flash Drive. To setup it you can use two method :
- With the Windows Media Creation Tool

It's the easiest method, you just need to download this tools from [here](https://www.microsoft.com/fr-fr/software-download/windows11) and follow the steps on the site. But with this method the automated installation of Windows is unstable and might not working.

- With the Windows iso file and Rufus or BelenaEtcher

It's the method I recommend cause you can prepare an installation media with an automated setup of Windows with the configurations describe [here](#1-configuration--features).
Use Rufus or BelenaEtcher to prepare the USB with the iso file.
You can download the iso file [here](https://www.microsoft.com/fr-fr/software-download/windows11). For the product language select `English international`.

Then copy the file in the `Windows` folder in this repository and past it directly in the prepared USB flash drive.
If the automated configurations isn't what you want you can get yours [here](https://schneegans.de/windows/unattend-generator/).

### 4.2. Post-install
After the installation of Windows, I recommend to install your favorite software so you can see how much space is needed to keep for Windows on your disk.
Then go in the partition manager of Windows and **shrink the `C:` partition to free some space for Arch Linux**.
Just before shutting down your computer to continue to the Arch installation process, I also recommend to create a restore point just in case something went wrong after.

## 5. Install Arch Linux :penguin:
## 6. Sources
## 7. Authors