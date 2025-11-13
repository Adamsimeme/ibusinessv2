# iBusiness.id Installation Guide

## Overview

This installation script provides a complete automated setup for the iBusiness platform (backend API and frontend) on Debian 12 with aaPanel. The script handles all dependencies, configurations, and deployments in a single execution.

## Prerequisites

- **Server Requirements:**
  - Debian 12 (fresh installation recommended)
  - Root access (sudo)
  - Minimum 2GB RAM, 20GB storage
  - Internet connection

- **Domain Requirements:**
  - Valid domain name
  - DNS pointing to server IP
  - SSL certificate capability

## Quick Start

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/your-repo/ibusiness-install/main/install-ibusiness.sh
   ```

2. **Make executable:**
   ```bash
   chmod +x install-ibusiness.sh
   ```

3. **Run as root:**
   ```bash
   sudo ./install-ibusiness.sh
   ```

## What the Script Does

### System Setup
- ✅ Updates Debian packages
- ✅ Installs basic dependencies (curl, wget, etc.)
- ✅ Installs aaPanel control panel

### Application Dependencies
- ✅ Node.js (configurable version, default: 18)
- ✅ MongoDB with authentication
- ✅ Redis with password protection
- ✅ PM2 process manager

### Application Deployment
- ✅ Creates application directory structure (backend/ and frontend/)
- ✅ Copies backend and frontend application files
- ✅ Installs Node.js dependencies for backend
- ✅ Configures environment variables for backend

### Web Server Configuration
- ✅ Nginx reverse proxy setup
- ✅ SSL certificate (Let's Encrypt)
- ✅ Security headers and optimizations

### Database & Services
- ✅ MongoDB user creation
- ✅ Redis authentication
- ✅ Admin user creation
- ✅ PM2 process configuration

### Monitoring & Security
- ✅ Log rotation setup
- ✅ System monitoring script
- ✅ Security hardening

## Interactive Configuration

The script will prompt for:

- **Domain Name:** Your website domain (e.g., `ibusiness.id`)
- **Database Password:** MongoDB admin password (auto-generated if empty)
- **Redis Password:** Redis authentication password (auto-generated if empty)
- **Email Configuration:** SMTP settings for notifications
- **Admin Credentials:** First admin user account
- **Installation Path:** Where to install the application
- **Node.js Version:** Which Node.js version to use

## Post-Installation

After successful installation, you'll receive:

### Access Information
- **Application URL:** `https://yourdomain.com` (Frontend)
- **API Endpoint:** `https://api.yourdomain.com/api` (Backend)
- **aaPanel Admin:** `https://server-ip:8888`

### Important Credentials
- MongoDB admin password
- Redis password
- Admin user credentials
- JWT secrets (auto-generated)

### Next Steps
1. **DNS Configuration:** Point your domain to the server IP
2. **SSL Verification:** Check certificate validity
3. **Application Testing:** Verify API endpoints
4. **Backup Setup:** Configure regular backups
5. **Monitoring:** Set up log monitoring

## File Structure After Installation

```
/www/wwwroot/yourdomain.com/
├── backend/                 # Backend API server
│   ├── server.js            # Main application file
│   ├── package.json         # Backend dependencies
│   ├── .env                 # Environment configuration
│   ├── ecosystem.config.js  # PM2 configuration
│   ├── models/              # Database models
│   ├── routes/              # API routes
│   ├── middleware/          # Custom middleware
│   ├── services/            # Business logic
│   ├── utils/               # Utility functions
│   ├── logs/                # Application logs
│   │   ├── pm2-error.log
│   │   ├── pm2-out.log
│   │   └── pm2-combined.log
│   └── uploads/             # File uploads directory
└── frontend/                # Frontend application
    ├── pages/               # HTML pages
    └── public/              # Static assets
        ├── js/              # JavaScript modules
        └── css/             # Stylesheets
```

## Monitoring Commands

### Check Application Status
```bash
pm2 status
pm2 logs ibusiness-api
```

### System Monitoring
```bash
ibusiness-monitor.sh
```

### Service Status
```bash
systemctl status mongod
systemctl status redis-server
systemctl status nginx
```

## Troubleshooting

### Common Issues

1. **SSL Certificate Failed**
   - Ensure domain DNS points to server
   - Check firewall settings (ports 80, 443)
   - Verify domain format

2. **MongoDB Connection Failed**
   - Check MongoDB service: `systemctl status mongod`
   - Verify credentials in `.env`
   - Check MongoDB logs: `tail /var/log/mongodb/mongod.log`

3. **Redis Connection Failed**
   - Check Redis service: `systemctl status redis-server`
   - Verify password in `.env`
   - Test connection: `redis-cli -a yourpassword ping`

4. **Application Not Starting**
   - Check PM2 logs: `pm2 logs ibusiness-api`
   - Verify Node.js installation: `node --version`
   - Check environment variables in `.env`

5. **Nginx Configuration Issues**
   - Test configuration: `nginx -t`
   - Check error logs: `tail /var/log/nginx/error.log`
   - Verify domain configuration

### Log Locations

- **Application Logs:** `/www/wwwroot/yourdomain.com/backend/logs/`
- **PM2 Logs:** `pm2 logs` or `~/.pm2/logs/`
- **Nginx Logs:** `/www/wwwlogs/yourdomain.com.log`
- **MongoDB Logs:** `/var/log/mongodb/mongod.log`
- **Redis Logs:** `/var/log/redis/redis-server.log`
- **System Logs:** `/var/log/syslog`

## Security Considerations

### Post-Installation Security
1. **Change Default Passwords:** Update all auto-generated passwords
2. **Firewall Configuration:** Configure UFW or iptables
3. **SSH Hardening:** Disable root login, use key authentication
4. **Regular Updates:** Keep system and dependencies updated
5. **Backup Strategy:** Implement regular database backups

### Environment Variables Security
- JWT secrets are auto-generated securely
- Database passwords are encrypted in MongoDB
- Redis requires password authentication
- File permissions are set correctly

## Backup Strategy

### Automated Backups
```bash
# Database backup
mongodump --db ibusiness --out /backup/mongodb/$(date +%Y%m%d)

# Application backup
tar -czf /backup/app/app-$(date +%Y%m%d).tar.gz /www/wwwroot/yourdomain.com

# Configuration backup
cp /www/server/panel/vhost/nginx/yourdomain.com.conf /backup/nginx/
```

### Manual Backup Commands
```bash
# Full system backup
rsync -av --exclude='logs/*' --exclude='node_modules' /www/wwwroot/yourdomain.com /backup/

# Database export
mongoexport --db ibusiness --collection users --out /backup/users.json
```

## Performance Optimization

### PM2 Configuration
- Cluster mode for multi-core utilization
- Automatic restarts on crashes
- Memory limits and monitoring
- Log rotation

### Nginx Optimizations
- Gzip compression enabled
- Static file caching
- Connection keep-alive
- Security headers

### Database Optimization
- Connection pooling configured
- Indexing on frequently queried fields
- Memory limits set appropriately

## Support

For support and issues:
- **Documentation:** Check this README and inline comments
- **Logs:** Review application and system logs
- **Community:** GitHub Issues for bug reports
- **Professional Support:** Contact iBusiness team

## Version Information

- **Script Version:** 1.0.0
- **Application Version:** iBusiness v2 (full-stack with backend and frontend)
- **Supported OS:** Debian 12
- **Node.js:** 16+ (configurable)
- **MongoDB:** 6.0
- **Redis:** Latest stable

---

**iBusiness.id** - Empowering Digital Businesses