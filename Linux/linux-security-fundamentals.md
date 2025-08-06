# Linux Security Fundamentals

## File Permissions and Access Control

### Understanding File Permissions

Linux uses a permission system based on three types of access for three categories of users:

#### Permission Types
- **Read (r)**: View file contents or list directory contents
- **Write (w)**: Modify file contents or create/delete files in directory
- **Execute (x)**: Run file as program or access directory

#### User Categories
- **Owner (u)**: The user who owns the file
- **Group (g)**: Users belonging to the file's group
- **Other (o)**: All other users

### Viewing Permissions

```bash
# List files with permissions
ls -l
ls -la  # Include hidden files

# Example output explanation:
# -rwxr-xr-- 1 user group 1024 Jan 1 12:00 filename
# |||||||||
# ||||||||└─ other permissions (r--)
# |||||└─ group permissions (r-x)
# ||└─ owner permissions (rwx)
# |└─ file type (- = file, d = directory, l = link)
# └─ special permissions
```

### Changing Permissions

#### Symbolic Method

```bash
# Add permissions
chmod u+x file.txt        # Add execute for owner
chmod g+w file.txt        # Add write for group
chmod o+r file.txt        # Add read for others
chmod a+x file.txt        # Add execute for all

# Remove permissions
chmod u-w file.txt        # Remove write from owner
chmod g-x file.txt        # Remove execute from group
chmod o-r file.txt        # Remove read from others

# Set exact permissions
chmod u=rwx,g=rx,o=r file.txt

# Complex combinations
chmod u+x,g-w,o=r file.txt
```

#### Numeric Method

```bash
# Permission values:
# 4 = read (r)
# 2 = write (w)
# 1 = execute (x)

# Common permission combinations:
chmod 755 file.txt        # rwxr-xr-x
chmod 644 file.txt        # rw-r--r--
chmod 600 file.txt        # rw-------
chmod 777 file.txt        # rwxrwxrwx (dangerous!)
chmod 000 file.txt        # --------- (no permissions)

# Apply to directories recursively
chmod -R 755 /path/to/directory
```

### Special Permissions

#### Setuid (SUID) - 4000

```bash
# Set SUID bit
chmod u+s executable
chmod 4755 executable

# Example: passwd command has SUID
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root passwd
```

#### Setgid (SGID) - 2000

```bash
# Set SGID on file
chmod g+s executable
chmod 2755 executable

# Set SGID on directory (new files inherit group)
chmod g+s /shared/directory
```

#### Sticky Bit - 1000

```bash
# Set sticky bit (commonly on /tmp)
chmod +t directory
chmod 1755 directory

# Example: /tmp directory
ls -ld /tmp
# drwxrwxrwt 10 root root /tmp
```

### File Ownership

```bash
# Change owner
sudo chown username file.txt
sudo chown username:groupname file.txt

# Change group only
sudo chgrp groupname file.txt

# Recursive ownership change
sudo chown -R username:groupname /path/to/directory

# Copy ownership from another file
sudo chown --reference=source.txt target.txt
```

## Access Control Lists (ACLs)

### Installing ACL Support

```bash
# Install ACL utilities
sudo apt install acl

# Mount filesystem with ACL support
sudo mount -o remount,acl /
```

### Basic ACL Commands

```bash
# View ACLs
getfacl filename

# Set ACL for specific user
setfacl -m u:username:rwx filename

# Set ACL for specific group
setfacl -m g:groupname:rw filename

# Set default ACL for directory
setfacl -d -m u:username:rwx directory/

# Remove ACL
setfacl -x u:username filename

# Remove all ACLs
setfacl -b filename

# Copy ACLs between files
getfacl source.txt | setfacl --set-file=- target.txt
```

## User Account Security

### Password Policies

```bash
# Install password quality checking
sudo apt install libpam-pwquality

# Configure password policy
sudo nano /etc/security/pwquality.conf
```

Example pwquality.conf settings:

```
minlen = 12
minclass = 3
maxrepeat = 2
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
```

### Account Locking

```bash
# Lock user account
sudo passwd -l username
sudo usermod -L username

# Unlock user account
sudo passwd -u username
sudo usermod -U username

# Set account expiration
sudo chage -E 2024-12-31 username

# View account information
sudo chage -l username
```

### Failed Login Monitoring

