# Ubuntu System Administration Guide

## User and Group Management

### User Management

#### Creating Users

```bash
# Create new user with home directory
sudo adduser username

# Create user with specific shell
sudo useradd -m -s /bin/bash username

# Create system user (no home directory)
sudo useradd -r -s /bin/false systemuser

# Create user with specific UID
sudo useradd -u 1500 username
```

#### Modifying Users

```bash
# Change user password
sudo passwd username

# Lock user account
sudo passwd -l username

# Unlock user account
sudo passwd -u username

# Change user shell
sudo chsh -s /bin/zsh username

# Change user's home directory
sudo usermod -d /new/home/path username

# Add user to group
sudo usermod -a -G groupname username

# Change user's primary group
sudo usermod -g newgroup username
```

#### User Information

```bash
# Display user information
id username
finger username
getent passwd username

# List logged-in users
who
w
users

# Show user's groups
groups username

# Display last login information
lastlog
last username
```

### Group Management

#### Creating and Managing Groups

```bash
# Create new group
sudo addgroup groupname
sudo groupadd groupname

# Delete group
sudo delgroup groupname
sudo groupdel groupname

# Add user to group
sudo gpasswd -a username groupname

# Remove user from group
sudo gpasswd -d username groupname

# List all groups
getent group
cat /etc/group
```

## Service Management with systemd

### Basic systemctl Commands

```bash
# Start a service
sudo systemctl start servicename

# Stop a service
sudo systemctl stop servicename

# Restart a service
sudo systemctl restart servicename

# Reload service configuration
sudo systemctl reload servicename

# Enable service to start at boot
sudo systemctl enable servicename

# Disable service from starting at boot
sudo systemctl disable servicename

# Check service status
systemctl status servicename

# Check if service is active
systemctl is-active servicename

# Check if service is enabled
systemctl is-enabled servicename
```

### Service Information and Troubleshooting

```bash
# List all services
systemctl list-units --type=service

# List failed services
systemctl --failed

# List enabled services
systemctl list-unit-files --state=enabled

# Show service logs
journalctl -u servicename

# Follow service logs in real-time
journalctl -u servicename -f

# Show logs since last boot
journalctl -u servicename -b

# Show logs for specific time period
journalctl -u servicename --since "2023-01-01" --until "2023-01-31"
```

### Creating Custom Services

```bash
# Create service file
sudo nano /etc/systemd/system/myservice.service
```

Example service file:

```ini
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/path/to/working/directory
ExecStart=/path/to/executable
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable myservice
sudo systemctl start myservice
```

## Network Configuration

### Network Interface Management

#### Using netplan (Ubuntu 18.04+)

```bash
# Edit network configuration
sudo nano /etc/netplan/01-netcfg.yaml
```

Example netplan configuration:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```bash
# Apply network configuration
sudo netplan apply

# Test configuration
sudo netplan try
```

#### Legacy Network Tools

```bash
# Configure interface (temporary)
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0

# Bring interface up/down
sudo ifconfig eth0 up
sudo ifconfig eth0 down

# Add route
sudo route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.1.1

# Delete route
sudo route del -net 192.168.2.0 netmask 255.255.255.0
```

### Network Diagnostics

```bash
# Check network connectivity
ping google.com
ping -c 4 8.8.8.8

# Trace network path
traceroute google.com
tracepath google.com

# DNS lookup
nslookup google.com
dig google.com

# Check open ports
netstat -tuln
ss -tuln

# Monitor network traffic
sudo iftop
sudo nethogs
```

## Firewall Management (UFW)

### Basic UFW Commands

```bash
# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Check firewall status
sudo ufw status
sudo ufw status verbose

# Reset firewall rules
sudo ufw --force reset
```

### Managing Rules

```bash
# Allow specific port
sudo ufw allow 22
sudo ufw allow 80/tcp
sudo ufw allow 53/udp

# Allow specific service
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Allow from specific IP
sudo ufw allow from 192.168.1.100

# Allow from IP range
sudo ufw allow from 192.168.1.0/24

# Deny connections
sudo ufw deny 23
sudo ufw deny from 192.168.1.100

# Delete rules
sudo ufw delete allow 80
sudo ufw delete 3  # Delete rule number 3
```

### Advanced UFW Configuration

```bash
# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow specific application profiles
sudo ufw app list
sudo ufw allow "Apache Full"

# Rate limiting
sudo ufw limit ssh

# Logging
sudo ufw logging on
sudo ufw logging medium
```

## System Monitoring and Performance

### Process Management

```bash
# List processes
ps aux
ps -ef

# Process tree
pstree

# Interactive process viewer
top
htop

# Kill process by PID
kill PID
kill -9 PID  # Force kill

# Kill process by name
killall processname
pkill processname

# Background jobs
jobs
bg %1
fg %1
nohup command &
```

### System Resources

```bash
# Memory usage
free -h
cat /proc/meminfo

# Disk usage
df -h
du -sh /path/to/directory

# Disk I/O
iostat
iotop

# CPU information
lscpu
cat /proc/cpuinfo

# System load
uptime
w
```

### Log File Management

```bash
# View system logs
sudo journalctl

# View specific service logs
sudo journalctl -u servicename

# View logs in real-time
sudo journalctl -f

# View logs by priority
sudo journalctl -p err

# View logs for specific time
sudo journalctl --since "1 hour ago"
sudo journalctl --since "2023-01-01 00:00:00"

# Disk usage of journal logs
sudo journalctl --disk-usage

# Clean old logs
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=500M
```

## File System Management

### Disk Partitioning

```bash
# List disks and partitions
lsblk
fdisk -l
parted -l

# Partition a disk
sudo fdisk /dev/sdb
sudo parted /dev/sdb

# Create file system
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.xfs /dev/sdb1
```

### Mounting File Systems

```bash
# Mount temporarily
sudo mount /dev/sdb1 /mnt/data

# Unmount
sudo umount /mnt/data

# Mount with options
sudo mount -o rw,noexec /dev/sdb1 /mnt/data

# Edit fstab for permanent mounts
sudo nano /etc/fstab
```

Example fstab entry:

```
/dev/sdb1 /mnt/data ext4 defaults,noexec 0 2
```

### File System Maintenance

```bash
# Check file system
sudo fsck /dev/sdb1
sudo fsck.ext4 /dev/sdb1

# Resize file system
sudo resize2fs /dev/sdb1

# Create and manage LVM
sudo pvcreate /dev/sdb1
sudo vgcreate myvg /dev/sdb1
sudo lvcreate -L 10G -n mylv myvg
```

This guide covers essential system administration tasks for Ubuntu systems, including user management, service control, network configuration, and system monitoring.
