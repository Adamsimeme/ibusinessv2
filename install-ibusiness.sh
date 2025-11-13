#!/bin/bash

# iBusiness.id Installation Script for Debian 12 with aaPanel
# This script provides a complete setup for iBusiness.id backend API
# Version: 1.0.0
# Author: iBusiness Team

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DOMAIN=""
DB_USER="ibusiness"
DB_PASS=""
REDIS_PASS=""
JWT_SECRET=""
JWT_REFRESH_SECRET=""
SESSION_SECRET=""
CSRF_SECRET=""
EMAIL_USER=""
EMAIL_PASS=""
ADMIN_EMAIL=""
ADMIN_PASS=""
INSTALL_PATH="/www/wwwroot/ibusiness.id"
NODE_VERSION="18"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Function to generate random password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-16
}

# Function to validate email
validate_email() {
    local email=$1
    if [[ ! $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 1
    fi
    return 0
}

# Function to validate domain
validate_domain() {
    local domain=$1
    if [[ ! $domain =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 1
    fi
    return 0
}

# Function to collect user input
collect_user_input() {
    print_status "Collecting installation information..."

    # Domain
    while true; do
        read -p "Enter your domain name (e.g., ibusiness.id): " DOMAIN
        if validate_domain "$DOMAIN"; then
            break
        else
            print_error "Invalid domain format. Please try again."
        fi
    done

    # Database password
    while true; do
        read -s -p "Enter MongoDB password (leave empty for auto-generate): " DB_PASS
        echo
        if [[ -z "$DB_PASS" ]]; then
            DB_PASS=$(generate_password)
            print_success "Auto-generated MongoDB password: $DB_PASS"
            break
        elif [[ ${#DB_PASS} -lt 8 ]]; then
            print_error "Password must be at least 8 characters long."
        else
            break
        fi
    done

    # Redis password
    while true; do
        read -s -p "Enter Redis password (leave empty for auto-generate): " REDIS_PASS
        echo
        if [[ -z "$REDIS_PASS" ]]; then
            REDIS_PASS=$(generate_password)
            print_success "Auto-generated Redis password: $REDIS_PASS"
            break
        elif [[ ${#REDIS_PASS} -lt 8 ]]; then
            print_error "Password must be at least 8 characters long."
        else
            break
        fi
    done

    # JWT secrets
    JWT_SECRET=$(generate_password)
    JWT_REFRESH_SECRET=$(generate_password)
    SESSION_SECRET=$(generate_password)
    CSRF_SECRET=$(generate_password)
    print_success "Generated JWT and session secrets"

    # Email configuration
    while true; do
        read -p "Enter SMTP email (e.g., noreply@ibusiness.id): " EMAIL_USER
        if validate_email "$EMAIL_USER"; then
            break
        else
            print_error "Invalid email format. Please try again."
        fi
    done

    while true; do
        read -s -p "Enter SMTP password: " EMAIL_PASS
        echo
        if [[ ${#EMAIL_PASS} -lt 8 ]]; then
            print_error "Password must be at least 8 characters long."
        else
            break
        fi
    done

    # Admin user
    while true; do
        read -p "Enter admin email: " ADMIN_EMAIL
        if validate_email "$ADMIN_EMAIL"; then
            break
        else
            print_error "Invalid email format. Please try again."
        fi
    done

    while true; do
        read -s -p "Enter admin password: " ADMIN_PASS
        echo
        if [[ ${#ADMIN_PASS} -lt 8 ]]; then
            print_error "Password must be at least 8 characters long."
        else
            break
        fi
    done

    # Installation path
    read -p "Enter installation path (default: /www/wwwroot/ibusiness.id): " INSTALL_PATH
    INSTALL_PATH=${INSTALL_PATH:-"/www/wwwroot/ibusiness.id"}

    # Node.js version
    read -p "Enter Node.js version (default: 18): " NODE_VERSION
    NODE_VERSION=${NODE_VERSION:-"18"}

    print_success "All information collected successfully"
}

# Function to update system
update_system() {
    print_status "Updating system packages..."
    apt update && apt upgrade -y
    print_success "System updated successfully"
}

# Function to install basic dependencies
install_dependencies() {
    print_status "Installing basic dependencies..."
    apt install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release unzip
    print_success "Basic dependencies installed"
}

# Function to install aaPanel
install_aapanel() {
    print_status "Installing aaPanel..."
    curl -sSL http://www.aapanel.com/script/install-ubuntu_6.0_en.sh | bash
    print_success "aaPanel installed successfully"
    print_warning "Please note your aaPanel login credentials displayed above"
}

# Function to install Node.js
install_nodejs() {
    print_status "Installing Node.js $NODE_VERSION..."
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt install -y nodejs
    print_success "Node.js $NODE_VERSION installed successfully"
}

# Function to install MongoDB
install_mongodb() {
    print_status "Installing MongoDB..."
    curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    apt update
    apt install -y mongodb-org
    systemctl start mongod
    systemctl enable mongod
    print_success "MongoDB installed and started"
}

# Function to install Redis
install_redis() {
    print_status "Installing Redis..."
    apt install -y redis-server
    systemctl start redis-server
    systemctl enable redis-server
    print_success "Redis installed and started"
}

# Function to install PM2
install_pm2() {
    print_status "Installing PM2..."
    npm install -g pm2
    print_success "PM2 installed successfully"
}

# Function to configure MongoDB
configure_mongodb() {
    print_status "Configuring MongoDB..."

    # Create admin user
    mongosh --eval "
        use admin;
        db.createUser({
            user: '$DB_USER',
            pwd: '$DB_PASS',
            roles: ['userAdminAnyDatabase', 'dbAdminAnyDatabase', 'readWriteAnyDatabase']
        });
    "

    # Update MongoDB configuration for authentication
    cat > /etc/mongod.conf << EOF
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 127.0.0.1

security:
  authorization: enabled

processManagement:
  timeZoneInfo: /usr/share/zoneinfo
EOF

    systemctl restart mongod
    print_success "MongoDB configured with authentication"
}

# Function to configure Redis
configure_redis() {
    print_status "Configuring Redis..."

    # Update Redis configuration
    sed -i 's/^# requirepass .*/requirepass '"$REDIS_PASS"'/' /etc/redis/redis.conf
    sed -i 's/^bind 127.0.0.1 ::1/bind 127.0.0.1/' /etc/redis/redis.conf

    systemctl restart redis-server
    print_success "Redis configured with password"
}

# Function to create application directory
create_app_directory() {
    print_status "Creating application directory..."
    mkdir -p "$INSTALL_PATH"
    chown -R www:www "$INSTALL_PATH"
    print_success "Application directory created at $INSTALL_PATH"
}

# Function to deploy application
deploy_application() {
    print_status "Deploying iBusiness application..."

    # Copy application files (assuming they're in the same directory as the script)
    if [[ -d "./backend" ]]; then
        cp -r ./backend/* "$INSTALL_PATH/"
    else
        print_error "Backend directory not found. Please ensure the application files are in the correct location."
        exit 1
    fi

    cd "$INSTALL_PATH"

    # Install dependencies
    npm install --production

    print_success "Application deployed successfully"
}

# Function to create environment file
create_env_file() {
    print_status "Creating environment configuration..."

    cat > "$INSTALL_PATH/.env" << EOF
# Environment Configuration for iBusiness.id Backend
# Generated by installation script

# Node Environment
NODE_ENV=production

# Server Configuration
PORT=3000

# Database Configuration
MONGODB_URI=mongodb://$DB_USER:$DB_PASS@127.0.0.1:27017/ibusiness?authSource=admin
MONGODB_TEST_URI=mongodb://$DB_USER:$DB_PASS@127.0.0.1:27017/ibusiness_test?authSource=admin

# Redis Configuration
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=$REDIS_PASS

# JWT Configuration
JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=$JWT_REFRESH_SECRET
JWT_REFRESH_EXPIRES_IN=30d

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=$EMAIL_USER
EMAIL_PASS=$EMAIL_PASS
EMAIL_FROM=$EMAIL_USER

# Security Configuration
CORS_ORIGIN=https://$DOMAIN,http://$DOMAIN
SESSION_SECRET=$SESSION_SECRET
CSRF_SECRET=$CSRF_SECRET

# File Upload Configuration
FILE_UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880
MAX_FILES_COUNT=10

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging Configuration
LOG_LEVEL=info
LOG_FILE_PATH=./logs/app.log

# Other Configuration
BCRYPT_ROUNDS=10
API_VERSION=v1
EOF

    print_success "Environment file created"
}

# Function to setup PM2
setup_pm2() {
    print_status "Setting up PM2 process..."

    cd "$INSTALL_PATH"

    # Create PM2 ecosystem file
    cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'ibusiness-api',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    log_file: './logs/pm2-combined.log',
    time: true,
    watch: false,
    max_memory_restart: '1G',
    restart_delay: 4000,
    autorestart: true
  }]
};
EOF

    # Start application with PM2
    pm2 start ecosystem.config.js
    pm2 save
    pm2 startup

    print_success "PM2 process configured and started"
}

# Function to configure Nginx
configure_nginx() {
    print_status "Configuring Nginx reverse proxy..."

    # Create Nginx configuration
    cat > /www/server/panel/vhost/nginx/$DOMAIN.conf << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/wwwroot/$DOMAIN;

    # Load configuration files for the default server block.
    include /www/server/panel/vhost/nginx/*.conf;

    # iBusiness API proxy
    location /api {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;

        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;

    access_log /www/wwwlogs/$DOMAIN.log;
    error_log /www/wwwlogs/$DOMAIN.error.log;
}
EOF

    # Reload Nginx
    nginx -t && systemctl reload nginx

    print_success "Nginx configured for $DOMAIN"
}

# Function to setup SSL
setup_ssl() {
    print_status "Setting up SSL certificate..."

    # Install certbot if not present
    apt install -y certbot python3-certbot-nginx

    # Obtain SSL certificate
    certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL

    print_success "SSL certificate configured for $DOMAIN"
}

# Function to setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring..."

    # Install monitoring tools
    apt install -y htop iotop sysstat

    # Create monitoring script
    cat > /usr/local/bin/ibusiness-monitor.sh << 'EOF'
#!/bin/bash

echo "=== iBusiness Monitoring Report ==="
echo "Date: $(date)"
echo ""

echo "=== System Resources ==="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
echo ""

echo "Memory Usage:"
free -h
echo ""

echo "Disk Usage:"
df -h
echo ""

echo "=== Services Status ==="
echo "MongoDB: $(systemctl is-active mongod)"
echo "Redis: $(systemctl is-active redis-server)"
echo "Nginx: $(systemctl is-active nginx)"
echo ""

echo "=== Application Status ==="
pm2 list
echo ""

echo "=== Network Connections ==="
netstat -tlnp | grep :3000 || echo "Port 3000 not listening"
echo ""

echo "=== Recent Logs ==="
echo "Last 10 application logs:"
tail -10 /www/wwwroot/ibusiness.id/logs/pm2-combined.log 2>/dev/null || echo "No logs found"
echo ""
EOF

    chmod +x /usr/local/bin/ibusiness-monitor.sh

    # Setup log rotation
    cat > /etc/logrotate.d/ibusiness << EOF
/www/wwwroot/ibusiness.id/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www www
    postrotate
        pm2 reloadLogs
    endscript
}
EOF

    print_success "Monitoring configured"
}

# Function to create admin user
create_admin_user() {
    print_status "Creating admin user..."

    cd "$INSTALL_PATH"

    # Create a temporary script to create admin user
    cat > create_admin.js << EOF
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('./models/User');

async function createAdmin() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);

        const hashedPassword = await bcrypt.hash('$ADMIN_PASS', 10);

        const adminUser = new User({
            email: '$ADMIN_EMAIL',
            password: hashedPassword,
            name: 'Administrator',
            role: 'super_admin',
            emailVerified: true,
            isActive: true
        });

        await adminUser.save();
        console.log('Admin user created successfully');

        // Create referral code
        adminUser.referralCode = adminUser._id.toString().substr(-8).toUpperCase();
        await adminUser.save();

        console.log('Admin user referral code generated');
    } catch (error) {
        console.error('Error creating admin user:', error);
    } finally {
        await mongoose.connection.close();
    }
}

createAdmin();
EOF

    # Run the script
    node create_admin.js

    # Clean up
    rm create_admin.js

    print_success "Admin user created"
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."

    # Check services
    services=("mongod" "redis-server" "nginx")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            print_success "$service is running"
        else
            print_error "$service is not running"
        fi
    done

    # Check PM2
    if pm2 list | grep -q "ibusiness-api"; then
        print_success "PM2 process is running"
    else
        print_error "PM2 process is not running"
    fi

    # Check application
    if curl -s http://localhost:3000 | grep -q "iBusiness"; then
        print_success "Application is responding"
    else
        print_error "Application is not responding"
    fi

    print_success "Installation verification completed"
}

# Function to display completion message
display_completion() {
    print_success "iBusiness.id installation completed successfully!"
    echo ""
    echo "=== Installation Summary ==="
    echo "Domain: $DOMAIN"
    echo "Installation Path: $INSTALL_PATH"
    echo "MongoDB User: $DB_USER"
    echo "MongoDB Password: $DB_PASS"
    echo "Redis Password: $REDIS_PASS"
    echo "Admin Email: $ADMIN_EMAIL"
    echo "Admin Password: $ADMIN_PASS"
    echo ""
    echo "=== Important URLs ==="
    echo "Application: https://$DOMAIN"
    echo "API: https://$DOMAIN/api"
    echo "aaPanel: https://$(hostname -I | awk '{print $1}'):8888"
    echo ""
    echo "=== Next Steps ==="
    echo "1. Access aaPanel and configure your website"
    echo "2. Update DNS records to point to this server"
    echo "3. Test the application at https://$DOMAIN"
    echo "4. Monitor logs: pm2 logs ibusiness-api"
    echo "5. Run monitoring: ibusiness-monitor.sh"
    echo ""
    echo "=== Security Notes ==="
    echo "- Change default passwords after first login"
    echo "- Keep your server updated"
    echo "- Monitor logs regularly"
    echo "- Backup your data regularly"
    echo ""
    print_success "Installation completed at $(date)"
}

# Main installation function
main() {
    print_status "Starting iBusiness.id installation script v1.0.0"

    check_root
    collect_user_input

    update_system
    install_dependencies
    install_aapanel
    install_nodejs
    install_mongodb
    install_redis
    install_pm2

    configure_mongodb
    configure_redis

    create_app_directory
    deploy_application
    create_env_file

    setup_pm2
    configure_nginx
    setup_ssl
    setup_monitoring

    create_admin_user
    verify_installation

    display_completion
}

# Run main function
main "$@"