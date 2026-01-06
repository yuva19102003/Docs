# 📁 Linux Basics - File Navigation & Management

**Essential commands for navigating and managing files in Linux**

---

## 🎯 Overview

This guide covers the fundamental commands for navigating the Linux filesystem, managing files and directories, and viewing file contents.

---

## 📂 Directory Navigation

### List Files and Directories

#### `ls` - List Directory Contents

**Basic Usage:**
```bash
ls                    # List files in current directory
ls -l                 # Long format (detailed view)
ls -la                # Include hidden files
ls -lh                # Human-readable file sizes
ls -lt                # Sort by modification time
ls -lS                # Sort by file size
```

**Common Options:**
- `-l` - Long format with details
- `-a` - Show hidden files (starting with .)
- `-h` - Human-readable sizes (KB, MB, GB)
- `-t` - Sort by modification time
- `-r` - Reverse order
- `-R` - Recursive listing

**Examples:**
```bash
ls -lah /var/log      # List all files in /var/log with details
ls -lt | head -10     # Show 10 most recently modified files
ls -lS | tail -10     # Show 10 smallest files
```

---

### Change Directory

#### `cd` - Change Directory

**Basic Usage:**
```bash
cd /path/to/directory    # Go to specific directory
cd ~                     # Go to home directory
cd ..                    # Go up one level
cd -                     # Go to previous directory
cd                       # Go to home directory (same as cd ~)
```

**Examples:**
```bash
cd /var/log              # Navigate to /var/log
cd ~/Documents           # Navigate to Documents in home
cd ../../etc             # Go up two levels, then to etc
```

**Shortcuts:**
- `~` - Home directory
- `.` - Current directory
- `..` - Parent directory
- `-` - Previous directory
- `/` - Root directory

---

### Print Working Directory

#### `pwd` - Print Working Directory

**Usage:**
```bash
pwd                      # Show current directory path
```

**Example:**
```bash
$ pwd
/home/username/projects/devops
```

---

## 📄 File Operations

### Copy Files

#### `cp` - Copy Files and Directories

**Basic Usage:**
```bash
cp source.txt destination.txt           # Copy file
cp -r source_dir/ destination_dir/      # Copy directory recursively
cp -i source.txt destination.txt        # Interactive (prompt before overwrite)
cp -v source.txt destination.txt        # Verbose (show what's being copied)
```

**Common Options:**
- `-r` or `-R` - Copy directories recursively
- `-i` - Interactive mode (prompt before overwrite)
- `-v` - Verbose mode
- `-p` - Preserve file attributes
- `-u` - Copy only when source is newer

**Examples:**
```bash
cp file.txt backup/                     # Copy to directory
cp -r project/ project_backup/          # Copy entire directory
cp *.txt documents/                     # Copy all .txt files
cp -p important.txt backup/             # Preserve permissions and timestamps
```

---

### Move/Rename Files

#### `mv` - Move or Rename Files

**Basic Usage:**
```bash
mv oldname.txt newname.txt              # Rename file
mv file.txt /path/to/destination/       # Move file
mv -i source.txt destination.txt        # Interactive mode
mv -v source.txt destination.txt        # Verbose mode
```

**Common Options:**
- `-i` - Interactive (prompt before overwrite)
- `-v` - Verbose mode
- `-u` - Move only when source is newer
- `-n` - Don't overwrite existing files

**Examples:**
```bash
mv report.txt final_report.txt          # Rename file
mv *.log logs/                          # Move all .log files
mv -i important.txt backup/             # Move with confirmation
```

---

### Remove Files

#### `rm` - Remove Files and Directories

**Basic Usage:**
```bash
rm filename.txt                         # Remove file
rm -r directory/                        # Remove directory recursively
rm -i filename.txt                      # Interactive mode
rm -f filename.txt                      # Force removal (no prompt)
```

**Common Options:**
- `-r` or `-R` - Remove directories recursively
- `-i` - Interactive mode (prompt for each file)
- `-f` - Force removal without prompting
- `-v` - Verbose mode

**Examples:**
```bash
rm old_file.txt                         # Remove single file
rm -r old_directory/                    # Remove directory and contents
rm -i *.tmp                             # Remove with confirmation
rm -rf temp/                            # Force remove directory (use carefully!)
```

**⚠️ Warning:** `rm -rf` is dangerous! It permanently deletes without confirmation.

---

## 👁️ Viewing File Contents

### Display File Content

#### `cat` - Concatenate and Display Files

**Basic Usage:**
```bash
cat file.txt                            # Display entire file
cat file1.txt file2.txt                 # Display multiple files
cat -n file.txt                         # Show line numbers
```

