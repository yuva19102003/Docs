# Git - Version Control System

## Overview
Git is a distributed version control system that tracks changes in source code during software development. It enables multiple developers to work together on projects, manage code history, and collaborate efficiently.

---

## What is Git?

**Git** is a free and open-source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.

### Key Benefits
- ✅ **Distributed** - Every developer has full project history
- ✅ **Fast** - Most operations are local
- ✅ **Branching** - Lightweight and powerful branching
- ✅ **Collaboration** - Multiple developers can work simultaneously
- ✅ **History** - Complete change history and tracking
- ✅ **Integrity** - Cryptographic integrity of code
- ✅ **Free** - Open-source and widely adopted

### Git vs Other VCS

| Feature | Git | SVN | Mercurial |
|---------|-----|-----|-----------|
| **Type** | Distributed | Centralized | Distributed |
| **Speed** | Very Fast | Slower | Fast |
| **Branching** | Excellent | Limited | Good |
| **Offline Work** | Yes | No | Yes |
| **Learning Curve** | Moderate | Easy | Easy |
| **Popularity** | Very High | Medium | Low |

---

## Learning Path

### Beginner Level
1. **[Git Fundamentals](0-Git-Fundamentals.md)** - Start here
   - What is Git and version control
   - Key concepts (repo, branch, commit, push/pull)
   - Basic workflow diagrams
   - Essential commands reference table

2. **[Git Commands](1-Git-Commands.md)** - Command reference
   - Setting up repositories
   - Basic workflow commands
   - Branching and merging
   - Remote repositories
   - Viewing history
   - Undoing changes
   - Stashing and tagging
   - Complete workflow examples

### Intermediate Level
3. **[GitHub Token Setup](2-GitHub-Token-Setup.md)**
   - Personal access tokens
   - Environment variable configuration
   - Secure authentication
   - Linux/Mac setup

---

## Quick Reference

### Essential Git Commands

#### Repository Setup
```bash
# Initialize new repository
git init

# Clone existing repository
git clone https://github.com/user/repo.git

# Check repository status
git status
```

#### Basic Workflow
```bash
# Add files to staging
git add filename
git add .                    # Add all changes

# Commit changes
git commit -m "Commit message"

# Push to remote
git push origin main

# Pull from remote
git pull origin main
```

#### Branching
```bash
# Create new branch
git branch feature-branch

# Switch to branch
git checkout feature-branch

# Create and switch (shortcut)
git checkout -b feature-branch

# List branches
git branch                   # Local branches
git branch -a                # All branches

# Delete branch
git branch -d feature-branch
```

#### Merging
```bash
# Merge branch into current
git merge feature-branch

# Abort merge (if conflicts)
git merge --abort
```

#### Remote Repositories
```bash
# Add remote
git remote add origin https://github.com/user/repo.git

# View remotes
git remote -v

# Change remote URL
git remote set-url origin https://github.com/user/new-repo.git

# Fetch changes
git fetch origin

# Pull changes
git pull origin main
```

#### History and Logs
```bash
# View commit history
git log

# Compact history
git log --oneline

# Graph view
git log --graph --oneline --all

# Show specific commit
git show commit-hash
```

#### Undoing Changes
```bash
# Unstage file
git reset HEAD filename

# Discard changes in file
git checkout -- filename

# Revert commit (creates new commit)
git revert commit-hash

# Reset to previous commit
git reset --hard commit-hash
```

#### Stashing
```bash
# Stash changes
git stash

# List stashes
git stash list

# Apply stash
git stash apply

# Apply and remove stash
git stash pop

# Clear all stashes
git stash clear
```

---

## Git Workflow

### Basic Workflow
```
┌─────────────┐
│ Working Dir │  (Your files)
└──────┬──────┘
       │ git add
       ▼
┌─────────────┐
│ Staging Area│  (Prepared changes)
└──────┬──────┘
       │ git commit
       ▼
┌─────────────┐
│ Local Repo  │  (Committed history)
└──────┬──────┘
       │ git push
       ▼
┌─────────────┐
│ Remote Repo │  (GitHub, GitLab, etc.)
└─────────────┘
```

### Feature Branch Workflow
```
main branch:     ─────●─────●─────●─────●─────
                       │           │
feature branch:        └─●─●─●─────┘
                        (merge)
```

