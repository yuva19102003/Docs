# Linux File Management

## Overview
File management is fundamental to Linux administration. This guide covers compression, archiving, searching, and manipulating files efficiently.

---

## File Compression and Archiving

### `tar` - Tape Archive
Create and extract compressed archives.

**Create archives:**
```bash
tar -cvf archive.tar /path/to/directory      # Create uncompressed tar
tar -czvf archive.tar.gz /path/to/directory  # Create gzip compressed
tar -cjvf archive.tar.bz2 /path/to/directory # Create bzip2 compressed
tar -cJvf archive.tar.xz /path/to/directory  # Create xz compressed
```

**Extract archives:**
```bash
tar -xvf archive.tar                         # Extract tar
tar -xzvf archive.tar.gz                     # Extract gzip
tar -xjvf archive.tar.bz2                    # Extract bzip2
tar -xJvf archive.tar.xz                     # Extract xz
```

**Common options:**
- `c` - Create archive
- `x` - Extract archive
- `v` - Verbose (show progress)
- `f` - File (specify archive name)
- `z` - Gzip compression
- `j` - Bzip2 compression
- `J` - XZ compression
- `t` - List contents without extracting

**Useful examples:**
```bash
# List archive contents
tar -tzf archive.tar.gz

# Extract to specific directory
tar -xzvf archive.tar.gz -C /destination/path

# Extract specific file
tar -xzvf archive.tar.gz path/to/file.txt

# Exclude files while creating
tar -czvf archive.tar.gz --exclude='*.log' /path/to/directory

# Append files to existing archive
tar -rvf archive.tar newfile.txt
```

### `gzip` / `gunzip` - Gzip Compression
Compress individual files (replaces original).

```bash
gzip file.txt                    # Creates file.txt.gz, removes file.txt
gzip -k file.txt                 # Keep original file
gzip -9 file.txt                 # Maximum compression
gunzip file.txt.gz               # Decompress
gzip -d file.txt.gz              # Alternative decompress
```

### `bzip2` / `bunzip2` - Bzip2 Compression
Better compression than gzip, slower.

```bash
bzip2 file.txt                   # Creates file.txt.bz2
bzip2 -k file.txt                # Keep original
bunzip2 file.txt.bz2             # Decompress
```

### `xz` / `unxz` - XZ Compression
Best compression ratio, slowest.

```bash
xz file.txt                      # Creates file.txt.xz
xz -k file.txt                   # Keep original
unxz file.txt.xz                 # Decompress
```

### `zip` / `unzip` - ZIP Archives
Cross-platform compression format.

```bash
# Create zip archive
zip archive.zip file1 file2 file3
zip -r archive.zip directory/    # Recursive

# Extract zip archive
unzip archive.zip
unzip archive.zip -d /destination/path

# List contents
unzip -l archive.zip

# Test archive integrity
unzip -t archive.zip
```

---

## Searching for Files

### `find` - Search for Files
Powerful file search tool with many options.

**Basic syntax:**
```bash
find /path/to/search -name "filename"
```

**Search by name:**
```bash
find / -name "config.txt"                    # Exact name
find / -iname "config.txt"                   # Case-insensitive
find / -name "*.log"                         # Wildcard pattern
find / -name "*.conf" -o -name "*.cfg"       # Multiple patterns (OR)
```

**Search by type:**
```bash
find / -type f                               # Files only
find / -type d                               # Directories only
find / -type l                               # Symbolic links only
```

**Search by size:**
```bash
find / -size +100M                           # Larger than 100MB
find / -size -1M                             # Smaller than 1MB
find / -size 50M                             # Exactly 50MB
find / -size +1G -size -10G                  # Between 1GB and 10GB
```

**Search by time:**
```bash
find / -mtime -7                             # Modified in last 7 days
find / -mtime +30                            # Modified more than 30 days ago
find / -atime -1                             # Accessed in last 24 hours
find / -ctime -7                             # Changed in last 7 days
find / -mmin -60                             # Modified in last 60 minutes
```

**Search by permissions:**
```bash
find / -perm 777                             # Exact permissions
find / -perm -644                            # At least these permissions
find / -perm /u+w                            # User writable
```

