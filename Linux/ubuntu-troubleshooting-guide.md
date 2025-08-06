# Ubuntu Troubleshooting Guide

## System Boot Issues

### GRUB Boot Problems

#### GRUB Not Loading

```bash
# Boot from Ubuntu live USB/CD
# Mount the root filesystem
sudo mkdir /mnt/ubuntu
sudo mount /dev/sda1 /mnt/ubuntu  # Adjust device as needed

# Mount other required filesystems
sudo mount --bind /dev /mnt/ubuntu/dev
sudo mount --bind /proc /mnt/ubuntu/proc
sudo mount --bind /sys /mnt/ubuntu/sys

# Chroot into the system
sudo chroot /mnt/ubuntu

# Reinstall GRUB
grub-install /dev/sda
update-grub

# Exit chroot and reboot
exit
sudo umount /mnt/ubuntu/dev
sudo umount /mnt/ubuntu/proc
sudo umount /mnt/ubuntu/sys
sudo umount /mnt/ubuntu
sudo reboot
```

#### GRUB Configuration Issues

```bash
# Reconfigure GRUB
sudo update-grub

# Edit GRUB configuration
sudo nano /etc/default/grub

# Common GRUB parameters:
GRUB_DEFAULT=0
GRUB_TIMEOUT=10
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""

# Apply changes
sudo update-grub

# Manually edit GRUB menu (temporary)
# At GRUB menu, press 'e' to edit
# Modify kernel parameters
# Press Ctrl+X to boot
```

### Kernel Boot Issues

#### Kernel Panic Recovery

```bash
# Boot with previous kernel version
# Select "Advanced options" in GRUB menu
# Choose older kernel version

# Boot in recovery mode
# Select "Recovery mode" from GRUB menu
# Choose "root" option for root shell

# Boot with minimal parameters
# Edit GRUB entry and remove:
# quiet splash
# Add:
# nomodeset single init=/bin/bash

# Common kernel parameters for troubleshooting:
# nomodeset     - Disable kernel mode setting
# acpi=off      - Disable ACPI
# noapic        - Disable APIC
# single        - Single user mode
# init=/bin/bash - Direct shell access
```

#### Hardware Detection Issues

```bash
# Check hardware detection
lspci
lsusb
lshw
dmesg | grep -i error
dmesg | grep -i fail

# Check loaded modules
lsmod
modinfo module_name

# Load missing modules
sudo modprobe module_name

# Blacklist problematic modules
sudo nano /etc/modprobe.d/blacklist-local.conf
# Add: blacklist module_name

# Update initramfs
sudo update-initramfs -u
```

## System Performance Issues

### High CPU Usage

#### Identifying CPU-Heavy Processes

```bash
# Find top CPU consumers
top
htop
ps aux --sort=-pcpu | head -10

# Monitor CPU usage over time
sar -u 1 10
iostat -c 1 10

# Check system load
uptime
cat /proc/loadavg

# Monitor specific process
pidstat -u -p PID 1 10
```

#### CPU Usage Troubleshooting

```bash
# Check for CPU frequency scaling issues
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
cpupower frequency-info

# Set performance governor
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Check for thermal throttling
sensors
cat /proc/cpuinfo | grep MHz

# Monitor interrupts
cat /proc/interrupts
watch -n 1 'cat /proc/interrupts'
```

### Memory Issues

#### Out of Memory Problems

```bash
# Check memory usage
free -h
cat /proc/meminfo

# Find memory-hungry processes
ps aux --sort=-pmem | head -10
pmap -x PID

# Check swap usage
swapon --show
cat /proc/swaps

# Monitor memory over time
vmstat 1 10
sar -r 1 10
```

#### Memory Leak Detection

```bash
# Monitor process memory growth
while true; do
    ps -o pid,vsz,rss,comm -p PID
    sleep 60
done

# Use valgrind for detailed analysis
valgrind --tool=memcheck --leak-check=full program

# Check system memory allocation
cat /proc/buddyinfo
cat /proc/pagetypeinfo
```

### Disk Space and I/O Issues

#### Disk Space Problems

