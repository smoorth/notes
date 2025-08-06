# Ubuntu Package Management Guide

## APT (Advanced Package Tool) - The Ubuntu Package Manager

APT is the primary package management system for Ubuntu and other Debian-based distributions.

### Basic APT Commands

#### Package Installation
```bash
# Install a single package
sudo apt install package-name

# Install multiple packages
sudo apt install package1 package2 package3

# Install a specific version
sudo apt install package-name=version

# Install from .deb file
sudo dpkg -i package.deb
sudo apt install -f  # Fix dependencies if needed
```

#### Package Removal
```bash
# Remove package but keep configuration files
sudo apt remove package-name

# Remove package and configuration files
sudo apt purge package-name

# Remove unused dependencies
sudo apt autoremove

# Remove orphaned packages
sudo apt autoremove --purge
```

#### Package Information and Search
```bash
# Search for packages
apt search keyword
apt-cache search keyword

# Show package information
apt show package-name
apt-cache show package-name

# List installed packages
apt list --installed
dpkg -l

# Check if package is installed
dpkg -l | grep package-name
apt list --installed | grep package-name
```

#### System Updates
```bash
# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade

# Full system upgrade (handles dependencies better)
sudo apt full-upgrade

# Update and upgrade in one command
sudo apt update && sudo apt upgrade

# Check for upgradeable packages
apt list --upgradeable
```

### Advanced APT Usage

#### Repository Management
```bash
# Add repository
sudo add-apt-repository ppa:repository-name
sudo add-apt-repository "deb [arch=amd64] https://repository-url distribution component"

# Remove repository
sudo add-apt-repository --remove ppa:repository-name

# List repositories
grep -r "^deb" /etc/apt/sources.list /etc/apt/sources.list.d/

# Edit sources manually
sudo nano /etc/apt/sources.list
```

#### APT Configuration
```bash
# Configure APT preferences
sudo nano /etc/apt/preferences

# Configure APT settings
sudo nano /etc/apt/apt.conf.d/99custom

# Example: Disable automatic package suggestions
echo 'APT::Install-Suggests "0";' | sudo tee -a /etc/apt/apt.conf.d/99no-suggests
```

## Snap Package Management

Snap packages are containerized software packages that work across different Linux distributions.

### Basic Snap Commands
```bash
# Install snap package
sudo snap install package-name

# Install from specific channel
sudo snap install package-name --channel=stable/edge/beta/candidate

# List installed snaps
snap list

# Remove snap package
sudo snap remove package-name

# Update all snaps
sudo snap refresh

# Update specific snap
sudo snap refresh package-name

# Find snap packages
snap find keyword
```

### Snap Management
```bash
# Show snap information
snap info package-name

# Connect interfaces
sudo snap connect package-name:interface

# Disconnect interfaces
sudo snap disconnect package-name:interface

# List available interfaces
snap interfaces

# Revert to previous version
sudo snap revert package-name
```

## Flatpak Package Management

Flatpak is another universal package management system.

### Setting Up Flatpak
```bash
# Install Flatpak
sudo apt install flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Basic Flatpak Commands
```bash
# Install application
flatpak install flathub app-name

# Run application
flatpak run app-name

# List installed applications
flatpak list

# Update applications
flatpak update

# Remove application
flatpak uninstall app-name

# Search for applications
flatpak search keyword
```

## Alternative Package Managers

### AppImage
```bash
# Make AppImage executable
chmod +x application.AppImage

# Run AppImage
./application.AppImage

# Install AppImageLauncher for better integration
sudo apt install appimagelauncher
```

### Manual Compilation and Installation
```bash
# Typical source compilation process
wget https://source-url/package.tar.gz
tar -xzf package.tar.gz
cd package-directory

# Configure, compile, and install
./configure
make
sudo make install

# Alternative using cmake
mkdir build && cd build
cmake ..
make
sudo make install
```

## Package Management Best Practices

### Security Considerations
```bash
# Verify package signatures
apt-key list
apt-key fingerprint

# Check package integrity
debsums package-name

# Only use trusted repositories
# Regularly update GPG keys
```

### System Maintenance
```bash
# Clean package cache
sudo apt clean
sudo apt autoclean

# Check for broken packages
sudo apt check

# Fix broken dependencies
sudo apt install -f

# Reconfigure packages
sudo dpkg-reconfigure package-name
```

### Troubleshooting Common Issues

#### Broken Dependencies
```bash
# Fix broken packages
sudo apt --fix-broken install

# Force package configuration
sudo dpkg --configure -a

# Remove problematic package
sudo dpkg --remove --force-remove-reinstreq package-name
```

#### Repository Issues
```bash
# Reset repository keys
sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com

# Fix repository key errors
wget -qO - https://repository-url/key.gpg | sudo apt-key add -

# Temporarily ignore repository
sudo apt update -o Dir::Etc::sourcelist="sources.list.d/specific-repo.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
```

## Package Information and Dependencies

### Analyzing Packages
```bash
# Show package dependencies
apt depends package-name

# Show reverse dependencies
apt rdepends package-name

# Show package files
dpkg -L package-name

# Find which package owns a file
dpkg -S /path/to/file

# Check package status
dpkg -s package-name
```

### Creating Package Lists
```bash
# Export installed packages
dpkg --get-selections > package-list.txt

# Import packages on new system
sudo dpkg --set-selections < package-list.txt
sudo apt dselect-upgrade

# Generate script to reinstall packages
dpkg --get-selections | grep -v deinstall | awk '{print $1}' > packages.list
```

This guide covers the essential package management operations for Ubuntu systems, from basic installations to advanced repository management and troubleshooting techniques.