**Search by owner:**
```bash
find / -user username                        # Owned by user
find / -group groupname                      # Owned by group
find / -nouser                               # No owner (orphaned)
```

**Execute commands on results:**
```bash
# Delete found files
find /tmp -name "*.tmp" -delete

# Execute command on each file
find / -name "*.log" -exec rm {} \;
find / -name "*.txt" -exec chmod 644 {} \;

# Execute with confirmation
find / -name "*.bak" -ok rm {} \;

# Execute command on multiple files at once (faster)
find / -name "*.log" -exec rm {} +
```

**Practical examples:**
```bash
# Find large files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

# Find empty files
find / -type f -empty

# Find files modified today
find / -type f -mtime 0

# Find and compress old logs
find /var/log -name "*.log" -mtime +30 -exec gzip {} \;

# Find world-writable files (security risk)
find / -type f -perm -002

# Find SUID files (security audit)
find / -type f -perm -4000 -ls 2>/dev/null
```

### `locate` - Fast File Search
Uses database for quick searches (faster than find).

```bash
# Update database (run as root)
sudo updatedb

# Search for files
locate filename
locate -i filename                           # Case-insensitive
locate -c filename                           # Count matches
locate -r "pattern"                          # Regex search
```

**Note:** `locate` uses a database updated daily. New files won't appear until database is updated.

---

## Searching Within Files

### `grep` - Search Text in Files
Search for patterns within file contents.

**Basic usage:**
```bash
grep "search_term" filename
grep "error" /var/log/syslog
```

**Common options:**
```bash
grep -i "error" file.txt                     # Case-insensitive
grep -r "error" /var/log/                    # Recursive search
grep -n "error" file.txt                     # Show line numbers
grep -v "error" file.txt                     # Invert match (exclude)
grep -c "error" file.txt                     # Count matches
grep -l "error" *.txt                        # Show only filenames
grep -w "error" file.txt                     # Match whole word
grep -A 5 "error" file.txt                   # Show 5 lines after match
grep -B 5 "error" file.txt                   # Show 5 lines before match
grep -C 5 "error" file.txt                   # Show 5 lines before and after
```

**Advanced patterns:**
```bash
# Multiple patterns (OR)
grep -E "error|warning|critical" file.txt
grep "error\|warning" file.txt

# Multiple patterns (AND)
grep "error" file.txt | grep "database"

# Regex patterns
grep "^error" file.txt                       # Lines starting with "error"
grep "error$" file.txt                       # Lines ending with "error"
grep "[0-9]\{3\}" file.txt                   # Three consecutive digits
```

**Practical examples:**
```bash
# Find errors in logs
grep -i "error" /var/log/syslog

# Search multiple files
grep -r "TODO" /path/to/code/

# Find IP addresses
grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" file.txt

# Exclude certain files
grep -r "error" /var/log/ --exclude="*.gz"

# Search compressed files
zgrep "error" /var/log/syslog.*.gz
```

---

## File Manipulation

### `cat` - Concatenate and Display
```bash
cat file.txt                                 # Display file
cat file1.txt file2.txt                      # Display multiple files
cat file1.txt file2.txt > combined.txt       # Combine files
cat >> file.txt                              # Append to file (Ctrl+D to save)
```

### `head` / `tail` - View File Portions
```bash
head file.txt                                # First 10 lines
head -n 20 file.txt                          # First 20 lines
tail file.txt                                # Last 10 lines
tail -n 20 file.txt                          # Last 20 lines
tail -f /var/log/syslog                      # Follow file in real-time
tail -f -n 100 /var/log/syslog               # Follow last 100 lines
```

### `less` / `more` - Page Through Files
```bash
less file.txt                                # View file (recommended)
more file.txt                                # View file (older tool)
```

**less commands:**
- `Space` - Next page
- `b` - Previous page
- `/pattern` - Search forward
- `?pattern` - Search backward
- `n` - Next match
- `N` - Previous match
- `g` - Go to beginning
- `G` - Go to end
- `q` - Quit

