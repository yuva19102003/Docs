# 🔐 Linux File Permissions & Ownership

**Understanding and managing file permissions and ownership in Linux**

---

## 🎯 Overview

Linux file permissions control who can read, write, or execute files and directories. This guide covers permission concepts, commands, and best practices for securing your system.

---

## 📚 Understanding Permissions

### Permission Types

Linux has three types of permissions:

1. **Read (r)** - Permission to read file contents or list directory contents
2. **Write (w)** - Permission to modify file or create/delete files in directory
3. **Execute (x)** - Permission to run file as program or access directory

### Permission Groups

Permissions are assigned to three groups:

1. **Owner (u)** - The user who owns the file
2. **Group (g)** - Users in the file's group
3. **Others (o)** - All other users

### Permission Notation

**Symbolic Notation:**
```
-rwxr-xr-x
│││││││││└─ Others: execute
││││││││└── Others: no write
│││││││└─── Others: read
││││││└──── Group: execute
│││││└───── Group: no write
││││└────── Group: read
│││└─────── Owner: execute
││└──────── Owner: write
│└───────── Owner: read
└────────── File type (- = file, d = directory, l = link)
```

**Numeric (Octal) Notation:**
```
r = 4 (read)
w = 2 (write)
x = 1 (execute)

Examples:
7 = rwx (4+2+1)
6 = rw- (4+2)
5 = r-x (4+1)
4 = r-- (4)
0 = --- (no permissions)
```

---

## 🔧 chmod - Change File Permissions

### Basic Usage

```bash
chmod [options] mode file
```

### Symbolic Mode

**Syntax:** `chmod [who][operator][permissions] file`

**Who:**
- `u` - User (owner)
- `g` - Group
- `o` - Others
- `a` - All (user, group, and others)

**Operators:**
- `+` - Add permission
- `-` - Remove permission
- `=` - Set exact permission

**Examples:**
```bash
# Add execute permission for owner
chmod u+x script.sh

# Remove write permission for group and others
chmod go-w file.txt

# Set read and write for owner, read for group and others
chmod u=rw,go=r file.txt

# Add execute permission for everyone
chmod a+x program

# Remove all permissions for others
chmod o-rwx sensitive.txt
```

---

### Numeric (Octal) Mode

**Common Permission Sets:**
```bash
chmod 755 script.sh      # rwxr-xr-x (owner: all, group/others: read+execute)
chmod 644 file.txt       # rw-r--r-- (owner: read+write, group/others: read)
chmod 700 private.sh     # rwx------ (owner: all, group/others: none)
chmod 600 secret.txt     # rw------- (owner: read+write, group/others: none)
chmod 777 shared.txt     # rwxrwxrwx (everyone: all) - AVOID THIS!
chmod 400 readonly.txt   # r-------- (owner: read only)
```

**Permission Calculator:**
```
Owner  Group  Others
 rwx    rwx    rwx
 421    421    421

Example: 755
Owner: 7 = 4+2+1 = rwx
Group: 5 = 4+0+1 = r-x
Others: 5 = 4+0+1 = r-x
```

---

### Recursive Permission Changes

```bash
# Change permissions recursively
chmod -R 755 directory/

# Change only directories
find /path -type d -exec chmod 755 {} \;

# Change only files
find /path -type f -exec chmod 644 {} \;
```

---

## 👤 chown - Change File Ownership

### Basic Usage

```bash
chown [options] owner[:group] file
```

### Examples

```bash
# Change owner only
chown username file.txt

# Change owner and group
chown username:groupname file.txt

# Change group only (using colon)
chown :groupname file.txt

# Recursive ownership change
chown -R username:groupname directory/

# Change ownership of symbolic link itself
chown -h username symlink

# Verbose mode
chown -v username file.txt
```

---

## 👥 chgrp - Change Group Ownership

### Basic Usage

```bash
chgrp [options] group file
```

### Examples

```bash
# Change group
chgrp developers project.txt

# Recursive group change
chgrp -R developers project/

# Verbose mode
chgrp -v developers file.txt
```

---

## 🔍 Viewing Permissions

### ls -l - Long Format Listing

```bash
ls -l file.txt
# Output: -rw-r--r-- 1 user group 1234 Jan 5 10:00 file.txt
#         │││││││││  │  │    │     │    │         └─ filename
#         │││││││││  │  │    │     │    └─ modification time
#         │││││││││  │  │    │     └─ file size
#         │││││││││  │  │    └─ group
#         │││││││││  │  └─ owner
#         │││││││││  └─ number of hard links
#         └─────────── permissions
```

### stat - Detailed File Information

```bash
stat file.txt
# Shows detailed information including:
# - Permissions (both symbolic and numeric)
# - Owner and group
# - File size
# - Timestamps (access, modify, change)
# - Inode number
```

---

## 🛡️ Special Permissions

### Setuid (Set User ID)

**Numeric:** 4000  
**Symbolic:** u+s

