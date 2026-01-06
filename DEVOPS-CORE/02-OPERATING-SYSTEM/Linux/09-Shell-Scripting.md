# Linux Shell Scripting

## Overview
Shell scripting is essential for automating repetitive tasks, system administration, and DevOps workflows. This guide covers Bash scripting fundamentals with practical examples.

---

## Getting Started

### Creating a Script
```bash
# Create script file
nano script.sh

# Make executable
chmod +x script.sh

# Run script
./script.sh
```

### Basic Script Structure
```bash
#!/bin/bash
# This is a comment
# Script description

echo "Hello, World!"
```

**Shebang (`#!/bin/bash`):**
- Must be first line
- Tells system which interpreter to use
- Common options:
  - `#!/bin/bash` - Bash shell
  - `#!/bin/sh` - POSIX shell
  - `#!/usr/bin/env bash` - Portable (finds bash in PATH)

---

## Variables

### Declaring Variables
```bash
#!/bin/bash

# Variable assignment (no spaces around =)
name="John"
age=30
```

# Using variables
echo "Name: $name"
echo "Age: ${age}"

# Command substitution
current_date=$(date)
user_count=$(who | wc -l)

echo "Date: $current_date"
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

**Example usage:**
```bash
./script.sh arg1 arg2 arg3
# $0 = ./script.sh
# $1 = arg1
# $2 = arg2
# $@ = arg1 arg2 arg3
# $# = 3
```

### Environment Variables
```bash
#!/bin/bash

# Common environment variables
echo "Home directory: $HOME"
echo "Current user: $USER"
echo "Current path: $PWD"
echo "Shell: $SHELL"
echo "PATH: $PATH"

# Set environment variable
export MY_VAR="value"
```

---

## Input and Output

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
read -sp "Enter password: " password
echo ""
echo "Password saved"

# Read multiple values
read -p "Enter first and last name: " first last
echo "First: $first, Last: $last"
```

### Output
```bash
#!/bin/bash

# Standard output
echo "This goes to stdout"
printf "Formatted: %s %d\n" "Number" 42

# Error output
echo "Error message" >&2

# Redirect output
echo "Save to file" > output.txt
echo "Append to file" >> output.txt

# Suppress output
command > /dev/null 2>&1
```

---

## Conditionals

### If Statements
```bash
#!/bin/bash

# Basic if
if [ "$USER" = "root" ]; then
    echo "Running as root"
fi

# If-else
if [ -f "file.txt" ]; then
    echo "File exists"
else
    echo "File does not exist"
fi

# If-elif-else
if [ $age -lt 18 ]; then
    echo "Minor"
elif [ $age -lt 65 ]; then
    echo "Adult"
else
    echo "Senior"
fi
```

### Test Operators

**File tests:**
```bash
[ -f file ]      # File exists and is regular file
[ -d dir ]       # Directory exists
[ -e path ]      # Path exists (file or directory)
[ -r file ]      # File is readable
[ -w file ]      # File is writable
[ -x file ]      # File is executable
[ -s file ]      # File exists and is not empty
[ -L link ]      # Path is symbolic link
```

**String tests:**
```bash
[ -z "$str" ]    # String is empty
[ -n "$str" ]    # String is not empty
[ "$a" = "$b" ]  # Strings are equal
[ "$a" != "$b" ] # Strings are not equal
```

**Numeric tests:**
```bash
[ $a -eq $b ]    # Equal
[ $a -ne $b ]    # Not equal
[ $a -lt $b ]    # Less than
[ $a -le $b ]    # Less than or equal
[ $a -gt $b ]    # Greater than
[ $a -ge $b ]    # Greater than or equal
```

**Logical operators:**
```bash
[ condition1 ] && [ condition2 ]  # AND
[ condition1 ] || [ condition2 ]  # OR
[ ! condition ]                   # NOT
```

### Case Statements
```bash
#!/bin/bash

read -p "Enter a choice (start/stop/restart): " choice

case $choice in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
```

---

## Loops

### For Loop
```bash
#!/bin/bash

# Loop over list
for item in apple banana cherry; do
    echo "Fruit: $item"
done

# Loop over files
for file in *.txt; do
    echo "Processing $file"
done

# C-style for loop
for ((i=1; i<=5; i++)); do
    echo "Number: $i"
done

# Loop over command output
for user in $(cat /etc/passwd | cut -d: -f1); do
    echo "User: $user"
done
```

### While Loop
```bash
#!/bin/bash

# Basic while loop
counter=1
while [ $counter -le 5 ]; do
    echo "Count: $counter"
    ((counter++))
