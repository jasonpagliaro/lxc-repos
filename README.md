# LXC Repos

A collection of installation scripts for deploying public applications in Proxmox LXC containers. This repository provides a simple, modular framework for installing and managing applications in Linux containers.

## Overview

This repository is designed to make it easy to install various applications in Proxmox VMs and LXC containers. Each application has its own installation script that handles all dependencies and configuration.

## Quick Start

### Prerequisites

- Proxmox VE environment (or any Linux system with bash)
- Root access on the target container/VM
- Internet connectivity for package installation

### Basic Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/jasonpagliaro/lxc-repos.git
   cd lxc-repos
   ```

2. Make the bootstrap script executable:
   ```bash
   chmod +x bootstrap.sh
   ```

3. List available applications:
   ```bash
   ./bootstrap.sh --list
   ```

4. Install an application:
   ```bash
   sudo ./bootstrap.sh <app-name>
   ```

### Example

```bash
# Install the example application
sudo ./bootstrap.sh example

# Run the example application
example
```

## Repository Structure

```
lxc-repos/
├── bootstrap.sh          # Main entry point for installing applications
├── scripts/
│   └── common.sh         # Shared utility functions
├── apps/
│   ├── example/
│   │   └── install.sh    # Example application installer
│   └── ...               # Additional applications
└── README.md
```

## Adding New Applications

To add a new application to this repository:

1. Create a new directory under `apps/`:
   ```bash
   mkdir -p apps/myapp
   ```

2. Create an `install.sh` script:
   ```bash
   cat > apps/myapp/install.sh << 'EOF'
   #!/bin/bash
   set -e
   
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
   source "$REPO_ROOT/scripts/common.sh"
   
   # Your installation logic here
   log "Installing myapp..."
   check_root
   install_package package1 package2
   # ... more installation steps
   EOF
   
   chmod +x apps/myapp/install.sh
   ```

3. Test your installation:
   ```bash
   sudo ./bootstrap.sh myapp
   ```

## Common Utility Functions

The `scripts/common.sh` file provides several useful functions for application installers:

- `log(message)` - Log informational messages
- `warn(message)` - Log warning messages
- `die(message)` - Log error message and exit
- `check_root()` - Ensure script is running as root
- `install_package(packages...)` - Install packages using apt
- `command_exists(command)` - Check if a command is available
- `create_systemd_service(name)` - Create a systemd service
- `enable_service(name)` - Enable and start a service
- `create_user(username, home_dir)` - Create a system user
- `download_file(url, output)` - Download a file
- `wait_for_service(host, port, timeout)` - Wait for a service to be ready

## Use in Proxmox

### Method 1: Direct Execution

1. Create a new LXC container in Proxmox
2. Start the container and access its console
3. Clone this repository and run the bootstrap script

### Method 2: Cloud-Init / Post-Install Script

Add to your container's cloud-init or post-install script:

```bash
#!/bin/bash
git clone https://github.com/jasonpagliaro/lxc-repos.git /opt/lxc-repos
cd /opt/lxc-repos
chmod +x bootstrap.sh
./bootstrap.sh example  # Replace with your app name
```

### Method 3: Proxmox CT Template

Include this repository in your custom container template:

```bash
# In your template build script
git clone https://github.com/jasonpagliaro/lxc-repos.git /opt/lxc-repos
cd /opt/lxc-repos
chmod +x bootstrap.sh
# Optionally pre-install some applications
./bootstrap.sh example
```

## Contributing

To contribute a new application:

1. Fork this repository
2. Create a new branch for your application
3. Add your application under `apps/yourapp/`
4. Ensure your installation script follows the existing patterns
5. Test your installation script
6. Submit a pull request

## License

This repository contains installation scripts for various open-source applications. Each application is subject to its own license. Please refer to the individual application's documentation for licensing information.

## Support

For issues or questions:
- Open an issue on GitHub
- Check existing applications for examples
- Review the common.sh utility functions
