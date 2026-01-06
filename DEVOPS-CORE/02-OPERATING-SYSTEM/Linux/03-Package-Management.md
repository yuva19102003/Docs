# 📦 Linux Package Management

**Installing, updating, and managing software packages in Linux**

---

## 🎯 Overview

Package managers automate the process of installing, upgrading, configuring, and removing software. This guide covers the most common package managers used in Linux distributions.

---

## 🔧 Package Manager Types

### Debian-Based Systems (Ubuntu, Debian, Mint)
- **APT** (Advanced Package Tool)
- **dpkg** (Debian Package)

### Red Hat-Based Systems (RHEL, CentOS, Fedora)
- **YUM** (Yellowdog Updater Modified)
- **DNF** (Dandified YUM - newer)
- **RPM** (Red Hat Package Manager)

### Universal Package Managers
- **Snap**
- **Flatpak**
- **AppImage**

---

## 📥 APT - Debian/Ubuntu Package Manager

### Update Package Lists

```bash
# Update package database
sudo apt update

# Show upgradable packages
apt list --upgradable
```

### Install Packages

```bash
# Install single package
sudo apt install package_name

# Install multiple packages
sudo apt install package1 package2 package3

# Install specific version
sudo apt install package_name=version

# Install without prompts
sudo apt install -y package_name

# Reinstall package
sudo apt install --reinstall package_name
```

**Examples:**
```bash
sudo apt install git                    # Install Git
sudo apt install nginx mysql-server     # Install multiple packages
sudo apt install -y docker.io           # Install without confirmation
```

---

### Remove Packages

```bash
# Remove package (keep configuration files)
sudo apt remove package_name

# Remove package and configuration files
sudo apt purge package_name

# Remove unused dependencies
sudo apt autoremove

# Remove package and unused dependencies
sudo apt autoremove package_name
```

**Examples:**
```bash
sudo apt remove apache2                 # Remove Apache
sudo apt purge apache2                  # Remove Apache and configs
sudo apt autoremove                     # Clean up unused packages
```

---

### Upgrade Packages

```bash
# Upgrade all packages
sudo apt upgrade

# Upgrade with intelligent dependency handling
sudo apt full-upgrade

# Upgrade specific package
sudo apt install --only-upgrade package_name
```

**Examples:**
```bash
sudo apt update && sudo apt upgrade -y  # Update and upgrade
sudo apt full-upgrade                   # Smart upgrade
```

---

### Search and Information

```bash
# Search for packages
apt search keyword

# Show package information
apt show package_name

# List installed packages
apt list --installed

# List all available packages
apt list

# Check if package is installed
dpkg -l | grep package_name
```

**Examples:**
```bash
apt search nginx                        # Search for nginx packages
apt show nginx                          # Show nginx details
apt list --installed | grep python      # List installed Python packages
```

---

### Clean Up

```bash
# Remove downloaded package files
sudo apt clean

# Remove old package files
sudo apt autoclean

# Remove unused packages
sudo apt autoremove
```

---

## 🔴 YUM - Red Hat/CentOS Package Manager

### Update Package Lists

```bash
# Check for updates
sudo yum check-update

# Update package database
sudo yum makecache
```

### Install Packages

```bash
# Install package
sudo yum install package_name

# Install multiple packages
sudo yum install package1 package2

# Install without prompts
sudo yum install -y package_name

# Reinstall package
sudo yum reinstall package_name

# Install local RPM file
sudo yum localinstall package.rpm
```

**Examples:**
```bash
sudo yum install git                    # Install Git
sudo yum install -y httpd mariadb       # Install Apache and MariaDB
```

---

### Remove Packages

```bash
# Remove package
sudo yum remove package_name

# Remove package and dependencies
sudo yum autoremove package_name
```

---

### Upgrade Packages

```bash
# Update all packages
sudo yum update

# Update specific package
sudo yum update package_name

# Update security patches only
sudo yum update --security
```

---

### Search and Information

```bash
# Search for packages
yum search keyword

# Show package information
yum info package_name

# List installed packages
yum list installed

# List available packages
yum list available

# Show package dependencies
yum deplist package_name
```

---

### Clean Up

```bash
# Clean package cache
sudo yum clean all

# Remove old kernels (keep latest 2)
sudo package-cleanup --oldkernels --count=2
```

---

## 🆕 DNF - Modern Fedora Package Manager

