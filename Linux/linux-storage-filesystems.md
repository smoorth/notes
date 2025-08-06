# Linux Storage and File Systems Guide

## File System Types and Overview

### Common File System Types

#### ext4 (Fourth Extended Filesystem)
- Default file system for most Linux distributions
- Supports files up to 16TB and volumes up to 1EB
- Journaling support for data integrity
- Backward compatible with ext2 and ext3

#### XFS
- High-performance 64-bit journaling file system
- Excellent for large files and high I/O workloads
- Supports online defragmentation
- Maximum file size: 8EB

#### Btrfs (B-tree File System)
- Copy-on-write file system with advanced features
- Built-in RAID, snapshots, and compression
- Self-healing capabilities
- Still considered experimental for some use cases

#### ZFS
- Advanced file system with volume management
- Built-in RAID, snapshots, deduplication
- Strong data integrity guarantees
- Not included in kernel by default

### File System Information

```bash
# Display file system information
df -h                    # Disk space usage
df -i                    # Inode usage
lsblk                    # Block device tree
blkid                    # UUID and file system type
findmnt                  # Mounted file systems tree

# Detailed file system info
tune2fs -l /dev/sda1     # ext2/3/4 information
xfs_info /mount/point    # XFS information
btrfs filesystem show   # Btrfs information

# File system statistics
dumpe2fs -h /dev/sda1   # ext2/3/4 statistics
```

## Disk Partitioning

### MBR vs GPT Partitioning

#### MBR (Master Boot Record)
- Maximum disk size: 2TB
- Maximum 4 primary partitions
- Uses fdisk for management

#### GPT (GUID Partition Table)
- Supports disks larger than 2TB
- Up to 128 partitions
- More robust with backup partition table
- Uses gdisk or parted for management

### Partitioning Tools

#### Using fdisk (MBR)

```bash
# List all disks
sudo fdisk -l

# Partition a disk
sudo fdisk /dev/sdb

# fdisk commands:
# n - Create new partition
# d - Delete partition
# p - Print partition table
# w - Write changes and exit
# q - Quit without saving

# Example partitioning session:
sudo fdisk /dev/sdb
# n (new partition)
# p (primary)
# 1 (partition number)
# [Enter] (first sector - default)
# +10G (size - 10GB)
# w (write and exit)
```

#### Using parted (GPT)

```bash
# Create GPT partition table
sudo parted /dev/sdb mklabel gpt

# Create partition
sudo parted /dev/sdb mkpart primary ext4 0% 50%
sudo parted /dev/sdb mkpart primary ext4 50% 100%

# Interactive mode
sudo parted /dev/sdb
# (parted) print
# (parted) mkpart primary ext4 0% 100%
# (parted) quit

# Align partitions for performance
sudo parted -a optimal /dev/sdb mkpart primary ext4 0% 100%
```

#### Using gdisk (GPT)

```bash
# Partition with gdisk
sudo gdisk /dev/sdb

# gdisk commands:
# n - New partition
# d - Delete partition
# p - Print partition table
# w - Write and exit
# q - Quit without saving
```

## File System Creation and Management

### Creating File Systems

```bash
# Create ext4 file system
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.ext4 -L "MyData" /dev/sdb1  # With label

# Create XFS file system
sudo mkfs.xfs /dev/sdb1
sudo mkfs.xfs -L "MyData" /dev/sdb1

# Create Btrfs file system
sudo mkfs.btrfs /dev/sdb1
sudo mkfs.btrfs -L "MyData" /dev/sdb1

# Create file system with specific options
sudo mkfs.ext4 -b 4096 -i 8192 /dev/sdb1  # Block size and inode ratio
sudo mkfs.xfs -b size=4096 -s size=512 /dev/sdb1  # Block and sector size
```

### File System Labels and UUIDs

```bash
# Set file system label
sudo e2label /dev/sdb1 "MyLabel"      # ext2/3/4
sudo xfs_admin -L "MyLabel" /dev/sdb1  # XFS
sudo btrfs filesystem label /dev/sdb1 "MyLabel"  # Btrfs

# View labels and UUIDs
blkid
lsblk -f
sudo tune2fs -l /dev/sdb1 | grep UUID

# Generate new UUID
sudo tune2fs -U random /dev/sdb1      # ext2/3/4
sudo xfs_admin -U generate /dev/sdb1  # XFS
```

## Mounting File Systems

### Basic Mounting

