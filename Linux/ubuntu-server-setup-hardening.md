# Ubuntu Server Setup and Hardening Guide

## Initial Server Setup

### Basic System Configuration

#### Update System Packages

```bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget vim git htop tree unzip software-properties-common

# Install build essentials
sudo apt install -y build-essential

# Clean up
sudo apt autoremove -y
sudo apt autoclean
```

#### Configure Timezone and Locale

```bash
# Set timezone
sudo timedatectl set-timezone America/New_York
timedatectl status

# Configure locale
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Set hostname
sudo hostnamectl set-hostname myserver
hostnamectl status
```

#### Create Non-Root User

```bash
# Create new user with sudo privileges
sudo adduser username
sudo usermod -aG sudo username

# Switch to new user
su - username

# Test sudo access
sudo whoami
```

### SSH Hardening

#### Key-Based Authentication Setup

```bash
# Generate SSH key pair (on client)
ssh-keygen -t ed25519 -b 4096 -f ~/.ssh/server_key

# Copy public key to server
ssh-copy-id -i ~/.ssh/server_key.pub username@server_ip

# Test key-based login
ssh -i ~/.ssh/server_key username@server_ip
```

#### SSH Daemon Configuration

```bash
# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH configuration
sudo nano /etc/ssh/sshd_config
```

Recommended SSH hardening settings:

```bash
# Basic security settings
Port 2222
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Additional security measures
MaxAuthTries 3
LoginGraceTime 30
MaxStartups 3
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable dangerous features
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no
PermitEmptyPasswords no
PermitUserEnvironment no

# Restrict users (optional)
AllowUsers username
DenyUsers root
```

```bash
# Validate configuration
sudo sshd -t

# Restart SSH service
sudo systemctl restart sshd

# Check SSH status
sudo systemctl status sshd
```

## Firewall Configuration

### UFW (Uncomplicated Firewall) Setup

```bash
# Install UFW (usually pre-installed)
sudo apt install ufw

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (adjust port if changed)
sudo ufw allow 2222/tcp

# Allow common services
sudo ufw allow http
sudo ufw allow https

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

### Advanced Firewall Rules

```bash
# Allow from specific IP
sudo ufw allow from 192.168.1.100

# Allow from subnet
sudo ufw allow from 192.168.1.0/24

# Rate limiting for SSH
sudo ufw limit 2222/tcp

# Allow port range
sudo ufw allow 60000:61000/tcp

# Deny specific IP
sudo ufw deny from 192.168.1.50

# Log firewall activity
sudo ufw logging medium
```

## System Hardening

### Automatic Security Updates

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Configure automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Edit configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

Example unattended-upgrades configuration:

```bash
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
```

### Fail2Ban Installation and Configuration

```bash
# Install Fail2Ban
sudo apt install fail2ban

# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo nano /etc/fail2ban/jail.local
```

Example Fail2Ban configuration:

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = admin@example.com
sendername = Fail2Ban
mta = sendmail

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache*/*error.log
maxretry = 6

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
```

```bash
# Start and enable Fail2Ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### Kernel Hardening

```bash
# Edit sysctl configuration
sudo nano /etc/sysctl.conf
```

Add security-focused kernel parameters:

```bash
# Network security
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# TCP stack hardening
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# Memory protection
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1

# File system security
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.suid_dumpable = 0
```

```bash
# Apply changes
sudo sysctl -p

# Verify settings
sudo sysctl -a | grep net.ipv4.ip_forward
```

## Monitoring and Logging

### System Monitoring Setup

```bash
# Install monitoring tools
sudo apt install htop iotop nethogs iftop

# Install and configure logwatch
sudo apt install logwatch

# Configure logwatch
sudo nano /etc/logwatch/conf/logwatch.conf
```

Example logwatch configuration:

```ini
LogDir = /var/log
MailTo = admin@example.com
MailFrom = logwatch@server.local
Detail = Med
Service = All
Range = yesterday
Format = html
```

### Log Rotation Configuration

```bash
# Check current logrotate configuration
cat /etc/logrotate.conf