```bash
# Check disk usage
df -h
du -sh /*
du -sh /var/* | sort -hr

# Find large files
find / -type f -size +100M 2>/dev/null
find /var -type f -size +50M 2>/dev/null

# Check inodes usage
df -i

# Find directories with many files
find / -type d -exec sh -c 'echo "{}: $(ls -1 "{}" | wc -l)"' \; 2>/dev/null | sort -t: -k2 -nr | head
```

#### I/O Performance Issues

```bash
# Monitor I/O usage
iotop
iostat -x 1 5
pidstat -d 1 5

# Check disk performance
hdparm -tT /dev/sda
dd if=/dev/zero of=/tmp/test bs=1M count=1024; rm /tmp/test

# Find processes using disk heavily
lsof | grep REG | awk '{print $2}' | sort | uniq -c | sort -nr | head
```

## Network Issues

### Connectivity Problems

#### Basic Network Diagnostics

```bash
# Check network interfaces
ip addr show
ifconfig -a

# Test connectivity
ping -c 4 google.com
ping -c 4 8.8.8.8

# Check routing
ip route show
traceroute google.com
mtr google.com

# DNS resolution
nslookup google.com
dig google.com
cat /etc/resolv.conf
```

#### Network Configuration Issues

```bash
# Restart networking
sudo systemctl restart networking
sudo systemctl restart NetworkManager

# Reset network configuration
sudo netplan apply

# Check network manager status
systemctl status NetworkManager
nmcli device status
nmcli connection show
```

### DNS Problems

```bash
# Test DNS resolution
nslookup google.com 8.8.8.8
dig @8.8.8.8 google.com

# Flush DNS cache
sudo systemd-resolve --flush-caches
sudo systemctl restart systemd-resolved

# Check DNS configuration
systemd-resolve --status
cat /etc/systemd/resolved.conf

# Alternative DNS configuration
sudo nano /etc/resolv.conf
# Add: nameserver 8.8.8.8
```

## Application Issues

### Service Management Problems

#### Service Won't Start

```bash
# Check service status
systemctl status service_name

# Check service logs
journalctl -u service_name
journalctl -u service_name --since "1 hour ago"
journalctl -u service_name -f

# Check service configuration
systemctl cat service_name

# Reload service configuration
sudo systemctl daemon-reload
sudo systemctl restart service_name

# Check dependencies
systemctl list-dependencies service_name
```

#### Application Crashes

```bash
# Check application logs
journalctl -u application
tail -f /var/log/application.log

# Check for core dumps
ls -la /var/crash/
coredumpctl list
coredumpctl info PID

# Debug with strace
strace -f -o trace.log application

# Check library dependencies
ldd /usr/bin/application
```

### Package Management Issues

#### Broken Package Dependencies

```bash
# Fix broken packages
sudo apt --fix-broken install
sudo dpkg --configure -a

# Clean package cache
sudo apt clean
sudo apt autoclean
sudo apt autoremove

# Reset package database
sudo rm /var/lib/apt/lists/*
sudo apt update

# Force package installation
sudo dpkg -i --force-depends package.deb
sudo apt install -f
```

#### Repository Issues

```bash
# Check repository configuration
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/

# Update repository keys
sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
wget -qO - https://repo-url/key.gpg | sudo apt-key add -

# Remove problematic repository
sudo add-apt-repository --remove ppa:repository-name
sudo rm /etc/apt/sources.list.d/repository.list
```

## File System Issues

### File System Corruption

#### Check and Repair File Systems

```bash
# Check file system (unmounted)
sudo fsck /dev/sda1
sudo fsck.ext4 /dev/sda1

# Force check on next boot
sudo touch /forcefsck

# Check file system in read-only mode
sudo fsck -n /dev/sda1

# Mount file system in read-only mode
sudo mount -o ro /dev/sda1 /mnt

# Check for bad blocks
sudo badblocks -v /dev/sda1
```

#### File Permission Issues

```bash
# Fix common permission issues
sudo chmod 755 /usr/bin/sudo
sudo chmod 4755 /usr/bin/sudo  # Restore SUID bit

# Reset home directory permissions
sudo chown -R username:username /home/username
sudo chmod 755 /home/username

# Fix system directory permissions
sudo chmod 755 /var/log
sudo chmod 644 /etc/passwd
sudo chmod 640 /etc/shadow
```

### Mount Issues

