# 📌 1️⃣ What is Git?

**Git** is a distributed version control system used to track code changes and collaborate.

* Created by Linus Torvalds
* Official site: Git
* Popular hosting: GitHub, GitLab, Bitbucket

---

# 📌 2️⃣ Installation

### Windows

Download from git-scm.com

### Ubuntu

```bash
sudo apt update
sudo apt install git -y
```

### Verify

```bash
git --version
```

---

# 📌 3️⃣ Initial Setup (VERY IMPORTANT)

```bash
git config --global user.name "YuvaDevOps"
git config --global user.email "yuvaraj.k@raidenlabs.io"
```

Check:

```bash
git config --list
```

---

# 📌 4️⃣ Core Git Concepts

| Concept           | Meaning                      |
| ----------------- | ---------------------------- |
| Working Directory | Your project files           |
| Staging Area      | Prepared changes             |
| Repository (.git) | Git database                 |
| Commit            | Snapshot                     |
| Branch            | Separate line of development |
| Remote            | Cloud repo                   |

---

# 📌 5️⃣ Basic Workflow (Daily Use)

## Step 1: Initialize Repo

```bash
git init
```

## Step 2: Add Files

```bash
git add .
```

## Step 3: Commit

```bash
git commit -m "Initial commit"
```

## Step 4: Check Status

```bash
git status
```

## Step 5: View History

```bash
git log --oneline --graph
```

---

# 📌 6️⃣ Connect to Remote (GitHub Example)

```bash
git remote add origin https://github.com/username/repo.git
git branch -M main
git push -u origin main
```

---

# 📌 7️⃣ Branching (Very Important for Real Projects)

## Create Branch

```bash
git checkout -b feature/login
```

## Switch Branch

```bash
git checkout main
```

## Merge Branch

```bash
git merge feature/login
```

---

# 📌 8️⃣ Merge Conflicts (Most Common Interview Question)

When two developers change same lines.

### Resolve:

1. Open file
2. Fix conflict
3. Add again

```bash
git add .
git commit
```

---

# 📌 9️⃣ Pull & Fetch

```bash
git pull origin main
```

Better way:

```bash
git fetch
git merge origin/main
```

---

# 📌 🔟 Rebase (Advanced)

Rebase keeps history clean.

```bash
git checkout feature
git rebase main
```

⚠️ Never rebase shared branch.

---

# 📌 11️⃣ Stash (Save Work Temporarily)

```bash
git stash
git stash list
git stash apply
git stash pop
```

---

# 📌 12️⃣ Undo Scenarios (VERY IMPORTANT)

### Undo last commit (keep changes)

```bash
git reset --soft HEAD~1
```

### Undo and delete changes

```bash
git reset --hard HEAD~1
```

### Restore file

```bash
git restore file.txt
```

---

# 📌 13️⃣ Cherry Pick

Take commit from another branch:

```bash
git cherry-pick <commit-id>
```

---

# 📌 14️⃣ Tagging (Release Versioning)

```bash
git tag v1.0
git push origin v1.0
```

---

# 📌 15️⃣ Git Workflow Models

## 1️⃣ Git Flow

* main
* develop
* feature/*
* release/*
* hotfix/*

## 2️⃣ GitHub Flow

* main
* feature branches

Most modern teams use **GitHub Flow**.

---

# 📌 16️⃣ Working with Forks

1. Fork repo
2. Clone fork
3. Add upstream

```bash
git remote add upstream https://github.com/original/repo.git
git fetch upstream
git merge upstream/main
```

---

# 📌 17️⃣ Submodules

Add another repo inside project:

```bash
git submodule add https://github.com/user/lib.git
```

Update:

```bash
git submodule update --init --recursive
```

---

# 📌 18️⃣ Large Files (Git LFS)

```bash
git lfs install
git lfs track "*.zip"
```

---

# 📌 19️⃣ Fixing Mistakes & Recovery

### Deleted branch?

```bash
git reflog
git checkout -b recovered <commit-id>
```

### Remove remote branch

```bash
git push origin --delete feature/login
```

---

# 📌 20️⃣ DevOps + CI/CD Usage

### In GitHub Actions

```yaml
- uses: actions/checkout@v4
```

### Docker build from repo

```bash
docker build -t app:v1 .
```

### Tag version automatically

```bash
git tag v1.1
git push origin v1.1
```

---

# 📌 21️⃣ Real World Scenarios (Important)

### 🔥 Scenario 1: Force push?

```bash
git push --force
```

⚠️ Dangerous. Avoid on shared branches.

---

### 🔥 Scenario 2: Remove sensitive file

```bash
git rm --cached .env
```

Add to `.gitignore`

---

### 🔥 Scenario 3: Rename branch

```bash
git branch -m old-name new-name
```

---

### 🔥 Scenario 4: Squash commits

```bash
git rebase -i HEAD~3
```

---

# 📌 22️⃣ .gitignore Example

```
node_modules/
.env
dist/
*.log
```

---

# 📌 23️⃣ Git Best Practices

✔ Small commits
✔ Meaningful messages
✔ Pull before push
✔ Never commit secrets
✔ Use feature branches
✔ Protect main branch

---

# 📌 24️⃣ Interview Questions

* Difference between merge and rebase?
* What is detached HEAD?
* What is git reflog?
* Explain git stash internally?
* How git stores objects? (Blob, Tree, Commit)

---

# 📌 25️⃣ Internal Architecture (Deep Level)

Git stores objects in:

```
.git/objects
```

Types:

* Blob
* Tree
* Commit
* Tag

Git uses SHA-1 hash.

---

# 📌 26️⃣ Advanced Commands

```bash
git bisect
git blame
git clean -fd
git revert
git worktree
```

---

# 📌 27️⃣ Enterprise Workflow (DevOps Engineer Level)

For your DevOps background:

1. Feature branch
2. PR
3. Code review
4. CI pipeline
5. Merge
6. Auto tag
7. Docker build
8. Deploy via Terraform

---

# 📌 28️⃣ Complete Real Project Flow

```bash
git clone repo
git checkout -b feature/payment
# code
git add .
git commit -m "Add payment API"
git push origin feature/payment
# create PR
# merge after review
git checkout main
git pull
```

---

# 🎯 Final Summary

If you master:

* Branching
* Rebase
* Conflict resolution
* Reflog recovery
* CI integration
* Tagging strategy
* Git internals

👉 You are **production-ready Git user**

---