**Common Options:**
- `-n` - Number all lines
- `-b` - Number non-empty lines
- `-s` - Squeeze multiple blank lines

**Examples:**
```bash
cat config.txt                          # View configuration file
cat file1.txt file2.txt > combined.txt  # Combine files
cat -n script.sh                        # View with line numbers
```

---

#### `less` - View File Page by Page

**Basic Usage:**
```bash
less file.txt                           # View file with pagination
less +F file.txt                        # Follow mode (like tail -f)
```

**Navigation Keys:**
- `Space` - Next page
- `b` - Previous page
- `g` - Go to beginning
- `G` - Go to end
- `/pattern` - Search forward
- `?pattern` - Search backward
- `n` - Next search result
- `q` - Quit

**Examples:**
```bash
less /var/log/syslog                    # View system log
less +F /var/log/apache2/access.log     # Follow log file
```

---

#### `head` - View Beginning of File

**Basic Usage:**
```bash
head file.txt                           # Show first 10 lines
head -n 20 file.txt                     # Show first 20 lines
head -n 5 *.txt                         # Show first 5 lines of all .txt files
```

**Examples:**
```bash
head -n 50 large_file.log               # View first 50 lines
head -n 1 *.csv                         # View headers of CSV files
```

---

#### `tail` - View End of File

**Basic Usage:**
```bash
tail file.txt                           # Show last 10 lines
tail -n 20 file.txt                     # Show last 20 lines
tail -f file.txt                        # Follow file (watch for new lines)
tail -f /var/log/syslog                 # Monitor log file in real-time
```

**Common Options:**
- `-n` - Number of lines to show
- `-f` - Follow mode (watch for changes)
- `-F` - Follow with retry (useful for rotating logs)

**Examples:**
```bash
tail -n 100 error.log                   # View last 100 lines
tail -f /var/log/nginx/access.log       # Monitor web server logs
tail -F /var/log/app.log                # Follow with retry
```

---

## 🔍 Additional Useful Commands

### Create Directories

#### `mkdir` - Make Directory

**Basic Usage:**
```bash
mkdir new_directory                     # Create directory
mkdir -p path/to/nested/directory       # Create nested directories
mkdir -v directory                      # Verbose mode
```

**Examples:**
```bash
mkdir projects                          # Create single directory
mkdir -p ~/projects/web/frontend        # Create nested structure
mkdir dir1 dir2 dir3                    # Create multiple directories
```

---

### Remove Directories

#### `rmdir` - Remove Empty Directory

**Basic Usage:**
```bash
rmdir empty_directory                   # Remove empty directory
rmdir -p path/to/empty/directory        # Remove nested empty directories
```

**Note:** Use `rm -r` to remove non-empty directories.

---

### Create Empty Files

#### `touch` - Create or Update File

**Basic Usage:**
```bash
touch newfile.txt                       # Create empty file
touch file1.txt file2.txt file3.txt     # Create multiple files
touch -t 202401011200 file.txt          # Set specific timestamp
```

**Examples:**
```bash
touch README.md                         # Create README file
touch {1..10}.txt                       # Create files 1.txt through 10.txt
```

---

## 💡 Practical Examples

### Example 1: Organize Files
```bash
# Create directory structure
mkdir -p ~/projects/{frontend,backend,docs}

# Move files to appropriate directories
mv *.html ~/projects/frontend/
mv *.js ~/projects/backend/
mv *.md ~/projects/docs/

# Verify
ls -R ~/projects/
```

### Example 2: Backup Files
```bash
# Create backup directory
mkdir -p ~/backups/$(date +%Y-%m-%d)

# Copy important files
cp -r ~/projects ~/backups/$(date +%Y-%m-%d)/

# Verify backup
ls -lh ~/backups/$(date +%Y-%m-%d)/
```

### Example 3: Clean Up Old Files
```bash
# List files older than 30 days
find ~/temp -type f -mtime +30

# Remove old log files (be careful!)
find ~/logs -name "*.log" -mtime +30 -delete

# Remove empty directories
find ~/temp -type d -empty -delete
```

---

## 🎯 Best Practices

1. **Always use `-i` flag** when removing or overwriting important files
2. **Use tab completion** to avoid typos in file paths
3. **Use `pwd`** to verify your location before operations
4. **Test with `ls`** before using wildcards with `rm`
5. **Create backups** before major file operations
6. **Use relative paths** when working within a project
7. **Avoid spaces** in filenames (use underscores or hyphens)

---

## 🔗 Related Topics

- **File Permissions:** `02-Permissions.md`
- **File Searching:** `07-File-Management.md`
- **Shell Scripting:** `09-Shell-Scripting.md`

---

**Last Updated:** January 5, 2026  
**Status:** ✅ Complete

