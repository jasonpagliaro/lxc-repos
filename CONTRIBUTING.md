# Contributing to LXC Repos

Thank you for your interest in contributing to this project! This guide will help you add new applications to the repository.

## How to Contribute

### Adding a New Application

1. **Fork and Clone**: Fork this repository and clone it to your local machine

2. **Create Application Directory**: 
   ```bash
   mkdir -p apps/your-app-name
   ```

3. **Create Installation Script**: Follow the template in `apps/README.md` or use an existing app as reference

4. **Test Your Script**: Test thoroughly in a Proxmox LXC container or similar environment

5. **Add Documentation**: Include a README.md in your app directory explaining what it does and how to use it

6. **Submit Pull Request**: Push your changes and create a pull request

### Application Guidelines

#### Required Files

Each application must have at minimum:
- `apps/your-app-name/install.sh` - The installation script

#### Recommended Files

- `apps/your-app-name/README.md` - Documentation for your application
- Configuration examples or templates if applicable

#### Script Requirements

Your `install.sh` must:

1. **Start with shebang and error handling**:
   ```bash
   #!/bin/bash
   set -e
   ```

2. **Source common utilities**:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
   source "$REPO_ROOT/scripts/common.sh"
   ```

3. **Check for root privileges** (if needed):
   ```bash
   check_root
   ```

4. **Use logging functions**:
   ```bash
   log "Starting installation..."
   warn "This might take a while..."
   die "Installation failed!"
   ```

5. **Be idempotent**: The script should be safe to run multiple times

6. **Clean up after itself**: Remove temporary files and resources

### Code Style

- Use 4 spaces for indentation (no tabs)
- Use descriptive variable names in UPPERCASE for constants
- Use lowercase for function names with underscores
- Add comments for complex logic
- Follow existing script patterns in the repository

### Testing Checklist

Before submitting your pull request, ensure:

- [ ] Script runs without errors in a fresh container
- [ ] Script is idempotent (can run multiple times safely)
- [ ] All dependencies are properly installed
- [ ] Services start correctly if applicable
- [ ] Documentation is clear and complete
- [ ] Script uses common.sh utility functions
- [ ] Error handling is in place
- [ ] Script cleans up temporary files

### Example: Complete Application

```
apps/myapp/
├── README.md          # Documentation
├── install.sh         # Installation script
└── config.example     # Optional: example configuration
```

**install.sh**:
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_ROOT/scripts/common.sh"

APP_NAME="myapp"
INSTALL_DIR="/opt/$APP_NAME"

install_myapp() {
    log "Installing $APP_NAME"
    check_root
    
    install_package curl git
    
    mkdir -p "$INSTALL_DIR"
    # ... installation steps ...
    
    log "Installation complete!"
}

install_myapp
```

**README.md**:
```markdown
# MyApp

Brief description of your application.

## Installation

\`\`\`bash
sudo ./bootstrap.sh myapp
\`\`\`

## Configuration

How to configure the application...

## Usage

How to use the application...
```

### Security Considerations

- Never hardcode passwords or secrets
- Use environment variables or configuration files for sensitive data
- Validate user input if your script accepts parameters
- Follow security best practices for the application you're installing
- Use HTTPS for downloads when possible

### Getting Help

If you need help:

1. Check the existing applications for examples
2. Review the utility functions in `scripts/common.sh`
3. Read the `apps/README.md` documentation
4. Open an issue if you're stuck

### Pull Request Process

1. Create a new branch for your application
2. Add your application files
3. Test thoroughly
4. Update documentation if needed
5. Submit a pull request with:
   - Clear description of what your application does
   - Any special requirements or considerations
   - Testing steps you performed

### Code Review

Your pull request will be reviewed for:

- Functionality and correctness
- Code quality and style
- Documentation completeness
- Security considerations
- Adherence to guidelines

### License

By contributing, you agree that your contributions will be licensed under the same license as this project.

## Questions?

Feel free to open an issue if you have questions about contributing!
