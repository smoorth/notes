# Shell Scripting Guide for Ubuntu

## Introduction to Shell Scripting

Shell scripting allows you to automate tasks and create powerful command-line tools. This guide focuses on Bash scripting, the default shell in Ubuntu.

## Basic Script Structure

### Creating Your First Script

```bash
#!/bin/bash
# This is a comment
# Script: hello.sh
# Purpose: Display a greeting message

echo "Hello, World!"
echo "Welcome to shell scripting!"
```

### Making Scripts Executable

```bash
# Make script executable
chmod +x script.sh

# Run the script
./script.sh

# Run with bash explicitly
bash script.sh
```

### Shebang Lines

```bash
#!/bin/bash              # Bash shell
#!/bin/sh                # POSIX shell
#!/usr/bin/env bash      # Portable bash
#!/usr/bin/env python3   # Python script
```

## Variables and Data Types

### Variable Declaration and Usage

```bash
#!/bin/bash

# Variable assignment (no spaces around =)
name="John"
age=25
PI=3.14159

# Using variables
echo "Name: $name"
echo "Age: ${age} years old"
echo "Pi value: $PI"

# Command substitution
current_date=$(date)
user_count=`who | wc -l`

echo "Current date: $current_date"
echo "Users logged in: $user_count"
```

### Special Variables

```bash
#!/bin/bash

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
echo "Exit status of last command: $?"
echo "Process ID: $$"
```

### Array Variables

```bash
#!/bin/bash

# Declare array
fruits=("apple" "banana" "orange")

# Access elements
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[@]}"
echo "Number of fruits: ${#fruits[@]}"

# Add elements
fruits+=("grape")

# Loop through array
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
```

## User Input and Output

### Reading User Input

```bash
#!/bin/bash

# Simple input
echo "Enter your name:"
read name
echo "Hello, $name!"

# Input with prompt
read -p "Enter your age: " age
echo "You are $age years old"

# Silent input (for passwords)
read -s -p "Enter password: " password
echo  # New line after password input

# Input with timeout
if read -t 10 -p "Enter something (10 sec timeout): " input; then
    echo "You entered: $input"
else
    echo "Timeout occurred"
fi
```

### Output Formatting

```bash
#!/bin/bash

# printf for formatted output
printf "Name: %-10s Age: %3d\n" "John" 25
printf "Pi: %.2f\n" 3.14159

# Here documents
cat << EOF
This is a multi-line
output using here document.
Variables work here too: $USER
EOF

# Colors in output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}Error message${NC}"
echo -e "${GREEN}Success message${NC}"
echo -e "${YELLOW}Warning message${NC}"
```

## Control Structures

### Conditional Statements

```bash
#!/bin/bash

# if-then-else
age=18
if [ $age -ge 18 ]; then
    echo "You are an adult"
elif [ $age -ge 13 ]; then
    echo "You are a teenager"
else
    echo "You are a child"
fi

# File testing
filename="test.txt"
if [ -f "$filename" ]; then
    echo "File exists"
    if [ -r "$filename" ]; then
        echo "File is readable"
    fi
    if [ -w "$filename" ]; then
        echo "File is writable"
    fi
else
    echo "File does not exist"
fi

# String comparisons
string1="hello"
string2="world"
if [ "$string1" = "$string2" ]; then
    echo "Strings are equal"
else
    echo "Strings are different"
fi

# Numeric comparisons
num1=10
num2=20
if [ $num1 -lt $num2 ]; then
    echo "$num1 is less than $num2"
fi
```

### Case Statements

```bash
#!/bin/bash

echo "Enter a choice (1-3):"
read choice

case $choice in
    1)
        echo "You chose option 1"
        ;;
    2)
        echo "You chose option 2"
        ;;
    3)
        echo "You chose option 3"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac

# Case with patterns
read -p "Enter file extension: " ext
case $ext in
    txt|doc)
        echo "Text document"
        ;;
    jpg|png|gif)
        echo "Image file"
        ;;
    mp3|wav|ogg)
        echo "Audio file"
        ;;
    *)
        echo "Unknown file type"
        ;;
esac
```

### Loops

#### For Loops

```bash
#!/bin/bash

# Traditional for loop
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# Range for loop
for i in {1..10}; do
    echo "Count: $i"
done

# Step range
for i in {0..20..2}; do
    echo "Even number: $i"
done

# C-style for loop
for ((i=1; i<=10; i++)); do
    echo "Counter: $i"
done

# Loop through files
for file in *.txt; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
    fi
done

# Loop through command output
for user in $(cut -d: -f1 /etc/passwd); do
    echo "User: $user"
done
```

#### While Loops

```bash
#!/bin/bash

# Basic while loop
counter=1
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    counter=$((counter + 1))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < "input.txt"

# Infinite loop with break
while true; do
    read -p "Enter 'quit' to exit: " input
    if [ "$input" = "quit" ]; then
        break
    fi
    echo "You entered: $input"
done
```

#### Until Loops

```bash
#!/bin/bash

# Until loop (opposite of while)
counter=1
until [ $counter -gt 5 ]; do
    echo "Counter: $counter"
    counter=$((counter + 1))
done
```

## Functions

### Function Definition and Usage

```bash
#!/bin/bash

# Function definition
greet() {
    echo "Hello, $1!"
}

# Function with multiple parameters
calculate_area() {
    local length=$1
    local width=$2
    local area=$((length * width))
    echo $area
}

# Function with return value
is_even() {
    local number=$1
    if [ $((number % 2)) -eq 0 ]; then
        return 0  # true
    else
        return 1  # false
    fi
}

# Using functions
greet "Alice"
greet "Bob"

area=$(calculate_area 5 3)
echo "Area: $area"

if is_even 10; then
    echo "10 is even"
else
    echo "10 is odd"
fi
```