DNF is the successor to YUM with better performance and dependency resolution.

### Basic Commands

```bash
# Install package
sudo dnf install package_name

# Remove package
sudo dnf remove package_name

# Update all packages
sudo dnf upgrade

# Search packages
dnf search keyword

# Show package info
dnf info package_name

# List installed packages
dnf list installed

# Clean cache
sudo dnf clean all
```

**Examples:**
```bash
sudo dnf install nodejs                 # Install Node.js
sudo dnf upgrade                        # Update all packages
dnf search docker                       # Search for Docker packages
```

---

## 📦 Low-Level Package Managers

### dpkg - Debian Package Manager

```bash
# Install .deb package
sudo dpkg -i package.deb

# Remove package
sudo dpkg -r package_name

# List installed packages
dpkg -l

# Show package information
dpkg -s package_name

# List package files
dpkg -L package_name

# Find which package owns a file
dpkg -S /path/to/file

# Fix broken dependencies
sudo apt install -f
```

---

### RPM - Red Hat Package Manager

```bash
# Install .rpm package
sudo rpm -i package.rpm

# Upgrade package
sudo rpm -U package.rpm

# Remove package
sudo rpm -e package_name

# List installed packages
rpm -qa

# Show package information
rpm -qi package_name

# List package files
rpm -ql package_name

# Find which package owns a file
rpm -qf /path/to/file
```

---

## 🌐 Universal Package Managers

### Snap

```bash
# Install snap
sudo apt install snapd          # Ubuntu/Debian
sudo dnf install snapd          # Fedora

# Install package
sudo snap install package_name

# List installed snaps
snap list

# Update all snaps
sudo snap refresh

# Remove snap
sudo snap remove package_name

# Search for snaps
snap find keyword
```

**Examples:**
```bash
sudo snap install code --classic        # Install VS Code
sudo snap install spotify               # Install Spotify
```

---

### Flatpak

```bash
# Install flatpak
sudo apt install flatpak        # Ubuntu/Debian
sudo dnf install flatpak        # Fedora

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install package
flatpak install flathub app_id

# List installed flatpaks
flatpak list

# Update all flatpaks
flatpak update

# Remove flatpak
flatpak uninstall app_id

# Search for flatpaks
flatpak search keyword
```

---

## 💡 Practical Examples

### Example 1: Set Up Web Server (Ubuntu)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install NGINX
sudo apt install -y nginx

# Install PHP and MySQL
sudo apt install -y php-fpm mysql-server

# Start services
sudo systemctl start nginx
sudo systemctl start mysql

# Enable services on boot
sudo systemctl enable nginx
sudo systemctl enable mysql
```

---

### Example 2: Install Development Tools (CentOS)

```bash
# Install development tools
sudo yum groupinstall -y "Development Tools"

# Install Git
sudo yum install -y git

# Install Node.js
curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installations
git --version
node --version
npm --version
```

---

### Example 3: Clean Up System

```bash
# Ubuntu/Debian
sudo apt autoremove -y
sudo apt autoclean
sudo apt clean

# CentOS/RHEL
sudo yum autoremove -y
sudo yum clean all

# Remove old kernels (Ubuntu)
sudo apt autoremove --purge
```

---

## 🎯 Best Practices

### 1. Always Update Before Installing
```bash
sudo apt update && sudo apt install package_name
```

### 2. Use -y Flag in Scripts
```bash
sudo apt install -y package_name
```

### 3. Regular System Updates
```bash
# Create update script
cat > update.sh << 'EOF'
#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt clean
EOF

chmod +x update.sh
```

### 4. Check Before Removing
```bash
# See what will be removed
apt remove --dry-run package_name
```

### 5. Keep System Clean
```bash
# Weekly cleanup
sudo apt autoremove -y
sudo apt autoclean
```

---

## 🔒 Security Best Practices

### 1. Enable Automatic Security Updates (Ubuntu)

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Enable automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 2. Verify Package Signatures

```bash
# APT verifies signatures automatically
# Check GPG keys
apt-key list
```

### 3. Use Official Repositories

```bash
# List repositories
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/
```

---

## 🔗 Related Topics

- **System Services:** `04-Systemctl-Services.md`
- **System Monitoring:** `06-System-Monitoring.md`
- **Shell Scripting:** `09-Shell-Scripting.md`

---

**Last Updated:** January 5, 2026  
**Status:** ✅ Complete

