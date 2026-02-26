# Podman Installation

## System Requirements

### Minimum Requirements
- Linux kernel 3.10 or later
- 2 GB RAM
- 20 GB disk space
- 64-bit processor

### Recommended
- Linux kernel 4.18 or later (for better rootless support)
- 4 GB RAM
- 50 GB disk space
- Modern CPU with virtualization support

## Linux Installation

### RHEL/CentOS/Fedora

#### Fedora
```bash
# Install Podman
sudo dnf install -y podman

# Install additional tools
sudo dnf install -y podman-compose buildah skopeo

# Verify installation
podman --version
```

#### RHEL 8/9
```bash
# Enable required repositories
sudo subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms

# Install Podman
sudo dnf install -y podman

# Verify
podman --version
```

#### CentOS Stream
```bash
# Install Podman
sudo dnf install -y podman

# Install additional tools
sudo dnf install -y buildah skopeo
```

### Ubuntu/Debian

#### Ubuntu 20.04+
```bash
# Update package list
sudo apt-get update

# Install Podman
sudo apt-get install -y podman

# For latest version, use Kubic repository
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$(lsb_release -rs)/ /" | \
  sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$(lsb_release -rs)/Release.key" | \
  sudo apt-key add -

sudo apt-get update
sudo apt-get install -y podman

# Verify
podman --version
```

#### Debian 11+
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y \
  curl \
  wget \
  gnupg2

# Add repository
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/ /" | \
  sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/Release.key" | \
  sudo apt-key add -

# Install Podman
sudo apt-get update
sudo apt-get install -y podman

# Verify
podman --version
```

### Arch Linux
```bash
# Install Podman
sudo pacman -S podman

# Install additional tools
sudo pacman -S buildah skopeo podman-compose

# Verify
podman --version
```

### openSUSE
```bash
# Install Podman
sudo zypper install podman

# Install additional tools
sudo zypper install buildah skopeo

# Verify
podman --version
```

## macOS Installation

### Using Homebrew
```bash
# Install Podman
brew install podman

# Initialize Podman machine
podman machine init

# Start Podman machine
podman machine start

# Verify
podman --version
podman machine list
```

### Podman Desktop
```bash
# Download from https://podman-desktop.io/
# Or install via Homebrew
brew install --cask podman-desktop
```

### Configuration
```bash
# Set machine resources
podman machine init --cpus 4 --memory 8192 --disk-size 50

# SSH into machine
podman machine ssh

# Stop machine
podman machine stop

# Remove machine
podman machine rm
```

## Windows Installation

### Using WSL2

#### Install WSL2
```powershell
# Enable WSL
wsl --install

# Set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d Ubuntu
```

#### Install Podman in WSL2
```bash
# Inside WSL2 Ubuntu
sudo apt-get update
sudo apt-get install -y podman

# Verify
podman --version
```

### Podman Desktop for Windows
```powershell
# Download from https://podman-desktop.io/
# Run installer
# Follow installation wizard
```

### Windows Native (Experimental)
```powershell
# Using Chocolatey
choco install podman

# Or download from GitHub releases
# https://github.com/containers/podman/releases
```

## Post-Installation Setup

### Rootless Configuration

#### Enable User Namespaces
```bash
# Check if enabled
cat /proc/sys/kernel/unprivileged_userns_clone

# Enable (if needed)
echo 'kernel.unprivileged_userns_clone=1' | sudo tee /etc/sysctl.d/00-local-userns.conf
sudo sysctl -p /etc/sysctl.d/00-local-userns.conf
```

#### Configure Subuid/Subgid
```bash
# Check current mappings
cat /etc/subuid
cat /etc/subgid

# Add user mappings (if not present)
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER

# Verify
grep $USER /etc/subuid
grep $USER /etc/subgid
```

#### Migrate to Rootless
```bash
# Migrate existing containers
podman system migrate

# Verify rootless mode
podman info | grep rootless
```

### Registry Configuration

#### Configure Registries
```bash
# Edit registries.conf
sudo vi /etc/containers/registries.conf
```

```toml
# Add registries
[registries.search]
registries = ['docker.io', 'quay.io', 'registry.access.redhat.com']

[registries.insecure]
registries = []

[registries.block]
registries = []
```

#### Configure Authentication
```bash
# Login to registry
podman login docker.io
podman login quay.io

# Verify credentials
cat ~/.config/containers/auth.json
```

### Storage Configuration

#### Configure Storage Driver
```bash
# Edit storage.conf
vi ~/.config/containers/storage.conf
```

```toml
[storage]
driver = "overlay"
runroot = "/run/user/1000/containers"
graphroot = "/home/user/.local/share/containers/storage"

[storage.options]
mount_program = "/usr/bin/fuse-overlayfs"
```

### Network Configuration

#### Enable Networking
```bash
# Install CNI plugins
sudo dnf install containernetworking-plugins

# Or on Ubuntu
sudo apt-get install containernetworking-plugins

# Verify
ls /usr/libexec/cni/
```

#### Configure DNS
```bash
# Edit containers.conf
vi ~/.config/containers/containers.conf
```

```toml
[network]
dns_servers = ["8.8.8.8", "8.8.4.4"]
```

## Verification

### Check Installation
```bash
# Version
podman --version

# System info
podman info

# Check rootless
podman info | grep rootless

# Test run
podman run --rm hello-world
```

### Test Basic Operations
```bash
# Pull image
podman pull nginx

# Run container
podman run -d --name test-nginx -p 8080:80 nginx

# Check running
podman ps

# Test access
curl http://localhost:8080

# Cleanup
podman stop test-nginx
podman rm test-nginx
podman rmi nginx
```

## Troubleshooting Installation

### Common Issues

#### Permission Denied
```bash
# Check user namespaces
cat /proc/sys/kernel/unprivileged_userns_clone

# Enable if 0
echo 'kernel.unprivileged_userns_clone=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### Network Issues
```bash
# Check CNI plugins
ls /usr/libexec/cni/

# Reinstall if missing
sudo dnf reinstall containernetworking-plugins
```

#### Storage Issues
```bash
# Reset storage
podman system reset

# Check storage
podman info --debug
```

## Updating Podman

### RHEL/Fedora
```bash
sudo dnf update podman
```

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get upgrade podman
```

### macOS
```bash
brew upgrade podman
podman machine stop
podman machine rm
podman machine init
podman machine start
```

## Uninstallation

### Linux
```bash
# RHEL/Fedora
sudo dnf remove podman

# Ubuntu/Debian
sudo apt-get remove podman

# Remove data
rm -rf ~/.local/share/containers
rm -rf ~/.config/containers
```

### macOS
```bash
# Stop and remove machine
podman machine stop
podman machine rm

# Uninstall
brew uninstall podman
```

## Next Steps

Continue to:
- [Basic Commands](2-Basic-Commands.md) - Learn essential commands
- [Images](3-Images.md) - Work with container images
- [Containers](4-Containers.md) - Manage containers
