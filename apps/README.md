# Applications Directory

This directory contains installation scripts for various applications that can be deployed in Proxmox LXC containers.

## Structure

Each application should have its own directory with at least an `install.sh` script:

```
apps/
├── myapp/
│   ├── install.sh          # Required: Main installation script
│   ├── config.example      # Optional: Example configuration file
│   └── README.md           # Optional: Application-specific documentation
└── ...
```

## Creating a New Application Installer

### Basic Template

Create a new directory and installation script:

```bash
mkdir -p apps/myapp
cat > apps/myapp/install.sh << 'EOF'
#!/bin/bash
set -e

# Get script directory and source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/scripts/common.sh"

# Application configuration
APP_NAME="myapp"
APP_VERSION="1.0.0"
INSTALL_DIR="/opt/$APP_NAME"

# Main installation function
install_app() {
    log "Installing $APP_NAME v$APP_VERSION"
    
    # Ensure running as root
    check_root
    
    # Install dependencies
    install_package curl wget git
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Download and install your application
    # ... your installation steps here ...
    
    log "Installation complete!"
}

# Run installation
install_app
EOF

chmod +x apps/myapp/install.sh
```

### Available Utility Functions

The following functions are available from `scripts/common.sh`:

#### Logging
- `log "message"` - Log informational message with timestamp
- `warn "message"` - Log warning message
- `die "message"` - Log error and exit script

#### System Checks
- `check_root` - Ensure script is running as root
- `command_exists "command"` - Check if a command is available

#### Package Management
- `install_package package1 package2 ...` - Install packages using apt

#### Service Management
- `create_systemd_service "name" < service_file_content` - Create a systemd service
- `enable_service "name"` - Enable and start a service

#### User Management
- `create_user "username" "/home/path"` - Create a system user

#### File Operations
- `download_file "url" "/path/to/output"` - Download a file using curl or wget

#### Service Monitoring
- `wait_for_service "host" port timeout` - Wait for a service to be ready

### Best Practices

1. **Error Handling**: Always use `set -e` at the beginning of your script
2. **Root Check**: Call `check_root` early in your installation
3. **Idempotency**: Make your scripts safe to run multiple times
4. **Logging**: Use `log`, `warn`, and `die` for all output
5. **Cleanup**: Clean up temporary files if your installation creates any
6. **Testing**: Test your installation script before committing

### Example: Installing a Web Application

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/scripts/common.sh"

APP_NAME="webapp"
INSTALL_DIR="/opt/$APP_NAME"
PORT=8080

install_webapp() {
    log "Installing web application"
    check_root
    
    # Install Node.js
    install_package nodejs npm
    
    # Create app directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Initialize Node.js project
    npm init -y
    npm install express
    
    # Create simple web server
    cat > index.js << 'JSEOF'
const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('Hello World!'));
app.listen(8080, () => console.log('Server running on port 8080'));
JSEOF
    
    # Create systemd service
    create_systemd_service "$APP_NAME" << SERVICEEOF
[Unit]
Description=Web Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/node index.js
Restart=always

[Install]
WantedBy=multi-user.target
SERVICEEOF
    
    # Start the service
    enable_service "$APP_NAME"
    
    # Wait for service to be ready
    wait_for_service localhost $PORT 30
    
    log "Web application installed and running on port $PORT"
}

install_webapp
```

## Testing Your Application

Before submitting your application:

1. Test the installation script:
   ```bash
   sudo bash apps/myapp/install.sh
   ```

2. Test using the bootstrap script:
   ```bash
   sudo ./bootstrap.sh myapp
   ```

3. Verify the application is working as expected

4. Test in a clean Proxmox LXC container if possible

## Contributing

To contribute a new application:

1. Create your application directory under `apps/`
2. Add an `install.sh` script following the template above
3. Optionally add configuration examples and documentation
4. Test your installation thoroughly
5. Submit a pull request with your changes