### Typical Development Flow
1. **Clone repository** - `git clone <url>`
2. **Create feature branch** - `git checkout -b feature-name`
3. **Make changes** - Edit files
4. **Stage changes** - `git add .`
5. **Commit changes** - `git commit -m "message"`
6. **Push branch** - `git push origin feature-name`
7. **Create Pull Request** - On GitHub/GitLab
8. **Code Review** - Team reviews changes
9. **Merge to main** - After approval
10. **Delete feature branch** - Clean up

---

## Git Concepts

### Repository (Repo)
A directory containing your project files and Git's version history.

**Types:**
- **Local Repository** - On your computer
- **Remote Repository** - On GitHub, GitLab, Bitbucket

### Commit
A snapshot of your project at a specific point in time.

**Good commit message:**
```bash
git commit -m "Add user authentication feature"
```

**Bad commit message:**
```bash
git commit -m "changes"
```

### Branch
An independent line of development.

**Common branches:**
- `main` / `master` - Production code
- `develop` - Development code
- `feature/*` - New features
- `hotfix/*` - Urgent fixes
- `release/*` - Release preparation

### Merge
Combining changes from different branches.

**Types:**
- **Fast-forward** - Linear history
- **Three-way merge** - Creates merge commit
- **Squash merge** - Combines commits into one

### Rebase
Reapplying commits on top of another base.

```bash
# Rebase feature branch onto main
git checkout feature-branch
git rebase main
```

**When to use:**
- Clean up commit history
- Keep linear history
- Before merging feature branch

**When NOT to use:**
- On public/shared branches
- After pushing to remote

### Stash
Temporarily save uncommitted changes.

**Use cases:**
- Switch branches without committing
- Pull latest changes
- Test something quickly

---

## Common Scenarios

### Scenario 1: Start New Feature
```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/user-login

# Make changes and commit
git add .
git commit -m "Add login form"

# Push to remote
git push origin feature/user-login
```

### Scenario 2: Fix Merge Conflicts
```bash
# Try to merge
git merge feature-branch
# CONFLICT (content): Merge conflict in file.txt

# View conflicts
git status

# Edit conflicted files (remove conflict markers)
# <<<<<<< HEAD
# =======
# >>>>>>> feature-branch

# Mark as resolved
git add file.txt

# Complete merge
git commit -m "Resolve merge conflicts"
```

### Scenario 3: Undo Last Commit
```bash
# Keep changes, undo commit
git reset --soft HEAD~1

# Discard changes, undo commit
git reset --hard HEAD~1

# Create new commit that undoes changes
git revert HEAD
```

### Scenario 4: Update Fork
```bash
# Add upstream remote
git remote add upstream https://github.com/original/repo.git

# Fetch upstream changes
git fetch upstream

# Merge upstream main into your main
git checkout main
git merge upstream/main

# Push to your fork
git push origin main
```

### Scenario 5: Cherry-pick Commit
```bash
# Apply specific commit from another branch
git cherry-pick commit-hash

# Cherry-pick multiple commits
git cherry-pick commit1 commit2 commit3
```

---

## Best Practices

### Commit Messages
- ✅ Use present tense ("Add feature" not "Added feature")
- ✅ Be descriptive but concise
- ✅ Reference issue numbers when applicable
- ✅ Use conventional commits format

**Conventional Commits:**
```
feat: Add user authentication
fix: Resolve login bug
docs: Update README
style: Format code
refactor: Restructure auth module
test: Add login tests
chore: Update dependencies
```

### Branching Strategy
- ✅ Use descriptive branch names
- ✅ Follow naming conventions (`feature/`, `fix/`, `hotfix/`)
- ✅ Keep branches short-lived
- ✅ Delete merged branches
- ✅ Protect main/production branches

### Workflow
- ✅ Commit often, push regularly
- ✅ Pull before pushing
- ✅ Review changes before committing
- ✅ Use `.gitignore` for unwanted files
- ✅ Never commit secrets or credentials
- ✅ Write meaningful commit messages
- ✅ Test before committing

### Collaboration
- ✅ Use Pull Requests for code review
- ✅ Keep PRs small and focused
- ✅ Respond to review comments
- ✅ Update branch before merging
- ✅ Squash commits when appropriate

---

## .gitignore

### Purpose
Tells Git which files to ignore and not track.

### Common Patterns
```gitignore
# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
*.exe
*.dll

# Environment files
.env
.env.local

# IDE files
.vscode/
.idea/
*.swp

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Temporary files
*.tmp
*.temp
```

