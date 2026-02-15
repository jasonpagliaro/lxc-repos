#!/bin/bash
#
# Nginx static web server installation script
# This installs nginx and sets up a basic static website
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common utilities
# shellcheck source=../../scripts/common.sh
source "$REPO_ROOT/scripts/common.sh"

# Application-specific variables
APP_NAME="nginx-static"
WEB_ROOT="/var/www/html"
NGINX_CONF="/etc/nginx/sites-available/default"

# Main installation function
install_nginx_static() {
    log "Starting installation of Nginx static web server"
    
    # Check if running as root
    check_root
    
    # Install nginx
    log "Installing nginx..."
    install_package nginx
    
    # Create a simple static website
    log "Creating default website..."
    cat > "$WEB_ROOT/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Nginx</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 {
            margin-top: 0;
        }
        .info {
            background: rgba(255, 255, 255, 0.2);
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Nginx Installation Successful!</h1>
        <p>This is a static website served by Nginx on your Proxmox LXC container.</p>
        
        <div class="info">
            <strong>Installation Details:</strong>
            <ul>
                <li>Web server: Nginx</li>
                <li>Document root: /var/www/html</li>
                <li>Configuration: /etc/nginx/sites-available/default</li>
            </ul>
        </div>
        
        <p>To customize this page, edit <code>/var/www/html/index.html</code></p>
    </div>
</body>
</html>
EOF
    
    # Configure nginx
    log "Configuring nginx..."
    cat > "$NGINX_CONF" << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF
    
    # Test nginx configuration
    log "Testing nginx configuration..."
    nginx -t || die "Nginx configuration test failed"
    
    # Enable and start nginx
    log "Starting nginx service..."
    enable_service nginx
    
    # Wait for service to be ready
    log "Waiting for nginx to be ready..."
    wait_for_service localhost 80 30 || warn "Could not confirm nginx is listening on port 80"
    
    log "Installation complete!"
    log "Nginx is now running and serving content from $WEB_ROOT"
    log "Access your website at: http://<container-ip>/"
}

# Run the installation
install_nginx_static
