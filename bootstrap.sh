#!/bin/bash
#
# Bootstrap script for Proxmox LXC containers
# This is the main entry point for provisioning containers with applications
#
# Usage:
#   ./bootstrap.sh <app-name>          # Install a specific application
#   ./bootstrap.sh --list              # List available applications
#   ./bootstrap.sh --help              # Show help message
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR/apps"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Source common utilities
# shellcheck source=scripts/common.sh
source "$SCRIPTS_DIR/common.sh"

# Show help message
show_help() {
    cat << EOF
Bootstrap Script for Proxmox LXC Containers

Usage:
    $(basename "$0") <app-name>     Install a specific application
    $(basename "$0") --list         List available applications
    $(basename "$0") --help         Show this help message

Examples:
    $(basename "$0") example        Install the example application
    $(basename "$0") --list         Show all available applications

Applications are located in the apps/ directory, each with its own install.sh script.
EOF
}

# List available applications
list_apps() {
    log "Available applications:"
    echo ""
    
    if [ ! -d "$APPS_DIR" ]; then
        warn "Apps directory not found: $APPS_DIR"
        return 1
    fi
    
    local found=0
    for app_dir in "$APPS_DIR"/*; do
        if [ -d "$app_dir" ]; then
            local app_name
            app_name=$(basename "$app_dir")
            local install_script="$app_dir/install.sh"
            
            if [ -f "$install_script" ]; then
                echo "  - $app_name"
                found=1
            fi
        fi
    done
    
    if [ $found -eq 0 ]; then
        warn "No applications found in $APPS_DIR"
        return 1
    fi
    
    echo ""
}

# Install an application
install_app() {
    local app_name="$1"
    local app_dir="$APPS_DIR/$app_name"
    local install_script="$app_dir/install.sh"
    
    if [ ! -d "$app_dir" ]; then
        die "Application not found: $app_name"
    fi
    
    if [ ! -f "$install_script" ]; then
        die "Install script not found: $install_script"
    fi
    
    if [ ! -x "$install_script" ]; then
        chmod +x "$install_script"
    fi
    
    log "Installing application: $app_name"
    log "Running: $install_script"
    
    # Run the install script
    bash "$install_script" || die "Installation failed for: $app_name"
    
    log "Successfully installed: $app_name"
}

# Main script logic
main() {
    # Parse command line arguments
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --list|-l)
            list_apps
            exit 0
            ;;
        -*)
            die "Unknown option: $1\nUse --help for usage information"
            ;;
        *)
            install_app "$1"
            ;;
    esac
}

# Run main function
main "$@"
