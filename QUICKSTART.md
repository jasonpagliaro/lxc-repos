# Quick Start Guide

Get started with LXC Repos in 5 minutes!

## Installation

```bash
# In your Proxmox LXC container or Linux system
git clone https://github.com/jasonpagliaro/lxc-repos.git
cd lxc-repos
```

## Basic Commands

```bash
# List all available applications
./bootstrap.sh --list

# Install an application
sudo ./bootstrap.sh <app-name>

# Get help
./bootstrap.sh --help
```

## Available Applications

### Example Application
A simple demonstration application showing the basic structure.

```bash
sudo ./bootstrap.sh example
example  # Run the application
```

### Nginx Static Web Server
A complete web server with a modern landing page.

```bash
sudo ./bootstrap.sh nginx-static
# Access at http://<your-container-ip>/
```

## Adding Your Own Application

1. Create a new directory:
```bash
mkdir -p apps/myapp
```

2. Create an installation script:
```bash
cat > apps/myapp/install.sh << 'EOF'
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/scripts/common.sh"

check_root
log "Installing my application..."
install_package curl wget

# Your installation steps here

log "Installation complete!"
EOF

chmod +x apps/myapp/install.sh
```

3. Test it:
```bash
sudo ./bootstrap.sh myapp
```

## Common Use Cases

### In Proxmox Cloud-Init
```bash
#!/bin/bash
cd /opt
git clone https://github.com/jasonpagliaro/lxc-repos.git
cd lxc-repos
./bootstrap.sh nginx-static
```

### As a Post-Install Script
```bash
wget -O - https://raw.githubusercontent.com/jasonpagliaro/lxc-repos/main/bootstrap.sh | sudo bash -s example
```

### Manual Installation
```bash
git clone https://github.com/jasonpagliaro/lxc-repos.git /opt/lxc-repos
cd /opt/lxc-repos
sudo ./bootstrap.sh <app-name>
```

## Utility Functions

Available in all installation scripts:

- `log "message"` - Log with timestamp
- `warn "message"` - Warning message
- `die "message"` - Error and exit
- `check_root` - Ensure root privileges
- `install_package pkg1 pkg2` - Install packages
- `command_exists cmd` - Check if command exists
- `create_systemd_service name` - Create service
- `enable_service name` - Enable and start service
- `create_user username` - Create system user
- `download_file url path` - Download file
- `wait_for_service host port timeout` - Wait for service

## Need Help?

- Check the [full README](README.md)
- Read [CONTRIBUTING.md](CONTRIBUTING.md) for development guide
- Review example applications in `apps/` directory
- Open an issue on GitHub

## Quick Tips

1. **Always run as root** for installations that need system access
2. **Test in a clean container** before deploying to production
3. **Check logs** if something goes wrong: `journalctl -xe`
4. **Make scripts idempotent** - safe to run multiple times
5. **Use the common utilities** - they handle errors and logging for you

## Repository Structure

```
lxc-repos/
├── bootstrap.sh          # Main entry point
├── scripts/
│   └── common.sh         # Utility functions
├── apps/
│   ├── example/          # Example app
│   └── nginx-static/     # Nginx web server
├── README.md             # Full documentation
├── CONTRIBUTING.md       # Developer guide
└── QUICKSTART.md         # This file
```

Ready to add more applications? Check out [CONTRIBUTING.md](CONTRIBUTING.md)!