```bash
# Check mounted file systems
mount
df -h
cat /proc/mounts

# Unmount busy file system
sudo fuser -m /mount/point
sudo lsof +D /mount/point
sudo umount -l /mount/point  # Lazy unmount

# Remount file system
sudo mount -o remount,rw /
sudo mount -o remount /mount/point

# Check fstab syntax
sudo mount -a
```

## User and Permission Issues

### Login Problems

#### Can't Login

```bash
# Boot to recovery mode
# Select root shell option

# Check user account
passwd -S username
chage -l username

# Unlock account
passwd -u username
usermod -U username

# Reset password
passwd username

# Check home directory permissions
ls -ld /home/username
chown username:username /home/username
chmod 755 /home/username
```

#### SSH Access Issues

```bash
# Check SSH service
systemctl status sshd
sudo systemctl restart sshd

# Check SSH configuration
sudo sshd -t
cat /etc/ssh/sshd_config

# Check SSH logs
journalctl -u sshd
grep ssh /var/log/auth.log

# Test SSH key authentication
ssh -i ~/.ssh/keyfile -v user@server
```

### Sudo Problems

```bash
# Fix sudo configuration
# Boot to recovery mode or use root account

# Check sudoers file syntax
sudo visudo -c

# Reset sudoers file
sudo cp /etc/sudoers.bak /etc/sudoers

# Add user to sudo group
usermod -aG sudo username

# Check sudo permissions
sudo -l -U username
```

## Hardware Issues

### Driver Problems

#### Graphics Driver Issues

```bash
# Boot with nomodeset parameter
# Edit GRUB: add nomodeset to kernel parameters

# Check current graphics driver
lspci | grep VGA
nvidia-smi  # For NVIDIA cards
lsmod | grep nouveau
lsmod | grep nvidia

# Install proprietary drivers
sudo ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo apt install nvidia-driver-XXX

# Remove and reinstall drivers
sudo apt purge nvidia-*
sudo apt autoremove
sudo apt install nvidia-driver-XXX
```

#### Audio Issues

```bash
# Check audio devices
aplay -l
lsof /dev/snd/*

# Restart audio services
pulseaudio --kill
pulseaudio --start
sudo systemctl restart alsa-utils

# Check audio configuration
alsamixer
pavucontrol

# Reset audio configuration
rm -rf ~/.config/pulse
pulseaudio --kill
```

### Storage Device Issues

```bash
# Check disk health
sudo smartctl -a /dev/sda
sudo badblocks -v /dev/sda

# Check disk connections
dmesg | grep -i sata
dmesg | grep -i usb

# Monitor disk temperature
sudo hddtemp /dev/sda
sensors
```

## System Recovery

### Recovery Mode Operations

```bash
# Boot to recovery mode
# Select "Drop to root shell prompt"

# Remount root as read-write
mount -o remount,rw /

# Enable networking
dhclient eth0

# Update package database
apt update

# Fix broken packages
dpkg --configure -a
apt --fix-broken install

# Create emergency user
adduser emergency
usermod -aG sudo emergency
```

### Live USB Recovery

```bash
# Boot from Ubuntu live USB
# Choose "Try Ubuntu"

# Mount the installed system
sudo mkdir /mnt/ubuntu
sudo mount /dev/sda1 /mnt/ubuntu
sudo mount /dev/sda2 /mnt/ubuntu/home  # If separate home partition

# Backup important data
sudo cp -r /mnt/ubuntu/home/username /media/backup/

# Chroot for system repair
sudo mount --bind /dev /mnt/ubuntu/dev
sudo mount --bind /proc /mnt/ubuntu/proc
sudo mount --bind /sys /mnt/ubuntu/sys
sudo chroot /mnt/ubuntu

# Perform repairs inside chroot
apt update
apt --fix-broken install
update-grub

# Exit and cleanup
exit
sudo umount /mnt/ubuntu/dev
sudo umount /mnt/ubuntu/proc
sudo umount /mnt/ubuntu/sys
sudo umount /mnt/ubuntu/home
sudo umount /mnt/ubuntu
```

This comprehensive troubleshooting guide covers the most common issues encountered on Ubuntu systems and provides systematic approaches to diagnose and resolve them.
