# Linux Networking Essentials

## Network Interface Configuration

### Understanding Network Interfaces

```bash
# List all network interfaces
ip link show
ifconfig -a

# Show interface statistics
ip -s link show
cat /proc/net/dev

# Show interface details
ip addr show
ip addr show eth0
```

### Network Configuration with Netplan (Ubuntu 18.04+)

#### Basic Static IP Configuration

```bash
# Edit netplan configuration
sudo nano /etc/netplan/01-netcfg.yaml
```

Example static IP configuration:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4, 1.1.1.1]
        search: [local.domain]
```

#### DHCP Configuration

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
      dhcp6: false
```

#### Multiple Interface Configuration

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses:
        - 10.0.0.100/24
      routes:
        - to: 10.0.0.0/24
          via: 10.0.0.1
```

#### WiFi Configuration

```yaml
network:
  version: 2
  renderer: networkd
  wifis:
    wlp2s0:
      access-points:
        "MyWiFiNetwork":
          password: "mypassword"
      dhcp4: true
```

### Applying Network Configuration

```bash
# Test configuration
sudo netplan try

# Apply configuration
sudo netplan apply

# Generate backend configuration
sudo netplan generate

# Debug configuration
sudo netplan --debug apply
```

## Network Troubleshooting

### Connectivity Testing

```bash
# Basic connectivity
ping google.com
ping -c 4 8.8.8.8
ping6 google.com

# Test with different packet sizes
ping -s 1400 google.com
ping -s 1500 google.com  # May fragment

# Continuous ping with timestamp
ping google.com | while read pong; do echo "$(date): $pong"; done
```

### Route Analysis

```bash
# View routing table
ip route show
route -n

# Trace route to destination
traceroute google.com
tracepath google.com
mtr google.com  # Real-time traceroute

# Add/remove routes
sudo ip route add 192.168.2.0/24 via 192.168.1.1
sudo ip route del 192.168.2.0/24

# Default gateway
ip route show default
sudo ip route add default via 192.168.1.1
```

### DNS Resolution

```bash
# DNS lookup
nslookup google.com
dig google.com
host google.com

# Reverse DNS lookup
dig -x 8.8.8.8
nslookup 8.8.8.8

# DNS trace
dig +trace google.com

# Test specific DNS server
dig @8.8.8.8 google.com
nslookup google.com 1.1.1.1

# Check DNS configuration
cat /etc/resolv.conf
systemd-resolve --status
```

### Port and Service Testing

```bash
# Check if port is open
telnet google.com 80
nc -zv google.com 80
nmap -p 80 google.com

# Scan multiple ports
nmap -p 80,443,22 target.com
nmap -p 1-1000 target.com

# Check listening ports
netstat -tuln
ss -tuln
lsof -i

# Check specific port
netstat -tuln | grep :80
ss -tuln sport = :80
```

## Network Security

### Firewall Configuration with UFW

#### Basic UFW Operations

```bash
# Enable/disable firewall
sudo ufw enable
sudo ufw disable

# Check status
sudo ufw status
sudo ufw status verbose
sudo ufw status numbered
```

#### Allow/Deny Rules

```bash
# Allow by port
sudo ufw allow 22
sudo ufw allow 80/tcp
sudo ufw allow 53/udp

# Allow by service name
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Allow from specific IP
sudo ufw allow from 192.168.1.100
sudo ufw allow from 192.168.1.0/24

# Allow to specific interface
sudo ufw allow in on eth0 to any port 22
```

#### Advanced UFW Rules

```bash
# Rate limiting
sudo ufw limit ssh
sudo ufw limit 22/tcp

# Application profiles
sudo ufw app list
sudo ufw allow "Apache Full"
sudo ufw allow "OpenSSH"

# Deny rules
sudo ufw deny 23
sudo ufw deny from 192.168.1.50

# Delete rules
sudo ufw delete allow 80
sudo ufw delete 3  # Delete rule number 3
```

### Advanced Firewall with iptables

#### Basic iptables Commands

```bash
# View current rules
sudo iptables -L
sudo iptables -L -n  # Numeric output
sudo iptables -L -v  # Verbose

# Save/restore rules
sudo iptables-save > /tmp/iptables.rules
sudo iptables-restore < /tmp/iptables.rules

# Install iptables-persistent for Ubuntu
sudo apt install iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload
```

#### Basic iptables Rules

```bash
# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Drop all other input
sudo iptables -A INPUT -j DROP

# Flush all rules
sudo iptables -F
```

## Network Services

### SSH Configuration and Security

#### SSH Server Configuration

```bash
# Edit SSH daemon configuration
sudo nano /etc/ssh/sshd_config
```

Security hardening options:

```
# Change default port
Port 2222