```bash
# Install fail2ban
sudo apt install fail2ban

# Configure fail2ban
sudo nano /etc/fail2ban/jail.local
```

Example jail.local configuration:

```ini
[DEFAULT]
bantime = 600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
```

## SSH Security

### SSH Configuration Hardening

```bash
# Edit SSH daemon configuration
sudo nano /etc/ssh/sshd_config
```

Security recommendations:

```
# Change default port
Port 2222

# Disable root login
PermitRootLogin no

# Use key-based authentication only
PasswordAuthentication no
PubkeyAuthentication yes

# Limit user access
AllowUsers username
DenyUsers baduser

# Disable empty passwords
PermitEmptyPasswords no

# Set login grace time
LoginGraceTime 30

# Limit authentication attempts
MaxAuthTries 3

# Use protocol 2 only
Protocol 2
```

### SSH Key Management

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "email@example.com"
ssh-keygen -t ed25519 -C "email@example.com"

# Copy public key to server
ssh-copy-id user@server
ssh-copy-id -i ~/.ssh/key.pub user@server

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
```

### SSH Connection Security

```bash
# Use SSH agent for key management
ssh-agent
ssh-add ~/.ssh/id_rsa

# SSH with specific key
ssh -i ~/.ssh/specific_key user@server

# SSH tunneling (port forwarding)
ssh -L 8080:localhost:80 user@server
ssh -R 8080:localhost:80 user@server
ssh -D 1080 user@server  # SOCKS proxy
```

## System Hardening

### Disable Unnecessary Services

```bash
# List running services
systemctl list-units --type=service --state=running

# Disable unnecessary services
sudo systemctl disable avahi-daemon
sudo systemctl disable bluetooth
sudo systemctl disable cups

# Mask services to prevent activation
sudo systemctl mask service-name
```

### Kernel Security Parameters

```bash
# Edit sysctl configuration
sudo nano /etc/sysctl.conf
```

Security-related sysctl settings:

```
# Disable IP forwarding
net.ipv4.ip_forward = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0

# Enable SYN cookies
net.ipv4.tcp_syncookies = 1

# Disable ping responses
net.ipv4.icmp_echo_ignore_all = 1

# Apply changes
sudo sysctl -p
```

### File System Security

```bash
# Mount filesystems with security options
# Example /etc/fstab entries:
/dev/sdb1 /tmp ext4 defaults,noexec,nosuid,nodev 0 2
/dev/sdc1 /var/log ext4 defaults,noexec,nosuid,nodev 0 2

# Set immutable attribute on important files
sudo chattr +i /etc/passwd
sudo chattr +i /etc/shadow

# Remove immutable attribute
sudo chattr -i /etc/passwd

# View file attributes
lsattr filename
```

## Monitoring and Auditing

### System Monitoring Tools

```bash
# Monitor file changes
sudo apt install inotify-tools

# Watch directory for changes
inotifywait -m -r /etc --format '%w%f %e' --event modify,create,delete

# Monitor network connections
sudo netstat -tulpn
sudo ss -tulpn

# Check for rootkits
sudo apt install rkhunter chkrootkit
sudo rkhunter --check
sudo chkrootkit
```

### Log Monitoring

```bash
# Monitor authentication logs
sudo tail -f /var/log/auth.log

# Monitor system logs
sudo tail -f /var/log/syslog

# Monitor failed login attempts
sudo grep "Failed password" /var/log/auth.log

# Monitor sudo usage
sudo grep "sudo" /var/log/auth.log
```

### System Auditing with auditd

```bash
# Install audit daemon
sudo apt install auditd

# Configure audit rules
sudo nano /etc/audit/rules.d/audit.rules
```

Example audit rules:

```
# Monitor passwd file changes
-w /etc/passwd -p wa -k passwd_changes

# Monitor sudo usage
-w /usr/bin/sudo -p x -k sudo_usage

# Monitor file deletions
-a always,exit -F arch=b64 -S unlink -S unlinkat -k delete

# Monitor network connections
-a always,exit -F arch=b64 -S socket -F a0=2 -k network
```

```bash
# Restart auditd
sudo systemctl restart auditd

# Search audit logs
sudo ausearch -k passwd_changes
sudo ausearch -ts today -k sudo_usage
```

This guide covers fundamental security concepts and practices for Linux systems, focusing on access control, system hardening, and monitoring techniques essential for maintaining secure Ubuntu systems.
