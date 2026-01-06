
# ⚛️ 1. What is React?

> **React.js** is a JavaScript library for building **dynamic, component-based UIs**.  
> It handles the **view layer** of the MERN stack.

🧩 Role in MERN:  
React = **Frontend UI**  
Express + Node = **Backend server**  
MongoDB = **Database**

---

# 🏁 2. Setup React App

Use **Vite** (faster) or **CRA** (Create React App).

### ✅ Using Vite

```bash
npm create vite@latest mern-frontend --template react
cd mern-frontend
npm install
npm run dev
```

Open: **[http://localhost:5173](http://localhost:5173/)**

---

# 📁 3. Folder Structure

```
mern-frontend/
│
├── src/
│   ├── components/
│   │   └── UserList.jsx
│   ├── App.jsx
│   ├── main.jsx
│   └── styles.css
└── package.json
```

---

# ⚙️ 4. Basic Component

### 📄 `App.jsx`

```jsx
function App() {
  return (
    <div>
      <h1>Hello React 🚀</h1>
    </div>
  );
}

export default App;
```

### 📄 `main.jsx`

```jsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.jsx";

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
```

---

# 🧩 5. Components (Reusable UI Blocks)

### 📄 `components/User.jsx`

```jsx
function User(props) {
  return <p>{props.name}</p>;
}

export default User;
```

### 📄 `App.jsx`

```jsx
import User from "./components/User";

function App() {
  return (
    <div>
      <h1>User List</h1>
      <User name="Yuvaraj" />
      <User name="Kumar" />
    </div>
  );
}
```

---

# 🧠 6. State and Events

### 📄 `App.jsx`

```jsx
import { useState } from "react";

function App() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <h1>Counter: {count}</h1>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
    </div>
  );
}

export default App;
```

---

# 🔁 7. useEffect (Side Effects)

### 📄 `App.jsx`

```jsx
import { useState, useEffect } from "react";

function App() {
  const [time, setTime] = useState(new Date().toLocaleTimeString());

  useEffect(() => {
    const timer = setInterval(
      () => setTime(new Date().toLocaleTimeString()),
      1000
    );
    return () => clearInterval(timer); // cleanup
  }, []);

  return <h2>Current Time: {time}</h2>;
}
```

---

# 🧩 8. Props Destructuring & Mapping

### 📄 `UserList.jsx`

```jsx
function UserList({ users }) {
  return (
    <ul>
      {users.map((u, i) => (
        <li key={i}>{u}</li>
      ))}
    </ul>
  );
}

export default UserList;
```

### 📄 `App.jsx`

```jsx
import UserList from "./components/UserList";

function App() {
  const names = ["Yuvaraj", "Ravi", "Kumar"];
  return <UserList users={names} />;
}
```

---

# 🌍 9. Fetch Data from Backend (Axios)

Install Axios:

```bash
npm install axios
```

### 📄 `App.jsx`

```jsx
import { useEffect, useState } from "react";
import axios from "axios";

function App() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    axios.get("http://localhost:5000/api/users")
      .then(res => setUsers(res.data))
      .catch(err => console.error(err));
  }, []);

  return (
    <div>
      <h2>Users from Backend</h2>
      <ul>
        {users.map((u) => (
          <li key={u._id}>{u.name}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
```

✅ Backend (`Express.js`) must be running at **localhost:5000**.

---

# 🧱 10. CRUD UI Example (Connected to Express + MongoDB)

### 📄 `App.jsx`

```jsx
import { useEffect, useState } from "react";
import axios from "axios";

function App() {
  const [users, setUsers] = useState([]);
  const [name, setName] = useState("");

  // Read
  const fetchUsers = async () => {
    const res = await axios.get("http://localhost:5000/api/users");
    setUsers(res.data);
  };

  useEffect(() => { fetchUsers(); }, []);

  // Create
  const addUser = async () => {
    if (!name.trim()) return;
    await axios.post("http://localhost:5000/api/users", { name });
    setName("");
    fetchUsers();
  };

  // Delete
  const deleteUser = async (id) => {
    await axios.delete(`http://localhost:5000/api/users/${id}`);
    fetchUsers();
  };

  return (
    <div>
      <h1>Users CRUD 🧑‍💻</h1>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Enter name"
      />
      <button onClick={addUser}>Add</button>

      <ul>
        {users.map((u) => (
          <li key={u._id}>
            {u.name} <button onClick={() => deleteUser(u._id)}>❌</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
```

✅ Works with the Express API we created earlier!

---

# 🎨 11. Styling (CSS)

### 📄 `src/styles.css`

```css
body {
  font-family: sans-serif;
  background-color: #f9f9f9;
  padding: 20px;
}

button {
  margin-left: 10px;
  background-color: #007bff;
  border: none;
  padding: 5px 10px;
  color: white;
  border-radius: 5px;
}

input {
  padding: 5px;
}
```

Import it:

```jsx
import "./styles.css";
```

---

# 🔄 12. Folder Structure for MERN Integration

```
mern-app/
│
├── backend/
│   ├── models/
│   ├── routes/
│   ├── index.js
│   └── db.js
│
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   └── App.jsx
│   └── package.json
```

In **React frontend**, set the proxy (for development):

### 📄 `frontend/package.json`

```json
"proxy": "http://localhost:5000"
```

Now you can use `/api/users` directly without CORS issues.

---

# 🚀 13. Build for Production

When finished:

```bash
npm run build
```

This creates a `dist/` folder that can be served by your **Express server**.

---

# ✅ Summary

|Concept|Description|
|---|---|
|`Components`|Reusable UI elements|
|`State`|Data that changes in component|
|`Props`|Data passed between components|
|`useEffect`|Perform side effects (API calls, timers)|
|`Axios`|Fetch or send data to backend|
|`CRUD`|Create, Read, Update, Delete UI|
|`Build`|Create optimized production files|

---
