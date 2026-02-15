#!/bin/bash
#
# Example application installation script
# This demonstrates how to create an application installer for the LXC repos
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=../../scripts/common.sh
source "$REPO_ROOT/scripts/common.sh"

# Application-specific variables
APP_NAME="example"
APP_VERSION="1.0.0"
INSTALL_DIR="/opt/$APP_NAME"

# Main installation function
install_example() {
    log "Starting installation of $APP_NAME (version $APP_VERSION)"
    
    # Check if running as root
    check_root
    
    # Install required packages
    log "Installing dependencies..."
    install_package curl wget git build-essential
    
    # Create installation directory
    log "Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    
    # Create a simple example application
    log "Creating example application..."
    cat > "$INSTALL_DIR/app.sh" << 'EOF'
#!/bin/bash
echo "Hello from the example application!"
echo "This is running from: $(pwd)"
echo "Current time: $(date)"
EOF
    
    chmod +x "$INSTALL_DIR/app.sh"
    
    # Create a systemd service (optional)
    log "Creating systemd service..."
    create_systemd_service "$APP_NAME" << EOF
[Unit]
Description=Example Application
After=network.target

[Service]
Type=oneshot
ExecStart=$INSTALL_DIR/app.sh
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF
    
    # Create a convenient symlink
    log "Creating symlink in /usr/local/bin..."
    ln -sf "$INSTALL_DIR/app.sh" "/usr/local/bin/$APP_NAME"
    
    log "Installation complete!"
    log "You can run the application with: $APP_NAME"
    log "Or manually start the service with: systemctl start $APP_NAME"
}

# Run the installation
install_example