```bash
# Create mount point
sudo mkdir /mnt/mydata

# Mount file system
sudo mount /dev/sdb1 /mnt/mydata
sudo mount -t ext4 /dev/sdb1 /mnt/mydata

# Mount with options
sudo mount -o rw,noexec,nosuid /dev/sdb1 /mnt/mydata

# Mount by UUID or label
sudo mount UUID="12345678-1234-1234-1234-123456789012" /mnt/mydata
sudo mount LABEL="MyData" /mnt/mydata

# Unmount
sudo umount /mnt/mydata
sudo umount /dev/sdb1
```

### Mount Options

#### Common Mount Options

```bash
# Performance options
noatime          # Don't update access times
nodiratime       # Don't update directory access times
relatime         # Update access times relatively

# Security options
noexec          # Don't allow execution
nosuid          # Ignore SUID bits
nodev           # Don't interpret device files

# File system specific options
# ext4:
data=ordered    # Default journaling mode
data=writeback  # Faster but less safe
barrier=1       # Write barriers enabled

# XFS:
logbufs=8       # Number of in-memory log buffers
logbsize=256k   # Size of each log buffer

# Example with multiple options
sudo mount -o noatime,noexec,nosuid,relatime /dev/sdb1 /mnt/mydata
```

### Persistent Mounting with fstab

```bash
# Edit fstab
sudo nano /etc/fstab

# fstab format:
# <device> <mount_point> <fs_type> <options> <dump> <pass>

# Examples:
UUID=12345678-1234-1234-1234-123456789012 /mnt/mydata ext4 defaults,noatime 0 2
LABEL=MyData /mnt/mydata ext4 defaults,noatime 0 2
/dev/sdb1 /mnt/mydata ext4 defaults,noatime 0 2

# Test fstab entries
sudo mount -a

# Mount single fstab entry
sudo mount /mnt/mydata
```

## LVM (Logical Volume Management)

### LVM Concepts

- **Physical Volume (PV)**: Physical disk or partition
- **Volume Group (VG)**: Collection of physical volumes
- **Logical Volume (LV)**: Virtual partition within volume group

### LVM Setup

```bash
# Install LVM tools
sudo apt install lvm2

# Create physical volume
sudo pvcreate /dev/sdb1 /dev/sdc1

# Create volume group
sudo vgcreate myvg /dev/sdb1 /dev/sdc1

# Create logical volume
sudo lvcreate -L 10G -n mylv myvg
sudo lvcreate -l 100%FREE -n mylv myvg  # Use all available space

# Create file system on logical volume
sudo mkfs.ext4 /dev/myvg/mylv

# Mount logical volume
sudo mkdir /mnt/lvm
sudo mount /dev/myvg/mylv /mnt/lvm
```

### LVM Management

```bash
# Display information
pvdisplay          # Physical volumes
vgdisplay          # Volume groups
lvdisplay          # Logical volumes
pvs                # Physical volumes summary
vgs                # Volume groups summary
lvs                # Logical volumes summary

# Extend logical volume
sudo lvextend -L +5G /dev/myvg/mylv     # Add 5GB
sudo lvextend -l +100%FREE /dev/myvg/mylv  # Use all free space

# Resize file system after extending LV
sudo resize2fs /dev/myvg/mylv           # ext2/3/4
sudo xfs_growfs /mnt/lvm                # XFS

# Add physical volume to volume group
sudo pvcreate /dev/sdd1
sudo vgextend myvg /dev/sdd1

# Remove logical volume
sudo umount /mnt/lvm
sudo lvremove /dev/myvg/mylv

# Remove volume group and physical volume
sudo vgremove myvg
sudo pvremove /dev/sdb1
```

## RAID Configuration

### Software RAID with mdadm

```bash
# Install mdadm
sudo apt install mdadm

# Create RAID array
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1  # RAID 1
sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb1 /dev/sdc1  # RAID 0
sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1  # RAID 5

# Monitor RAID creation
cat /proc/mdstat
sudo mdadm --detail /dev/md0

# Create file system on RAID
sudo mkfs.ext4 /dev/md0

# Mount RAID array
sudo mkdir /mnt/raid
sudo mount /dev/md0 /mnt/raid

# Save RAID configuration
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

### RAID Management

```bash
# Check RAID status
cat /proc/mdstat
sudo mdadm --detail /dev/md0

# Add spare disk
sudo mdadm --add /dev/md0 /dev/sde1

# Remove failed disk
sudo mdadm --fail /dev/md0 /dev/sdb1
sudo mdadm --remove /dev/md0 /dev/sdb1

# Stop RAID array
sudo umount /mnt/raid
sudo mdadm --stop /dev/md0

# Start RAID array
sudo mdadm --assemble /dev/md0 /dev/sdb1 /dev/sdc1

