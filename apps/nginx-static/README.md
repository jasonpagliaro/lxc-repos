# Nginx Static Web Server

This application installs Nginx and sets up a basic static website in your Proxmox LXC container.

## What It Does

- Installs Nginx web server
- Creates a simple, attractive default homepage
- Configures Nginx with security headers
- Sets up the service to start automatically

## Installation

```bash
sudo ./bootstrap.sh nginx-static
```

## After Installation

Once installed, you can:

1. **Access your website**: Navigate to `http://<container-ip>/` in a web browser

2. **Customize the content**: Edit the files in `/var/www/html/`
   ```bash
   nano /var/www/html/index.html
   ```

3. **Add more pages**: Place additional HTML files in `/var/www/html/`

4. **Configure Nginx**: Edit the configuration at `/etc/nginx/sites-available/default`
   ```bash
   nano /etc/nginx/sites-available/default
   nginx -t  # Test configuration
   systemctl reload nginx  # Reload after changes
   ```

## Managing the Service

```bash
# Check status
systemctl status nginx

# Stop the service
systemctl stop nginx

# Start the service
systemctl start nginx

# Restart the service
systemctl restart nginx

# Reload configuration (without dropping connections)
systemctl reload nginx
```

## Configuration Details

- **Web root**: `/var/www/html`
- **Config file**: `/etc/nginx/sites-available/default`
- **Log files**: `/var/log/nginx/`
- **Default port**: 80 (HTTP)

## Adding SSL/HTTPS

To add HTTPS support, you can use Let's Encrypt with Certbot:

```bash
apt-get install certbot python3-certbot-nginx
certbot --nginx -d your-domain.com
```

## Troubleshooting

If nginx doesn't start:

1. Check the logs:
   ```bash
   journalctl -u nginx
   tail /var/log/nginx/error.log
   ```

2. Test the configuration:
   ```bash
   nginx -t
   ```

3. Check if port 80 is already in use:
   ```bash
   netstat -tulpn | grep :80
   ```
