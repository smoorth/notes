# Linux Performance Tuning and Optimization

## System Performance Analysis

### Performance Monitoring Tools

#### CPU Monitoring

```bash
# Real-time CPU usage
top
htop
atop

# CPU information and statistics
lscpu
cat /proc/cpuinfo
cat /proc/stat
cat /proc/loadavg

# Per-process CPU usage
ps aux --sort=-pcpu | head -10
pidstat -u 1 5  # CPU stats every second for 5 intervals

# CPU utilization by core
mpstat -P ALL 1 5
sar -u 1 5

# CPU context switches and interrupts
vmstat 1 5
cat /proc/interrupts
```

#### Memory Monitoring

```bash
# Memory usage overview
free -h
cat /proc/meminfo

# Memory usage by process
ps aux --sort=-pmem | head -10
pmap -x PID  # Memory map for specific process

# Memory statistics over time
vmstat -s
sar -r 1 5

# Memory fragmentation
cat /proc/buddyinfo

# Swap usage
swapon --show
cat /proc/swaps
```

#### Disk I/O Monitoring

```bash
# Disk usage and statistics
df -h
du -sh /path/to/directory

# Real-time I/O monitoring
iotop
iostat -x 1 5

# Per-process I/O
pidstat -d 1 5

# Disk performance
hdparm -tT /dev/sda
dd if=/dev/zero of=/tmp/test bs=1M count=1024

# Block device statistics
cat /proc/diskstats
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
```

#### Network Monitoring

```bash
# Network interface statistics
ip -s link
cat /proc/net/dev

# Network connections
netstat -tuln
ss -tuln
lsof -i

# Network bandwidth monitoring
iftop
nethogs
nload

# Network performance testing
ping -c 10 google.com
wget --progress=dot:mega -O /dev/null http://speedtest.com/file.zip
```

### System Load Analysis

#### Understanding Load Average

```bash
# Check load average
uptime
cat /proc/loadavg

# Monitor load over time
sar -q 1 5

# Identify high-load processes
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
```

#### CPU Performance Tuning

```bash
# Check CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Set performance governor
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Check CPU frequency
cat /proc/cpuinfo | grep MHz
cpupower frequency-info

# Disable CPU power saving (if needed)
sudo systemctl disable ondemand
```

## Memory Optimization

### Memory Management

#### Virtual Memory Configuration

```bash
# View current vm settings
sysctl vm.swappiness
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio

# Optimize for servers (less swapping)
sudo sysctl vm.swappiness=10
sudo sysctl vm.dirty_ratio=15
sudo sysctl vm.dirty_background_ratio=5

# Make changes permanent
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_ratio=15' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.conf
```

#### Memory Cleanup

```bash
# Clear page cache
sudo sync
echo 1 | sudo tee /proc/sys/vm/drop_caches

# Clear dentries and inodes
echo 2 | sudo tee /proc/sys/vm/drop_caches

# Clear all caches
echo 3 | sudo tee /proc/sys/vm/drop_caches

# Monitor memory before and after
free -h
```

#### Huge Pages Configuration

```bash
# Check huge pages status
cat /proc/meminfo | grep Huge

# Configure huge pages
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# For databases and high-memory applications
echo 'vm.nr_hugepages=1024' | sudo tee -a /etc/sysctl.conf
```

### Memory Leak Detection

```bash
# Monitor memory growth over time
while true; do
    ps -eo pid,cmd,%mem --sort=-%mem | head -10
    sleep 60
done

# Use valgrind for detailed analysis
sudo apt install valgrind
valgrind --tool=memcheck --leak-check=full ./your_program

# Monitor with smem (proportional memory usage)
sudo apt install smem
smem -t -k
```

## Disk I/O Optimization

### File System Tuning

#### ext4 Optimization

```bash
# Mount options for performance
sudo mount -o remount,noatime,nodiratime /

# Edit fstab for permanent changes
sudo nano /etc/fstab
# Add noatime,nodiratime to options
# /dev/sda1 / ext4 defaults,noatime,nodiratime 0 1

# Tune ext4 parameters
sudo tune2fs -o journal_data_writeback /dev/sda1
sudo tune2fs -O ^has_journal /dev/sda1  # Remove journal (risky)
```

#### XFS Optimization

```bash
# Mount XFS with performance options
sudo mount -o noatime,nodiratime,logbufs=8,logbsize=256k /dev/sdb1 /mnt

# XFS defragmentation
sudo xfs_fsr /mnt
```

### I/O Scheduler Optimization

```bash
# Check current I/O scheduler
cat /sys/block/sda/queue/scheduler

# Change I/O scheduler
echo deadline | sudo tee /sys/block/sda/queue/scheduler
echo noop | sudo tee /sys/block/sda/queue/scheduler      # For SSDs
echo cfq | sudo tee /sys/block/sda/queue/scheduler       # Default

# Make permanent via GRUB
sudo nano /etc/default/grub
# Add: GRUB_CMDLINE_LINUX_DEFAULT="elevator=deadline"
sudo update-grub
```