### Create .gitignore
```bash
# Create file
touch .gitignore

# Add patterns
echo "node_modules/" >> .gitignore
echo ".env" >> .gitignore

# Commit
git add .gitignore
git commit -m "Add .gitignore"
```

---

## GitHub Integration

### Personal Access Tokens
For HTTPS authentication with GitHub.

**Create token:**
1. GitHub Settings → Developer settings → Personal access tokens
2. Generate new token
3. Select scopes (repo, workflow, etc.)
4. Copy token (shown once!)

**Use token:**
```bash
# Clone with token
git clone https://TOKEN@github.com/user/repo.git

# Set remote with token
git remote set-url origin https://TOKEN@github.com/user/repo.git

# Or use environment variable (see 2-GitHub-Token-Setup.md)
```

### SSH Keys
Alternative to tokens for authentication.

**Generate SSH key:**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Add to GitHub:**
1. Copy public key: `cat ~/.ssh/id_ed25519.pub`
2. GitHub Settings → SSH and GPG keys → New SSH key
3. Paste key and save

**Clone with SSH:**
```bash
git clone git@github.com:user/repo.git
```

---

## Troubleshooting

### Problem: Merge Conflicts
```bash
# View conflicted files
git status

# Edit files to resolve conflicts
# Remove conflict markers: <<<<<<<, =======, >>>>>>>

# Mark as resolved
git add conflicted-file.txt

# Complete merge
git commit
```

### Problem: Accidentally Committed to Wrong Branch
```bash
# Undo commit (keep changes)
git reset --soft HEAD~1

# Switch to correct branch
git checkout correct-branch

# Commit changes
git add .
git commit -m "Correct commit message"
```

### Problem: Need to Undo Push
```bash
# Revert commit (safe, creates new commit)
git revert HEAD
git push origin main

# Force push (dangerous, rewrites history)
git reset --hard HEAD~1
git push --force origin main
```

### Problem: Detached HEAD State
```bash
# Create branch from current state
git checkout -b new-branch-name

# Or discard changes and return to branch
git checkout main
```

### Problem: Large File Committed
```bash
# Remove from history (use BFG or git-filter-branch)
# Or use Git LFS for large files

# Install Git LFS
git lfs install

# Track large files
git lfs track "*.psd"
git add .gitattributes
```

---

## Advanced Topics

### Git Hooks
Scripts that run automatically on Git events.

**Common hooks:**
- `pre-commit` - Run before commit
- `pre-push` - Run before push
- `post-merge` - Run after merge

**Example pre-commit hook:**
```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run tests
npm test

# Run linter
npm run lint
```

### Git Submodules
Include other Git repositories within your repository.

```bash
# Add submodule
git submodule add https://github.com/user/lib.git libs/lib

# Clone repo with submodules
git clone --recursive https://github.com/user/repo.git

# Update submodules
git submodule update --remote
```

### Git Bisect
Binary search to find which commit introduced a bug.

```bash
# Start bisect
git bisect start

# Mark current as bad
git bisect bad

# Mark known good commit
git bisect good commit-hash

# Git will checkout commits for testing
# Mark each as good or bad
git bisect good
git bisect bad

# When found, reset
git bisect reset
```

---

## Tools and Resources

### GUI Clients
- **GitHub Desktop** - Simple, beginner-friendly
- **GitKraken** - Powerful, visual
- **Sourcetree** - Free, feature-rich
- **Tower** - Professional, paid

### Command Line Tools
- **tig** - Text-mode interface
- **lazygit** - Terminal UI
- **git-extras** - Additional commands

### Learning Resources
- [Official Git Documentation](https://git-scm.com/doc)
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [GitHub Learning Lab](https://lab.github.com/)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)

---

## Directory Structure

```
GIT/
├── README.md                    # This file
├── 0-Git-Fundamentals.md        # Core concepts and basics
├── 1-Git-Commands.md            # Complete command reference
├── 2-GitHub-Token-Setup.md      # Authentication setup
├── image.png                    # Git workflow diagram
└── image 1.png                  # Git commands diagram
```

---

## Related Topics
- [DevOps Core](../README.md) - Main documentation
- [CI/CD](../CICD/) - Continuous integration with Git
- [Development](../../DEVELOPMENT/) - Development workflows

---

**Last Updated:** January 2026
**Maintained by:** DevOps Documentation Team
