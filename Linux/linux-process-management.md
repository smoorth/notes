# Linux Process Management and Job Control

## Understanding Processes

### Process Fundamentals

#### Process Information

```bash
# Display running processes
ps
ps aux
ps -ef
ps -aux --forest  # Tree view

# Process information details
ps -o pid,ppid,cmd,%mem,%cpu,stat,start,time

# Real-time process monitoring
top
htop
atop

# Process tree visualization
pstree
pstree -p  # Show PIDs
pstree username  # Processes for specific user
```

#### Process Identification

```bash
# Find process by name
ps aux | grep processname
pgrep processname
pgrep -f "full command line"

# Find process ID by name
pidof processname

# Find parent process
ps -p PID -o ppid=

# Process details in /proc
cat /proc/PID/cmdline
cat /proc/PID/status
cat /proc/PID/environ
```

### Process States and Status

#### Understanding Process States

```bash
# Process states in ps output:
# R - Running
# S - Sleeping (interruptible)
# D - Disk sleep (uninterruptible)
# Z - Zombie
# T - Stopped
# < - High priority
# N - Low priority
# L - Pages locked into memory
# s - Session leader
# + - Foreground process group

# Check specific process state
ps -o stat -p PID

# Find zombie processes
ps aux | grep " Z "
ps -eo pid,ppid,state,comm | grep " Z "
```

## Process Control

### Starting and Managing Processes

#### Foreground and Background Execution

```bash
# Run command in foreground
command

# Run command in background
command &

# Send current job to background
Ctrl+Z  # Suspend current job
bg      # Put suspended job in background

# Bring background job to foreground
fg
fg %1   # Bring job 1 to foreground

# List current jobs
jobs
jobs -l  # Include process IDs
```

#### Job Control Commands

```bash
# Suspend current process
Ctrl+Z

# Kill current process
Ctrl+C

# Send EOF to current process
Ctrl+D

# Job control examples
sleep 100 &         # Start background job
jobs                # List jobs
fg %1              # Bring job 1 to foreground
Ctrl+Z             # Suspend it
bg %1              # Resume in background
kill %1            # Kill job 1
```

### Process Termination

#### Kill Commands

```bash
# Terminate process by PID
kill PID
kill -TERM PID     # Graceful termination (default)
kill -KILL PID     # Force kill
kill -9 PID        # Force kill (same as -KILL)

# Terminate process by name
killall processname
pkill processname
pkill -f "command pattern"

# Kill all processes for user
pkill -u username
killall -u username

# Send different signals
kill -HUP PID      # Hang up
kill -USR1 PID     # User signal 1
kill -USR2 PID     # User signal 2
```

#### Signal Types

```bash
# List all available signals
kill -l

# Common signals:
# SIGTERM (15) - Graceful termination
# SIGKILL (9)  - Force kill
# SIGHUP (1)   - Hang up (often reload config)
# SIGINT (2)   - Interrupt (Ctrl+C)
# SIGSTOP (19) - Stop process
# SIGCONT (18) - Continue process
# SIGUSR1 (10) - User defined signal 1
# SIGUSR2 (12) - User defined signal 2

# Send specific signal
kill -SIGHUP PID
kill -1 PID        # Same as SIGHUP
```

## Advanced Process Management

### Process Priorities

#### Nice Values

```bash
# Check current nice value
ps -o pid,ni,cmd -p PID

# Start process with specific priority
nice -n 10 command           # Lower priority (+10)
nice -n -5 command           # Higher priority (-5)
nice --adjustment=10 command

# Change priority of running process
renice 10 PID               # Set nice to 10
renice -5 -p PID           # Set nice to -5
renice 5 -u username       # Set nice for all user processes
```

#### Real-time Priorities

```bash
# Set real-time priority (requires privileges)
chrt -f 50 command         # FIFO scheduling, priority 50
chrt -r 50 command         # Round-robin scheduling
chrt -o 0 command          # Other (normal) scheduling

# Check scheduling policy
chrt -p PID

# Available scheduling policies:
# SCHED_OTHER (0) - Normal
# SCHED_FIFO (1)  - Real-time FIFO
# SCHED_RR (2)    - Real-time round-robin
# SCHED_BATCH (3) - Batch processing
# SCHED_IDLE (5)  - Very low priority
```

### Process Monitoring and Analysis

#### Resource Usage Monitoring

```bash
# CPU usage by process
ps aux --sort=-pcpu | head -10

# Memory usage by process
ps aux --sort=-pmem | head -10

# Process resource usage over time
pidstat -p PID 1 5         # Stats every second for 5 times
pidstat -u -p PID          # CPU usage
pidstat -r -p PID          # Memory usage
pidstat -d -p PID          # Disk I/O

# Detailed process information
cat /proc/PID/status
cat /proc/PID/stat
cat /proc/PID/statm
```

#### Process Relationships

```bash
# Parent-child relationships
ps -eo pid,ppid,cmd --forest

# Find all child processes
pgrep -P PARENT_PID

# Process group information
ps -eo pid,pgid,sid,cmd

# Session and process group leaders
ps -eo pid,sid,pgid,tpgid,stat,cmd
```

### System Resource Limits