```bash
# Set setuid
chmod u+s program
chmod 4755 program

# When executed, runs with owner's permissions
# Example: /usr/bin/passwd
```

### Setgid (Set Group ID)

**Numeric:** 2000  
**Symbolic:** g+s

```bash
# Set setgid on file
chmod g+s program
chmod 2755 program

# Set setgid on directory (new files inherit group)
chmod g+s shared_directory/
chmod 2775 shared_directory/
```

### Sticky Bit

**Numeric:** 1000  
**Symbolic:** +t

```bash
# Set sticky bit (only owner can delete files)
chmod +t shared_directory/
chmod 1777 shared_directory/

# Common on /tmp directory
ls -ld /tmp
# drwxrwxrwt (note the 't' at the end)
```

---

## 👥 User and Group Management

### Create User

```bash
# Create new user
sudo useradd newuser

# Create user with home directory
sudo useradd -m newuser

# Create user with specific shell
sudo useradd -m -s /bin/bash newuser

# Set password
sudo passwd newuser
```

### Modify User

```bash
# Add user to group
sudo usermod -aG groupname username

# Add user to multiple groups
sudo usermod -aG group1,group2,group3 username

# Change user's primary group
sudo usermod -g newgroup username

# Change user's home directory
sudo usermod -d /new/home username

# Lock user account
sudo usermod -L username

# Unlock user account
sudo usermod -U username
```

### Delete User

```bash
# Delete user (keep home directory)
sudo userdel username

# Delete user and home directory
sudo userdel -r username
```

---

### Create Group

```bash
# Create new group
sudo groupadd newgroup

# Create group with specific GID
sudo groupadd -g 1500 newgroup
```

### Modify Group

```bash
# Rename group
sudo groupmod -n newname oldname

# Change group GID
sudo groupmod -g 1600 groupname
```

### Delete Group

```bash
# Delete group
sudo groupdel groupname
```

---

## 📋 Common Permission Scenarios

### Web Server Files

```bash
# Web root directory
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Make files readable, directories executable
sudo find /var/www/html -type f -exec chmod 644 {} \;
sudo find /var/www/html -type d -exec chmod 755 {} \;
```

### Shared Project Directory

```bash
# Create shared directory
sudo mkdir /shared/project
sudo chown :developers /shared/project
sudo chmod 2775 /shared/project

# Now all files created inherit 'developers' group
```

### Secure Private Files

```bash
# SSH private key
chmod 600 ~/.ssh/id_rsa

# SSH public key
chmod 644 ~/.ssh/id_rsa.pub

# SSH directory
chmod 700 ~/.ssh

# Configuration files with passwords
chmod 600 config.ini
```

### Executable Scripts

```bash
# Make script executable
chmod +x script.sh
chmod 755 script.sh

# Make script executable for owner only
chmod 700 script.sh
```

---

## 🎯 Best Practices

### Security Guidelines

1. **Principle of Least Privilege**
   - Grant minimum permissions necessary
   - Avoid 777 permissions (world-writable)

2. **Protect Sensitive Files**
   ```bash
   chmod 600 ~/.ssh/id_rsa
   chmod 600 ~/.aws/credentials
   chmod 600 ~/.netrc
   ```

3. **Secure Directories**
   ```bash
   chmod 700 ~/private
   chmod 755 ~/public_html
   ```

4. **Use Groups Effectively**
   - Create groups for teams
   - Use setgid on shared directories
   - Regularly audit group memberships

5. **Regular Audits**
   ```bash
   # Find world-writable files
   find / -type f -perm -002 2>/dev/null
   
   # Find files with setuid
   find / -type f -perm -4000 2>/dev/null
   
   # Find files with no owner
   find / -nouser 2>/dev/null
   ```

---

## 💡 Practical Examples

### Example 1: Set Up Development Environment

```bash
# Create project directory
sudo mkdir /opt/project
sudo chown developer:developers /opt/project
sudo chmod 2775 /opt/project

# Add users to developers group
sudo usermod -aG developers user1
sudo usermod -aG developers user2

# Users need to log out and back in for group changes
```

### Example 2: Secure Web Application

```bash
# Set ownership
sudo chown -R www-data:www-data /var/www/myapp

# Set directory permissions
sudo find /var/www/myapp -type d -exec chmod 755 {} \;

# Set file permissions
sudo find /var/www/myapp -type f -exec chmod 644 {} \;

# Make specific directories writable
sudo chmod 775 /var/www/myapp/uploads
sudo chmod 775 /var/www/myapp/cache
```

### Example 3: Backup Script Permissions

```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
tar -czf /backups/backup-$(date +%Y%m%d).tar.gz /data
EOF

# Set permissions
chmod 700 backup.sh
sudo chown root:root backup.sh

# Only root can read, write, and execute
```

---

## 🔗 Related Topics

- **File Navigation:** `01-Basics-Navigation.md`
- **User Management:** `02-Permissions.md` (this file)
- **System Security:** `../../../CYBERSECURITY/`

---

**Last Updated:** January 5, 2026  
**Status:** ✅ Complete