# Create custom logrotate rule
sudo nano /etc/logrotate.d/myapp
```

Example logrotate configuration:

```bash
/var/log/myapp/*.log {
    weekly
    rotate 52
    compress
    delaycompress
    missingok
    create 644 myapp myapp
    postrotate
        systemctl reload myapp
    endscript
}
```

### Centralized Logging with rsyslog

```bash
# Configure rsyslog for remote logging
sudo nano /etc/rsyslog.conf

# Enable reception of logs (on log server)
# Uncomment these lines:
# module(load="imudp")
# input(type="imudp" port="514")

# Send logs to remote server (on clients)
# Add at end of file:
# *.* @@logserver.domain.com:514

# Restart rsyslog
sudo systemctl restart rsyslog
```

## Backup and Recovery

### Automated Backup Script

```bash
# Create backup script
sudo nano /usr/local/bin/backup.sh
```

Example backup script:

```bash
#!/bin/bash

# Backup configuration script
BACKUP_SOURCE="/etc /home /var/www"
BACKUP_DEST="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="server_backup_$DATE.tar.gz"
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DEST

# Create compressed backup
tar -czf "$BACKUP_DEST/$BACKUP_NAME" $BACKUP_SOURCE

# Remove old backups
find $BACKUP_DEST -name "server_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Log backup completion
echo "$(date): Backup $BACKUP_NAME completed" >> /var/log/backup.log

# Optional: Send to remote location
# rsync -av "$BACKUP_DEST/$BACKUP_NAME" user@backupserver:/remote/backup/
```

```bash
# Make script executable
sudo chmod +x /usr/local/bin/backup.sh

# Add to crontab for automation
sudo crontab -e

# Add line for daily 2 AM backup
0 2 * * * /usr/local/bin/backup.sh
```

### System State Backup

```bash
# Backup package list
dpkg --get-selections > installed-packages.txt

# Backup repository sources
sudo cp -R /etc/apt/sources.list* /backup/

# Backup user accounts
sudo cp /etc/passwd /etc/group /etc/shadow /backup/

# Backup important configurations
sudo tar -czf /backup/config_backup.tar.gz /etc/ssh /etc/nginx /etc/apache2 /etc/mysql
```

## Performance Optimization

### System Resource Optimization

```bash
# Optimize swappiness for servers
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Optimize file system performance
echo 'vm.dirty_ratio=15' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.conf

# Network buffer optimization
echo 'net.core.rmem_max=16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.core.wmem_max=16777216' | sudo tee -a /etc/sysctl.conf
```

### Service Optimization

```bash
# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable avahi-daemon

# List all services
systemctl list-unit-files --type=service

# Check what's using system resources
sudo systemctl status
ps aux --sort=-pcpu | head -10
ps aux --sort=-pmem | head -10
```

## Security Auditing

### System Security Scanning

```bash
# Install security tools
sudo apt install lynis rkhunter chkrootkit

# Run Lynis security audit
sudo lynis audit system

# Run rootkit scanner
sudo rkhunter --check
sudo chkrootkit

# Check for weak passwords
sudo john /etc/shadow
```

### File Integrity Monitoring

```bash
# Install AIDE (Advanced Intrusion Detection Environment)
sudo apt install aide

# Initialize AIDE database
sudo aideinit

# Move database to expected location
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Run integrity check
sudo aide --check

# Update database after legitimate changes
sudo aide --update
```

### Regular Security Maintenance

Create a security maintenance script:

```bash
#!/bin/bash

# Security maintenance script
LOG_FILE="/var/log/security_maintenance.log"
DATE=$(date)

echo "[$DATE] Starting security maintenance" >> $LOG_FILE

# Update system
sudo apt update && sudo apt upgrade -y

# Update ClamAV signatures
sudo freshclam

# Run rootkit check
sudo rkhunter --check --sk

# Check for failed login attempts
sudo grep "Failed password" /var/log/auth.log | tail -10 >> $LOG_FILE

# Check listening ports
ss -tuln >> $LOG_FILE

# Check running processes
ps aux --sort=-pcpu | head -10 >> $LOG_FILE

echo "[$DATE] Security maintenance completed" >> $LOG_FILE
```

This comprehensive guide provides a solid foundation for setting up and hardening Ubuntu servers with security best practices, monitoring, and maintenance procedures.
