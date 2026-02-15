#!/bin/bash
#
# Common utility functions for all installation scripts
# Source this file in your install scripts: source "$(dirname "$0")/../scripts/common.sh"
#

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log a message with timestamp
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

# Log a warning message
warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $*" >&2
}

# Log an error message and exit
die() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $*" >&2
    exit 1
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        die "This script must be run as root"
    fi
}

# Install packages using apt
install_package() {
    log "Installing packages: $*"
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y "$@" || die "Failed to install packages: $*"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create a systemd service file
create_systemd_service() {
    local service_name="$1"
    local service_file="/etc/systemd/system/${service_name}.service"
    
    if [ -f "$service_file" ]; then
        warn "Service file $service_file already exists, skipping"
        return 0
    fi
    
    log "Creating systemd service: $service_name"
    cat > "$service_file"
    systemctl daemon-reload
    log "Service $service_name created successfully"
}

# Enable and start a systemd service
enable_service() {
    local service_name="$1"
    log "Enabling and starting service: $service_name"
    systemctl enable "$service_name" || die "Failed to enable service: $service_name"
    systemctl start "$service_name" || die "Failed to start service: $service_name"
}

# Create a user if it doesn't exist
create_user() {
    local username="$1"
    local home_dir="${2:-/home/$username}"
    
    if id "$username" >/dev/null 2>&1; then
        log "User $username already exists"
        return 0
    fi
    
    log "Creating user: $username"
    useradd -m -d "$home_dir" -s /bin/bash "$username" || die "Failed to create user: $username"
}

# Download a file with curl or wget
download_file() {
    local url="$1"
    local output="$2"
    
    log "Downloading $url to $output"
    if command_exists curl; then
        curl -fsSL "$url" -o "$output" || die "Failed to download $url"
    elif command_exists wget; then
        wget -q "$url" -O "$output" || die "Failed to download $url"
    else
        die "Neither curl nor wget is available"
    fi
}

# Wait for a service to be ready
wait_for_service() {
    local host="${1:-localhost}"
    local port="$2"
    local timeout="${3:-30}"
    local elapsed=0
    
    log "Waiting for service at $host:$port (timeout: ${timeout}s)"
    
    while [ $elapsed -lt "$timeout" ]; do
        if command_exists nc; then
            if nc -z "$host" "$port" 2>/dev/null; then
                log "Service is ready"
                return 0
            fi
        elif command_exists telnet; then
            if timeout 1 telnet "$host" "$port" 2>/dev/null | grep -q "Connected"; then
                log "Service is ready"
                return 0
            fi
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    warn "Service at $host:$port did not become ready within ${timeout}s"
    return 1
}

# Export all functions
export -f log warn die check_root install_package command_exists
export -f create_systemd_service enable_service create_user
export -f download_file wait_for_service
