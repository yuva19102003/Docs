# 🧠 Scenario: Building a Node.js API Project with a Team

You and 2 developers are building:

```
payment-api/
 ├── app.js
 ├── package.json
 └── README.md
```

We’ll go from:

✔ Creating repo
✔ Branching
✔ Conflict
✔ Rebase vs Merge
✔ Undo mistakes
✔ PR flow
✔ Production tagging
✔ Disaster recovery

---

# 1️⃣ What Git Actually Does (Example)

Imagine:

Day 1 → You write login feature
Day 2 → Teammate writes payment feature
Day 3 → You both change same file

Git keeps **snapshots of every version**.

Git was created by Linus Torvalds and powers platforms like GitHub.

---

# 2️⃣ Starting a Real Project

### Step 1 — Create folder

```bash
mkdir payment-api
cd payment-api
git init
```

Now Git creates `.git` folder.

---

# 3️⃣ First Commit (Real Example)

Create `app.js`

```js
console.log("Payment API started");
```

Check status:

```bash
git status
```

It shows:

```
Untracked files:
  app.js
```

Add & commit:

```bash
git add app.js
git commit -m "Initial commit: Setup payment API"
```

👉 What happened internally?

Git created:

* Blob (file content)
* Tree (folder structure)
* Commit (snapshot)

---

# 4️⃣ Connect to GitHub (Real Example)

You create repo in GitHub UI.

Then:

```bash
git remote add origin https://github.com/yuva/payment-api.git
git branch -M main
git push -u origin main
```

Now code is online.

---

# 5️⃣ Real Team Workflow (Feature Branch)

### You are adding Login API

```bash
git checkout -b feature/login
```

Edit `app.js`

```js
console.log("Payment API started");

function login() {
  console.log("User logged in");
}

login();
```

Commit:

```bash
git add .
git commit -m "Add login feature"
git push origin feature/login
```

Now you create a **Pull Request** in GitHub.

---

# 6️⃣ Meanwhile Teammate Changes Same File 😬

Your teammate creates:

```bash
git checkout -b feature/payment
```

They edit `app.js`:

```js
console.log("Payment API started");

function processPayment() {
  console.log("Payment processed");
}

processPayment();
```

They merge into `main`.

---

# 7️⃣ Now You Try To Merge 😱 (Conflict Example)

You:

```bash
git checkout main
git pull
git merge feature/login
```

Git says:

```
CONFLICT (content): Merge conflict in app.js
```

File becomes:

```js
console.log("Payment API started");

<<<<<<< HEAD
function processPayment() {
  console.log("Payment processed");
}
=======
function login() {
  console.log("User logged in");
}
>>>>>>> feature/login
```

---

# 8️⃣ How You Fix Conflict (Real Fix)

You edit file manually:

```js
console.log("Payment API started");

function login() {
  console.log("User logged in");
}

function processPayment() {
  console.log("Payment processed");
}

login();
processPayment();
```

Then:

```bash
git add app.js
git commit -m "Resolve merge conflict"
```

✅ Conflict resolved.

---

# 9️⃣ Merge vs Rebase (With Example)

## Merge

Creates extra commit:

```
Merge branch 'feature/login'
```

History looks like:

```
      feature/login
         \
main ---- M
```

---

## Rebase (Cleaner)

Instead:

```bash
git checkout feature/login
git rebase main
```

Now history becomes linear:

```
main ---- login commit
```

✔ Cleaner history
⚠ Don’t rebase shared branches

---

# 🔟 Undo Mistakes (Real Situations)

---

## ❌ Situation 1: Wrong Commit Message

```bash
git commit --amend -m "Correct message"
```

---

## ❌ Situation 2: Accidentally Committed .env

```bash
git rm --cached .env
echo ".env" >> .gitignore
git commit -m "Remove .env from tracking"
```

---

## ❌ Situation 3: Delete Last Commit But Keep Code

```bash
git reset --soft HEAD~1
```

---

## ❌ Situation 4: Completely Delete Last Commit

```bash
git reset --hard HEAD~1
```

---

# 1️⃣1️⃣ Recover Deleted Branch (Disaster Recovery)

You deleted branch accidentally:

```bash
git branch -D feature/login
```

Recover:

```bash
git reflog
git checkout -b recovered <commit-id>
```

Git **never truly forgets immediately**.

---

# 1️⃣2️⃣ Stash Example (Real Scenario)

You are coding but boss says switch branch urgently.

```bash
git stash
git checkout main
```

Later:

```bash
git checkout feature/login
git stash pop
```

Your work returns.

---

# 1️⃣3️⃣ Production Release Example

After testing:

```bash
git tag v1.0
git push origin v1.0
```

Now CI/CD pipeline triggers Docker build.

Example:

```bash
docker build -t payment-api:v1.0 .
```

---

# 1️⃣4️⃣ Real DevOps Flow (Enterprise Level)

Typical company flow:

1. Developer → feature branch
2. PR → code review
3. CI runs tests
4. Merge to main
5. Tag release
6. Docker build
7. Deploy via Terraform
8. Monitor

---

# 1️⃣5️⃣ Advanced Real Scenario: Squash Commits

You made 5 small commits:

```
fix bug
fix typo
update console
remove space
final fix
```

Before PR:

```bash
git rebase -i HEAD~5
```

Change to:

```
pick first
squash others
```

Now only 1 clean commit.

---

# 1️⃣6️⃣ Real Multi-Developer Collaboration Flow

Team uses:

### GitHub Flow (Most Modern Teams)

* main (production)
* feature branches
* PR review
* CI pipeline

Used widely in GitHub based teams.

---

# 1️⃣7️⃣ Git Internal Storage (Advanced Understanding)

Inside:

```
.git/
```

You’ll find:

* objects/
* refs/
* HEAD

Git stores everything as hashed objects (SHA).

---

# 1️⃣8️⃣ Real Interview Level Questions

### Q: Difference between revert and reset?

* `reset` → rewrites history
* `revert` → creates new undo commit

---

### Q: Detached HEAD?

When you checkout specific commit:

```bash
git checkout 3e4f5a
```

You are not on branch.

---

# 🎯 Complete Real Project Flow Summary

```
git clone
git checkout -b feature/api
# code
git add .
git commit -m "Add API"
git push origin feature/api
# create PR
# merge
git checkout main
git pull
git tag v1.1
git push origin v1.1
```

---