### `wc` - Word Count
```bash
wc file.txt                                  # Lines, words, bytes
wc -l file.txt                               # Count lines
wc -w file.txt                               # Count words
wc -c file.txt                               # Count bytes
```

### `sort` - Sort Lines
```bash
sort file.txt                                # Alphabetical sort
sort -r file.txt                             # Reverse sort
sort -n file.txt                             # Numeric sort
sort -u file.txt                             # Unique lines only
sort -k 2 file.txt                           # Sort by 2nd column
```

### `uniq` - Remove Duplicates
```bash
uniq file.txt                                # Remove adjacent duplicates
sort file.txt | uniq                         # Remove all duplicates
uniq -c file.txt                             # Count occurrences
uniq -d file.txt                             # Show only duplicates
```

### `cut` - Extract Columns
```bash
cut -d ':' -f 1 /etc/passwd                  # Extract 1st field
cut -d ':' -f 1,3 /etc/passwd                # Extract 1st and 3rd fields
cut -c 1-10 file.txt                         # Extract characters 1-10
```

### `awk` - Text Processing
```bash
awk '{print $1}' file.txt                    # Print 1st column
awk -F ':' '{print $1}' /etc/passwd          # Custom delimiter
awk '$3 > 100' file.txt                      # Filter rows
awk '{sum+=$1} END {print sum}' file.txt     # Sum column
```

### `sed` - Stream Editor
```bash
sed 's/old/new/' file.txt                    # Replace first occurrence
sed 's/old/new/g' file.txt                   # Replace all occurrences
sed -i 's/old/new/g' file.txt                # Edit file in-place
sed '1,10d' file.txt                         # Delete lines 1-10
sed -n '5,10p' file.txt                      # Print lines 5-10
```

---

## File Comparison

### `diff` - Compare Files
```bash
diff file1.txt file2.txt                     # Show differences
diff -u file1.txt file2.txt                  # Unified format
diff -y file1.txt file2.txt                  # Side-by-side
diff -r dir1/ dir2/                          # Compare directories
```

### `cmp` - Byte-by-Byte Comparison
```bash
cmp file1.txt file2.txt                      # Compare files
cmp -s file1.txt file2.txt && echo "Same"    # Silent comparison
```

---

## Practical Scenarios

### Backup Important Files
```bash
# Create compressed backup
tar -czvf backup-$(date +%Y%m%d).tar.gz /path/to/data

# Backup with exclusions
tar -czvf backup.tar.gz --exclude='*.log' --exclude='tmp/*' /path/to/data
```

### Find and Delete Old Files
```bash
# Find files older than 30 days
find /tmp -type f -mtime +30

# Delete old log files
find /var/log -name "*.log" -mtime +90 -delete

# Delete old backups
find /backups -name "*.tar.gz" -mtime +365 -exec rm {} \;
```

### Search Logs for Errors
```bash
# Find errors in current log
grep -i "error" /var/log/syslog

# Search all logs including compressed
zgrep -i "error" /var/log/syslog*

# Count error occurrences
grep -c "error" /var/log/syslog

# Find errors with context
grep -C 3 "error" /var/log/syslog
```

### Disk Space Cleanup
```bash
# Find large files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -rh

# Find duplicate files
find / -type f -exec md5sum {} \; | sort | uniq -w32 -dD

# Clean package cache
sudo apt clean                               # Debian/Ubuntu
sudo yum clean all                           # RHEL/CentOS
```

---

## Best Practices

1. **Always test find commands** - Use `-print` before `-delete` or `-exec`
2. **Use compression wisely** - Balance compression ratio vs. time
3. **Regular backups** - Automate with cron jobs
4. **Verify archives** - Test extraction before deleting originals
5. **Use appropriate tools** - `locate` for speed, `find` for flexibility
6. **Redirect errors** - Use `2>/dev/null` to suppress permission errors
7. **Document searches** - Save complex find/grep commands as scripts

---

## Related Topics
- [Basics and Navigation](01-Basics-Navigation.md) - File operations
- [Permissions](02-Permissions.md) - File security
- [Shell Scripting](09-Shell-Scripting.md) - Automating file management