### SSD Optimization

```bash
# Enable TRIM support
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# Manual TRIM
sudo fstrim -v /

# Check if TRIM is supported
sudo hdparm -I /dev/sda | grep TRIM

# SSD-specific mount options in /etc/fstab
# /dev/sda1 / ext4 defaults,noatime,discard 0 1
```

## Network Performance Tuning

### TCP/IP Stack Optimization

```bash
# View current network settings
sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.ipv4.tcp_congestion_control

# Optimize for high-bandwidth networks
sudo sysctl net.core.rmem_max=16777216
sudo sysctl net.core.wmem_max=16777216
sudo sysctl net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl net.ipv4.tcp_wmem="4096 65536 16777216"

# TCP congestion control
sudo sysctl net.ipv4.tcp_congestion_control=bbr

# Make changes permanent
echo 'net.core.rmem_max=16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.core.wmem_max=16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
```

### Network Interface Optimization

```bash
# Check network interface settings
ethtool eth0

# Optimize ring buffers
sudo ethtool -G eth0 rx 4096 tx 4096

# Enable/disable features
sudo ethtool -K eth0 gso on
sudo ethtool -K eth0 tso on
sudo ethtool -K eth0 gro on

# Set interrupt coalescing
sudo ethtool -C eth0 rx-usecs 50 tx-usecs 50
```

## Application-Specific Optimizations

### Database Performance

#### MySQL/MariaDB Tuning

```bash
# Key MySQL configuration variables
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Example MySQL optimizations:

```ini
[mysqld]
# Memory settings
innodb_buffer_pool_size = 2G
key_buffer_size = 256M
max_connections = 500

# I/O settings
innodb_flush_log_at_trx_commit = 2
innodb_log_file_size = 256M
innodb_log_buffer_size = 16M

# Query cache
query_cache_size = 256M
query_cache_type = 1
```

#### PostgreSQL Tuning

```bash
# Edit PostgreSQL configuration
sudo nano /etc/postgresql/14/main/postgresql.conf
```

Example PostgreSQL optimizations:

```ini
# Memory settings
shared_buffers = 2GB
effective_cache_size = 6GB
work_mem = 256MB
maintenance_work_mem = 1GB

# Checkpoint settings
checkpoint_segments = 64
checkpoint_completion_target = 0.9
wal_buffers = 16MB
```

### Web Server Performance

#### Apache Optimization

```bash
# Enable useful modules
sudo a2enmod expires
sudo a2enmod deflate
sudo a2enmod headers

# Configure in /etc/apache2/apache2.conf
```

Example Apache configuration:

```apache
# Worker MPM configuration
<IfModule mpm_worker_module>
    StartServers          2
    MinSpareThreads      25
    MaxSpareThreads      75
    ThreadLimit          64
    ThreadsPerChild      25
    MaxRequestWorkers   400
    MaxConnectionsPerChild 1000
</IfModule>

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/javascript
</IfModule>
```

#### Nginx Optimization

```bash
# Edit nginx configuration
sudo nano /etc/nginx/nginx.conf
```

Example Nginx optimizations:

```nginx
worker_processes auto;
worker_connections 1024;

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript;

    # Buffer sizes
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 2 1k;
}
```

## System Resource Limits

### Process Limits Configuration

```bash
# View current limits
ulimit -a

# Set limits for current session
ulimit -n 4096      # Open files
ulimit -u 2048      # Max processes
ulimit -c unlimited # Core dumps

# Permanent limits in /etc/security/limits.conf
echo '* soft nofile 4096' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 8192' | sudo tee -a /etc/security/limits.conf
echo '* soft nproc 2048' | sudo tee -a /etc/security/limits.conf
echo '* hard nproc 4096' | sudo tee -a /etc/security/limits.conf
```

### Systemd Service Limits

```bash
# Edit service file
sudo systemctl edit nginx

# Add limits
[Service]
LimitNOFILE=8192
LimitNPROC=4096
LimitMEMLOCK=infinity

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart nginx
```

## Performance Monitoring Scripts

### Comprehensive System Monitor

```bash
#!/bin/bash

# System Performance Monitor
LOG_FILE="/var/log/performance.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

log_performance() {
    echo "[$DATE] Performance Snapshot" >> $LOG_FILE

    # CPU Load
    echo "Load Average: $(cat /proc/loadavg)" >> $LOG_FILE

    # Memory Usage
    echo "Memory: $(free | grep Mem | awk '{printf "%.2f%%", $3/$2*100}')" >> $LOG_FILE

    # Disk Usage
    echo "Disk: $(df / | tail -1 | awk '{print $5}')" >> $LOG_FILE

    # Top CPU processes
    echo "Top CPU Processes:" >> $LOG_FILE
    ps aux --sort=-pcpu --no-headers | head -3 >> $LOG_FILE

    echo "---" >> $LOG_FILE
}

log_performance
```

This guide provides comprehensive approaches to analyzing and optimizing Linux system performance, covering CPU, memory, disk I/O, and network subsystems with practical examples for Ubuntu systems.