done

# Read file line by line
while read line; do
    echo "Line: $line"
done < file.txt

# Infinite loop
while true; do
    echo "Press Ctrl+C to stop"
    sleep 1
done
```

### Until Loop
```bash
#!/bin/bash

# Run until condition is true
counter=1
until [ $counter -gt 5 ]; do
    echo "Count: $counter"
    ((counter++))
done
```

### Loop Control
```bash
#!/bin/bash

# Break - exit loop
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        break
    fi
    echo $i
done

# Continue - skip iteration
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        continue
    fi
    echo $i
done
```

---

## Functions

### Defining Functions
```bash
#!/bin/bash

# Method 1
function greet() {
    echo "Hello, $1!"
}

# Method 2
say_goodbye() {
    echo "Goodbye, $1!"
}

# Call functions
greet "Alice"
say_goodbye "Bob"
```

### Function with Return Value
```bash
#!/bin/bash

add_numbers() {
    local sum=$(($1 + $2))
    echo $sum
}

result=$(add_numbers 5 3)
echo "Result: $result"
```

### Function with Return Status
```bash
#!/bin/bash

check_file() {
    if [ -f "$1" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

if check_file "test.txt"; then
    echo "File exists"
else
    echo "File not found"
fi
```

### Local Variables
```bash
#!/bin/bash

my_function() {
    local local_var="I'm local"
    global_var="I'm global"
    echo $local_var
}

my_function
echo $global_var      # Accessible
echo $local_var       # Not accessible (empty)
```

---

## Arrays

### Indexed Arrays
```bash
#!/bin/bash

# Declare array
fruits=("apple" "banana" "cherry")

# Access elements
echo ${fruits[0]}     # First element
echo ${fruits[1]}     # Second element
echo ${fruits[@]}     # All elements
echo ${#fruits[@]}    # Array length

# Add element
fruits+=("date")

# Loop through array
for fruit in "${fruits[@]}"; do
    echo $fruit
done

# Loop with index
for i in "${!fruits[@]}"; do
    echo "Index $i: ${fruits[$i]}"
done
```

### Associative Arrays (Bash 4+)
```bash
#!/bin/bash

# Declare associative array
declare -A person
person[name]="John"
person[age]=30
person[city]="New York"

# Access elements
echo ${person[name]}
echo ${person[age]}

# Loop through keys
for key in "${!person[@]}"; do
    echo "$key: ${person[$key]}"
done
```

---

## String Manipulation

### String Operations
```bash
#!/bin/bash

text="Hello World"

# Length
echo ${#text}         # 11

# Substring
echo ${text:0:5}      # Hello
echo ${text:6}        # World

# Replace
echo ${text/World/Universe}  # Hello Universe
echo ${text//o/0}     # Hell0 W0rld (replace all)

# Remove prefix/suffix
filename="script.sh"
echo ${filename%.sh}  # script (remove .sh)
echo ${filename#script.}  # sh (remove script.)

# Uppercase/lowercase
echo ${text^^}        # HELLO WORLD
echo ${text,,}        # hello world
```

### String Concatenation
```bash
#!/bin/bash

first="Hello"
second="World"

# Method 1
result="$first $second"

# Method 2
result="${first} ${second}"

echo $result
```

---

## Arithmetic Operations

### Basic Arithmetic
```bash
#!/bin/bash

# Using $(( ))
a=10
b=5

echo $((a + b))       # 15
echo $((a - b))       # 5
echo $((a * b))       # 50
echo $((a / b))       # 2
echo $((a % b))       # 0

# Increment/decrement
((a++))
((b--))
((a += 5))

# Using let
let result=a+b
echo $result

# Using expr (older method)
result=$(expr $a + $b)
echo $result
```

### Floating Point Arithmetic
```bash
#!/bin/bash

# Bash doesn't support floating point natively
# Use bc calculator

result=$(echo "scale=2; 10 / 3" | bc)
echo $result          # 3.33

result=$(echo "scale=4; 22 / 7" | bc)
echo $result          # 3.1428
```

---

## Practical Script Examples

### 1. Backup Script
```bash
#!/bin/bash

# Backup important files
SOURCE="/home/user/documents"
DEST="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DATE}.tar.gz"

echo "Starting backup..."
tar -czf "${DEST}/${BACKUP_FILE}" "$SOURCE"

if [ $? -eq 0 ]; then
    echo "Backup completed: ${BACKUP_FILE}"
else
    echo "Backup failed!" >&2
    exit 1
fi
```

### 2. System Health Check
```bash
#!/bin/bash

echo "=== System Health Check ==="
echo "Date: $(date)"
echo ""

# CPU Load
echo "CPU Load:"
uptime

# Memory Usage
echo ""
echo "Memory Usage:"
free -h

# Disk Usage
echo ""
echo "Disk Usage:"
df -h | grep -v tmpfs

# Check if disk usage > 80%
df -h | awk '{print $5 " " $6}' | while read usage mount; do
    usage_num=${usage%\%}
    if [ "$usage_num" -gt 80 ] 2>/dev/null; then
        echo "WARNING: $mount is ${usage} full"
    fi
done
```

### 3. Log Rotation Script
```bash
#!/bin/bash

LOG_DIR="/var/log/myapp"
MAX_DAYS=30

echo "Rotating logs older than $MAX_DAYS days..."

find "$LOG_DIR" -name "*.log" -type f -mtime +$MAX_DAYS -exec gzip {} \;
find "$LOG_DIR" -name "*.log.gz" -type f -mtime +90 -delete

echo "Log rotation completed"
```

### 4. Service Monitor
```bash
#!/bin/bash

SERVICE="nginx"

if systemctl is-active --quiet "$SERVICE"; then
    echo "$SERVICE is running"
else
    echo "$SERVICE is not running. Starting..."
    systemctl start "$SERVICE"
    
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE started successfully"
    else
        echo "Failed to start $SERVICE" >&2
        exit 1
    fi
fi
```

### 5. User Creation Script
```bash
#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME=$1

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
    exit 1
fi

# Create user
useradd -m -s /bin/bash "$USERNAME"

if [ $? -eq 0 ]; then
    echo "User $USERNAME created successfully"
    passwd "$USERNAME"
else
    echo "Failed to create user" >&2
    exit 1
fi
```

### 6. File Organizer
```bash
#!/bin/bash

SOURCE_DIR="$HOME/Downloads"
DEST_DIR="$HOME/Organized"

# Create destination directories
mkdir -p "$DEST_DIR"/{Images,Documents,Videos,Archives,Others}

# Move files based on extension
for file in "$SOURCE_DIR"/*; do
    if [ -f "$file" ]; then
        case "${file##*.}" in
            jpg|jpeg|png|gif)
                mv "$file" "$DEST_DIR/Images/"
                ;;
            pdf|doc|docx|txt)
                mv "$file" "$DEST_DIR/Documents/"
                ;;
            mp4|avi|mkv)
                mv "$file" "$DEST_DIR/Videos/"
                ;;
            zip|tar|gz|rar)
                mv "$file" "$DEST_DIR/Archives/"
                ;;
            *)
                mv "$file" "$DEST_DIR/Others/"
                ;;
        esac
    fi
done

echo "Files organized successfully"
```

---

## Error Handling

### Exit Status
```bash
#!/bin/bash

# Check command success
if command; then
    echo "Success"
else
    echo "Failed"
fi

# Check exit status
command
if [ $? -eq 0 ]; then
    echo "Success"
fi
```

### Set Options
```bash
#!/bin/bash

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# Combine options
set -euo pipefail
```

### Trap Errors
```bash
#!/bin/bash

# Cleanup on exit
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# Catch errors
error_handler() {
    echo "Error on line $1"
    exit 1
}

trap 'error_handler $LINENO' ERR
```

---

## Debugging

### Debug Options
```bash
#!/bin/bash

set -x  # Print commands before execution
set -v  # Print script lines as read

# Run script in debug mode
bash -x script.sh
```

### Debug Output
```bash
#!/bin/bash

DEBUG=true

debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $@" >&2
    fi
}

debug "This is a debug message"
echo "Normal output"
```

---

## Best Practices

1. **Always use shebang** - `#!/bin/bash` at the top
2. **Quote variables** - Use `"$var"` to prevent word splitting
3. **Check arguments** - Validate input before processing
4. **Use meaningful names** - Clear variable and function names
5. **Add comments** - Explain complex logic
6. **Handle errors** - Check exit status and use `set -e`
7. **Use functions** - Break complex scripts into functions
8. **Test thoroughly** - Test with various inputs and edge cases
9. **Make scripts portable** - Avoid bash-specific features if possible
10. **Use shellcheck** - Lint your scripts with shellcheck tool

---

## Related Topics
- [Basics and Navigation](01-Basics-Navigation.md) - File operations
- [Process Management](05-Process-Management.md) - Managing processes
- [System Monitoring](06-System-Monitoring.md) - Monitoring automation
- [File Management](07-File-Management.md) - File operations