# Disable root login
PermitRootLogin no

# Use key authentication only
PasswordAuthentication no
PubkeyAuthentication yes

# Limit users
AllowUsers username
DenyUsers baduser

# Other security settings
Protocol 2
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
```

#### SSH Key Management

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/mykey
ssh-keygen -t ed25519 -f ~/.ssh/mykey_ed25519

# Copy public key to server
ssh-copy-id user@server
ssh-copy-id -i ~/.ssh/mykey.pub user@server

# SSH with specific key
ssh -i ~/.ssh/mykey user@server

# SSH agent for key management
eval $(ssh-agent)
ssh-add ~/.ssh/mykey
ssh-add -l  # List loaded keys
```

#### SSH Tunneling

```bash
# Local port forwarding
ssh -L 8080:localhost:80 user@server

# Remote port forwarding
ssh -R 8080:localhost:80 user@server

# Dynamic port forwarding (SOCKS proxy)
ssh -D 1080 user@server

# Keep tunnel alive
ssh -L 8080:localhost:80 -N -f user@server
```

### Web Services

#### Apache Configuration

```bash
# Install Apache
sudo apt install apache2

# Start/stop/restart Apache
sudo systemctl start apache2
sudo systemctl stop apache2
sudo systemctl restart apache2
sudo systemctl reload apache2

# Enable/disable sites
sudo a2ensite default-ssl
sudo a2dissite 000-default

# Enable/disable modules
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2dismod autoindex
```

#### Nginx Configuration

```bash
# Install Nginx
sudo apt install nginx

# Control Nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx

# Test configuration
sudo nginx -t

# Basic site configuration
sudo nano /etc/nginx/sites-available/mysite
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
```

## Network Monitoring and Performance

### Bandwidth Monitoring

```bash
# Install monitoring tools
sudo apt install iftop nethogs nload bmon

# Monitor interface bandwidth
iftop -i eth0
nload eth0
bmon

# Monitor per-process network usage
sudo nethogs

# Command-line bandwidth test
wget -O /dev/null http://speedtest.tele2.net/1GB.zip
curl -o /dev/null http://speedtest.tele2.net/100MB.zip
```

### Network Analysis with tcpdump

```bash
# Capture packets on interface
sudo tcpdump -i eth0

# Capture specific traffic
sudo tcpdump -i eth0 host google.com
sudo tcpdump -i eth0 port 80
sudo tcpdump -i eth0 tcp port 22

# Save to file
sudo tcpdump -i eth0 -w capture.pcap
sudo tcpdump -r capture.pcap

# Verbose output
sudo tcpdump -i eth0 -v
sudo tcpdump -i eth0 -vv
sudo tcpdump -i eth0 -A  # ASCII output
```

### Network Statistics

```bash
# Interface statistics
cat /proc/net/dev
ip -s link show

# Connection statistics
ss -s
netstat -s

# ARP table
ip neigh show
arp -a

# Network sockets
ss -tuln  # TCP and UDP listening
ss -tap   # All TCP with process info
lsof -i   # Open network files
```

## Advanced Networking

### VLAN Configuration

```bash
# Install VLAN tools
sudo apt install vlan

# Load 8021q module
sudo modprobe 8021q

# Create VLAN interface
sudo ip link add link eth0 name eth0.100 type vlan id 100
sudo ip addr add 192.168.100.1/24 dev eth0.100
sudo ip link set eth0.100 up

# Netplan VLAN configuration
```

Example netplan VLAN:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
  vlans:
    vlan100:
      id: 100
      link: eth0
      addresses: [192.168.100.1/24]
```

### Network Bonding

```bash
# Install bonding tools
sudo apt install ifenslave

# Load bonding module
sudo modprobe bonding

# Netplan bonding configuration
```

Example netplan bonding:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
    eth1:
      dhcp4: false
  bonds:
    bond0:
      interfaces: [eth0, eth1]
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      parameters:
        mode: active-backup
        primary: eth0
```

### Network Namespaces

```bash
# Create network namespace
sudo ip netns add testns

# List namespaces
ip netns list

# Execute command in namespace
sudo ip netns exec testns bash

# Add interface to namespace
sudo ip link set eth1 netns testns

# Configure interface in namespace
sudo ip netns exec testns ip addr add 10.0.0.1/24 dev eth1
sudo ip netns exec testns ip link set eth1 up

# Delete namespace
sudo ip netns del testns
```

This comprehensive networking guide covers essential concepts and practical commands for managing network configuration, troubleshooting connectivity issues, and implementing network security measures on Ubuntu systems.
