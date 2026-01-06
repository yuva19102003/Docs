We’ll cover **concept → setup → routing → middleware → REST API → MongoDB connection → error handling → deployment basics** — all with **code blocks** and clear explanation.

---

# ⚙️ 1. What is Express.js?

> **Express.js** is a minimal and flexible **Node.js web application framework**  
> used to build **APIs, backend logic, and web servers** easily.

🧩 Role in MERN:  
It acts as the **backend server** — connects the **frontend (React)** with **database (MongoDB)**.

---

# 🧱 2. Setup Project

### Step 1 — Initialize Node.js

```bash
mkdir express-demo
cd express-demo
npm init -y
```

### Step 2 — Install Express

```bash
npm install express
```

---

# 🚀 3. Basic Server Setup

### 📁 `index.js`

```js
// Import express
const express = require("express");

// Initialize app
const app = express();

// Port number
const PORT = 5000;

// Middleware to parse JSON
app.use(express.json());

// Basic route
app.get("/", (req, res) => {
  res.send("Hello from Express Server 🚀");
});

// Start server
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
```

👉 Run it:

```bash
node index.js
```

Visit **[http://localhost:5000](http://localhost:5000/)**

---

# 🛣️ 4. Routing Basics

### 📁 `index.js`

```js
app.get("/users", (req, res) => {
  res.send("Get all users");
});

app.post("/users", (req, res) => {
  res.send("Create new user");
});

app.put("/users/:id", (req, res) => {
  res.send(`Update user ${req.params.id}`);
});

app.delete("/users/:id", (req, res) => {
  res.send(`Delete user ${req.params.id}`);
});
```

✅ You just built a **basic REST API**.

---

# 🧩 5. Middleware

Middlewares are **functions** that process requests before reaching routes.

```js
// Custom middleware example
const logger = (req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next(); // pass control to next handler
};

app.use(logger);
```

Now every request will be logged.

---

# 🧠 6. Request and Response

```js
app.post("/data", (req, res) => {
  const { name, age } = req.body;
  res.json({ message: `Received ${name}, age ${age}` });
});
```

➡️ Send JSON using Postman:

```json
{
  "name": "Yuvaraj",
  "age": 22
}
```

---

# 🧱 7. Express Router (Modular Routes)

### 📁 `routes/userRoutes.js`

```js
const express = require("express");
const router = express.Router();

router.get("/", (req, res) => res.send("All users"));
router.post("/", (req, res) => res.send("User added"));

module.exports = router;
```

### 📁 `index.js`

```js
const userRoutes = require("./routes/userRoutes");
app.use("/api/users", userRoutes);
```

✅ Now visit → `/api/users`

---

# 🍃 8. Connect to MongoDB (with Mongoose)

Install:

```bash
npm install mongoose
```

### 📁 `db.js`

```js
const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    await mongoose.connect("mongodb://localhost:27017/expressdb");
    console.log("✅ MongoDB Connected");
  } catch (err) {
    console.error("❌ DB Connection Failed:", err.message);
  }
};

module.exports = connectDB;
```

### In `index.js`

```js
const connectDB = require("./db");
connectDB();
```

---

# 🧩 9. Model and CRUD Example

### 📁 `models/User.js`

```js
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: String,
  email: String,
  age: Number
});

module.exports = mongoose.model("User", userSchema);
```

### 📁 `routes/userRoutes.js`

```js
const express = require("express");
const router = express.Router();
const User = require("../models/User");

// Create User
router.post("/", async (req, res) => {
  const user = new User(req.body);
  await user.save();
  res.json(user);
});

// Get All Users
router.get("/", async (req, res) => {
  const users = await User.find();
  res.json(users);
});

// Get by ID
router.get("/:id", async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
});

// Update
router.put("/:id", async (req, res) => {
  const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json(user);
});

// Delete
router.delete("/:id", async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  res.json({ message: "User deleted" });
});

module.exports = router;
```

---

# 🧰 10. Error Handling Middleware

```js
// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Something broke!" });
});
```

---

# 🧠 11. Environment Variables (dotenv)

Install:

```bash
npm install dotenv
```

### 📁 `.env`

```
PORT=5000
MONGO_URI=mongodb://localhost:27017/expressdb
```

### Update `index.js`

```js
require("dotenv").config();
const PORT = process.env.PORT || 3000;
```

---

# 🔒 12. CORS (Frontend Connection)

Install:

```bash
npm install cors
```

### In `index.js`

```js
const cors = require("cors");
app.use(cors());
```

Now your React app can make API calls safely.

---

# 🚀 13. Folder Structure

```
express-demo/
│
├── models/
│   └── User.js
│
├── routes/
│   └── userRoutes.js
│
├── db.js
├── index.js
├── .env
└── package.json
```

---

# 🌐 14. Deployment Basics

For production:

```bash
npm install --save-dev nodemon
```

In `package.json`:

```json
"scripts": {
  "start": "node index.js",
  "dev": "nodemon index.js"
}
```

Then:

```bash
npm run dev
```

✅ Deploy on:

- **Render**, **Vercel**, or **Railway** for backend hosting.
    
- MongoDB Atlas for online DB.
    

---

# ✅ Summary

|Component|Role|
|---|---|
|`express`|Framework to handle routes, requests, middleware|
|`mongoose`|ODM for MongoDB|
|`dotenv`|Manage secrets|
|`cors`|Connect with frontend safely|
|`nodemon`|Auto restart server during development|
|Routes|Define API endpoints|
|Models|Define DB schema|

---