#### Setting Process Limits

```bash
# View current limits
ulimit -a

# Set limits for current shell
ulimit -n 4096     # Open files
ulimit -u 2048     # Max processes
ulimit -m 1048576  # Max memory (KB)
ulimit -t 3600     # CPU time (seconds)
ulimit -c unlimited # Core dump size

# Permanent limits in /etc/security/limits.conf
echo "username soft nofile 4096" | sudo tee -a /etc/security/limits.conf
echo "username hard nofile 8192" | sudo tee -a /etc/security/limits.conf
echo "username soft nproc 2048" | sudo tee -a /etc/security/limits.conf
```

#### Resource Monitoring

```bash
# System-wide resource usage
vmstat 1 5         # Virtual memory stats
iostat 1 5         # I/O statistics
sar -u 1 5         # CPU utilization

# Per-process resource monitoring
strace -p PID      # System calls
ltrace -p PID      # Library calls
lsof -p PID        # Open files

# Memory mapping
pmap PID
pmap -x PID        # Extended format
cat /proc/PID/maps
```

## Process Automation and Scheduling

### Background Process Management

#### Daemon Processes

```bash
# Create daemon-like process
nohup command > /dev/null 2>&1 &

# Disown process from shell
command &
disown %1

# Start detached screen session
screen -dmS session_name command

# Start detached tmux session
tmux new-session -d -s session_name command
```

#### Persistent Processes

```bash
# Using screen
screen -S mysession
# Run commands in screen
# Detach: Ctrl+A, D
# Reattach: screen -r mysession

# Using tmux
tmux new -s mysession
# Run commands in tmux
# Detach: Ctrl+B, D
# Reattach: tmux attach -t mysession

# List sessions
screen -ls
tmux list-sessions
```

### Process Debugging

#### Debugging Tools

```bash
# Trace system calls
strace command
strace -p PID              # Attach to running process
strace -o trace.log command # Save to file
strace -f command          # Follow child processes

# Trace library calls
ltrace command
ltrace -p PID

# Debug with gdb
gdb program
gdb -p PID                 # Attach to running process

# Memory debugging
valgrind command
valgrind --tool=memcheck --leak-check=full command
```

#### Performance Analysis

```bash
# Profile CPU usage
perf record command
perf record -p PID
perf report

# System call statistics
strace -c command

# I/O monitoring for specific process
iotop -p PID
```

### Process Communication

#### Inter-Process Communication

```bash
# Pipes and named pipes
command1 | command2
mkfifo mypipe
echo "data" > mypipe &
cat < mypipe

# Signals for IPC
kill -USR1 PID             # Send custom signal

# Shared memory
ipcs                       # List IPC resources
ipcs -m                    # Shared memory segments
ipcs -s                    # Semaphores
ipcs -q                    # Message queues

# Clean up IPC resources
ipcrm -m shmid
ipcrm -s semid
ipcrm -q msgid
```

### System Service Management

#### systemd Process Management

```bash
# Service control
sudo systemctl start service_name
sudo systemctl stop service_name
sudo systemctl restart service_name
sudo systemctl reload service_name

# Service status
systemctl status service_name
systemctl is-active service_name
systemctl is-enabled service_name

# Process management through systemd
systemctl show service_name --property=MainPID
systemd-cgls                # Control group hierarchy
systemctl kill service_name # Kill service processes
```

### Process Monitoring Scripts

#### Custom Monitoring Script

```bash
#!/bin/bash

# Process monitoring script
PROCESS_NAME="$1"
LOG_FILE="/var/log/process_monitor.log"

if [ -z "$PROCESS_NAME" ]; then
    echo "Usage: $0 <process_name>"
    exit 1
fi

monitor_process() {
    while true; do
        PID=$(pgrep "$PROCESS_NAME" | head -1)

        if [ -n "$PID" ]; then
            CPU=$(ps -o %cpu= -p "$PID")
            MEM=$(ps -o %mem= -p "$PID")
            TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

            echo "[$TIMESTAMP] $PROCESS_NAME (PID: $PID) - CPU: $CPU%, MEM: $MEM%" >> "$LOG_FILE"
        else
            echo "[$TIMESTAMP] $PROCESS_NAME not running" >> "$LOG_FILE"
        fi

        sleep 60
    done
}

monitor_process
```

#### Process Cleanup Script

```bash
#!/bin/bash

# Cleanup old processes script
cleanup_processes() {
    # Kill processes older than 1 hour
    for pid in $(ps -eo pid,etime,cmd | awk '$2 ~ /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/ {print $1}'); do
        echo "Killing old process: $pid"
        kill -TERM "$pid"
    done

    # Clean up zombie processes
    ps aux | awk '$8 ~ /^Z/ {print $2}' | while read pid; do
        echo "Found zombie process: $pid"
        parent=$(ps -o ppid= -p "$pid")
        if [ -n "$parent" ]; then
            echo "Killing parent process: $parent"
            kill -TERM "$parent"
        fi
    done
}

cleanup_processes
```

This comprehensive guide covers all aspects of Linux process management, from basic process control to advanced monitoring and debugging techniques essential for system administrators and developers working with Ubuntu systems.