# Delete RAID array
sudo mdadm --stop /dev/md0
sudo mdadm --zero-superblock /dev/sdb1 /dev/sdc1
```

## File System Maintenance

### File System Checking and Repair

```bash
# Check file system (unmounted)
sudo fsck /dev/sdb1
sudo fsck.ext4 /dev/sdb1
sudo fsck.xfs /dev/sdb1

# Force check
sudo fsck -f /dev/sdb1

# Check without making changes
sudo fsck -n /dev/sdb1

# Automatic repair
sudo fsck -y /dev/sdb1

# Check for bad blocks
sudo fsck -c /dev/sdb1

# Schedule check on next boot
sudo tune2fs -c 1 /dev/sdb1  # ext2/3/4
sudo touch /forcefsck        # All file systems
```

### File System Tuning

```bash
# ext2/3/4 tuning
sudo tune2fs -l /dev/sdb1                    # Display settings
sudo tune2fs -c 30 /dev/sdb1                 # Check every 30 mounts
sudo tune2fs -i 30d /dev/sdb1                # Check every 30 days
sudo tune2fs -m 1 /dev/sdb1                  # Reserve 1% for root
sudo tune2fs -o journal_data_writeback /dev/sdb1  # Change journal mode

# XFS tuning
sudo xfs_admin -l /dev/sdb1                  # Display label
sudo xfs_admin -u /dev/sdb1                  # Display UUID

# Defragmentation
sudo e4defrag /mnt/mydata                    # ext4
sudo xfs_fsr /mnt/mydata                     # XFS
```

## Storage Monitoring and Performance

### Disk Usage Analysis

```bash
# Disk space usage
df -h
df -i                    # Inode usage
du -sh /path/to/dir     # Directory size
du -sh /* | sort -hr    # Sort by size

# Find large files
find / -type f -size +100M 2>/dev/null
find /var -type f -size +50M 2>/dev/null

# Find large directories
du -h / | sort -hr | head -20

# Disk usage by file type
find /home -name "*.log" -exec du -ch {} + | grep total
```

### I/O Performance Monitoring

```bash
# Real-time I/O monitoring
iotop
iostat -x 1 5
pidstat -d 1 5

# Disk performance testing
sudo hdparm -tT /dev/sda
dd if=/dev/zero of=/tmp/test bs=1M count=1024; rm /tmp/test

# Monitor disk activity
sudo iotop -d 1
watch -n 1 'cat /proc/diskstats'
```

### S.M.A.R.T. Monitoring

```bash
# Install smartmontools
sudo apt install smartmontools

# Check if S.M.A.R.T. is enabled
sudo smartctl -i /dev/sda

# Enable S.M.A.R.T.
sudo smartctl -s on /dev/sda

# Run short self-test
sudo smartctl -t short /dev/sda

# Run long self-test
sudo smartctl -t long /dev/sda

# View test results
sudo smartctl -l selftest /dev/sda

# View all S.M.A.R.T. data
sudo smartctl -a /dev/sda

# Monitor disk health
sudo smartctl -H /dev/sda
```

## Network File Systems

### NFS (Network File System)

#### NFS Server Setup

```bash
# Install NFS server
sudo apt install nfs-kernel-server

# Configure exports
sudo nano /etc/exports

# Example exports:
/home/shared    192.168.1.0/24(rw,sync,no_subtree_check)
/var/backups    192.168.1.100(ro,sync,no_subtree_check)

# Apply configuration
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server

# Check exports
sudo exportfs -v
showmount -e localhost
```

#### NFS Client Setup

```bash
# Install NFS client
sudo apt install nfs-common

# Create mount point
sudo mkdir /mnt/nfs

# Mount NFS share
sudo mount -t nfs server:/home/shared /mnt/nfs

# Permanent mount in fstab
echo "server:/home/shared /mnt/nfs nfs defaults 0 0" | sudo tee -a /etc/fstab

# Check mounted NFS shares
mount | grep nfs
df -h -t nfs
```

### CIFS/SMB

```bash
# Install CIFS utilities
sudo apt install cifs-utils

# Create mount point
sudo mkdir /mnt/smb

# Mount SMB share
sudo mount -t cifs //server/share /mnt/smb -o username=user,password=pass

# Mount with credentials file
echo "username=user" > ~/.smbcredentials
echo "password=pass" >> ~/.smbcredentials
chmod 600 ~/.smbcredentials

sudo mount -t cifs //server/share /mnt/smb -o credentials=~/.smbcredentials

# Permanent mount in fstab
echo "//server/share /mnt/smb cifs credentials=/home/user/.smbcredentials,uid=1000,gid=1000 0 0" | sudo tee -a /etc/fstab
```

This comprehensive guide covers Linux storage management from basic file systems to advanced configurations like LVM and RAID, providing the knowledge needed to effectively manage storage on Ubuntu systems.