### Local Variables and Scope

```bash
#!/bin/bash

global_var="I'm global"

test_scope() {
    local local_var="I'm local"
    global_var="Modified global"

    echo "Inside function:"
    echo "Local: $local_var"
    echo "Global: $global_var"
}

echo "Before function:"
echo "Global: $global_var"

test_scope

echo "After function:"
echo "Global: $global_var"
# echo "Local: $local_var"  # This would cause an error
```

## File Operations

### File Testing and Manipulation

```bash
#!/bin/bash

# File tests
check_file() {
    local file=$1

    if [ -e "$file" ]; then
        echo "$file exists"

        if [ -f "$file" ]; then
            echo "It's a regular file"
        elif [ -d "$file" ]; then
            echo "It's a directory"
        elif [ -L "$file" ]; then
            echo "It's a symbolic link"
        fi

        if [ -r "$file" ]; then
            echo "Readable"
        fi

        if [ -w "$file" ]; then
            echo "Writable"
        fi

        if [ -x "$file" ]; then
            echo "Executable"
        fi
    else
        echo "$file does not exist"
    fi
}

# File processing
process_logs() {
    local logfile=$1

    if [ ! -f "$logfile" ]; then
        echo "Log file not found: $logfile"
        return 1
    fi

    echo "Processing log file: $logfile"
    echo "Lines: $(wc -l < "$logfile")"
    echo "Words: $(wc -w < "$logfile")"
    echo "Size: $(du -h "$logfile" | cut -f1)"

    # Extract errors
    grep -i "error" "$logfile" > errors.log
    echo "Errors extracted to errors.log"
}

# Usage
check_file "/etc/passwd"
process_logs "/var/log/syslog"
```

## Error Handling and Debugging

### Exit Codes and Error Handling

```bash
#!/bin/bash

# Set strict mode
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo "Error occurred in script at line $line_number: exit code $exit_code"
    exit $exit_code
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Function with error checking
safe_copy() {
    local source=$1
    local destination=$2

    if [ ! -f "$source" ]; then
        echo "Error: Source file '$source' not found" >&2
        return 1
    fi

    if cp "$source" "$destination"; then
        echo "Successfully copied $source to $destination"
        return 0
    else
        echo "Error: Failed to copy $source to $destination" >&2
        return 1
    fi
}

# Usage with error checking
if safe_copy "file1.txt" "file2.txt"; then
    echo "Copy operation successful"
else
    echo "Copy operation failed"
    exit 1
fi
```

### Debugging Techniques

```bash
#!/bin/bash

# Debug mode
set -x  # Enable debug mode

# Conditional debugging
DEBUG=${DEBUG:-0}

debug_log() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "DEBUG: $*" >&2
    fi
}

# Function to demonstrate debugging
process_data() {
    local data=$1
    debug_log "Processing data: $data"

    # Simulate processing
    local result=$((data * 2))
    debug_log "Result: $result"

    echo $result
}

# Usage
export DEBUG=1
result=$(process_data 5)
echo "Final result: $result"
```

## Practical Examples

### System Information Script

```bash
#!/bin/bash

# System Information Script
echo "===== SYSTEM INFORMATION ====="
echo "Hostname: $(hostname)"
echo "Operating System: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Current User: $USER"
echo "Current Date: $(date)"

echo -e "\n===== CPU INFORMATION ====="
echo "CPU Model: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo "CPU Cores: $(nproc)"
echo "CPU Usage: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1)%"

echo -e "\n===== MEMORY INFORMATION ====="
free -h | grep -E "(Mem|Swap)"

echo -e "\n===== DISK INFORMATION ====="
df -h | grep -E "(Filesystem|/dev/)"

echo -e "\n===== NETWORK INFORMATION ====="
ip addr show | grep -E "(inet|ether)" | head -10
```

### Backup Script

```bash
#!/bin/bash

# Backup Script with rotation
BACKUP_SOURCE="/home/user/documents"
BACKUP_DEST="/backup"
MAX_BACKUPS=7
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$DATE.tar.gz"

# Create backup
create_backup() {
    echo "Creating backup: $BACKUP_NAME"

    if tar -czf "$BACKUP_DEST/$BACKUP_NAME" -C "$(dirname "$BACKUP_SOURCE")" "$(basename "$BACKUP_SOURCE")"; then
        echo "Backup created successfully"
    else
        echo "Backup failed"
        exit 1
    fi
}

# Rotate old backups
rotate_backups() {
    echo "Rotating old backups..."

    cd "$BACKUP_DEST" || exit 1

    # Keep only the newest MAX_BACKUPS files
    ls -t backup_*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm -f

    echo "Backup rotation completed"
}

# Main execution
main() {
    # Check if source exists
    if [ ! -d "$BACKUP_SOURCE" ]; then
        echo "Error: Backup source '$BACKUP_SOURCE' not found"
        exit 1
    fi

    # Create backup destination if it doesn't exist
    mkdir -p "$BACKUP_DEST"

    # Create backup
    create_backup

    # Rotate old backups
    rotate_backups

    echo "Backup process completed"
}

main "$@"
```

This comprehensive shell scripting guide covers the fundamentals needed to create effective automation scripts for Ubuntu systems, from basic syntax to practical real-world examples.
