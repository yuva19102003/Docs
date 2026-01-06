
# ⚛️ 1. React Uses JSX (HTML in JavaScript)

> JSX = **JavaScript XML** — looks like HTML but runs in JS.

Example 👇

```jsx
function App() {
  const name = "Yuvaraj";
  return (
    <div>
      <h1>Hello, {name} 👋</h1>
      <p>Welcome to React!</p>
    </div>
  );
}

export default App;
```

✅ JSX rules:

- Must **return one root element**.
    
- Use **`className`** instead of `class`.
    
- Use **camelCase** for attributes (`onClick`, `tabIndex`).
    

---

# 🧱 2. HTML Structure in React

You can use normal HTML tags inside components.

```jsx
function Profile() {
  return (
    <div>
      <h2>My Profile</h2>
      <img src="/avatar.png" alt="Avatar" />
      <p>I’m a Full Stack Developer</p>
      <a href="https://yuvarajk.netlify.app">Visit my portfolio</a>
    </div>
  );
}
```

---

# 🎨 3. Basic CSS File Styling

### 📄 `App.css`

```css
body {
  background-color: #f5f5f5;
  font-family: 'Poppins', sans-serif;
}

.container {
  background: white;
  padding: 20px;
  margin: 40px auto;
  width: 300px;
  text-align: center;
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}
```

### 📄 `App.jsx`

```jsx
import "./App.css";

function App() {
  return (
    <div className="container">
      <h1>Hello React CSS 🎨</h1>
      <p>This is styled using external CSS.</p>
    </div>
  );
}

export default App;
```

---

# 🪄 4. Inline Styling

```jsx
function App() {
  const style = {
    backgroundColor: "#282c34",
    color: "white",
    padding: "20px",
    borderRadius: "10px",
  };

  return (
    <div style={style}>
      <h1>Inline Style Example 💅</h1>
    </div>
  );
}
```

✅ Use **camelCase** properties (`backgroundColor` not `background-color`).

---

# 📦 5. CSS Modules (Scoped CSS)

> Prevents class name conflicts between components.

### 📄 `Button.module.css`

```css
.btn {
  background-color: #007bff;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.btn:hover {
  background-color: #0056b3;
}
```

### 📄 `Button.jsx`

```jsx
import styles from "./Button.module.css";

function Button({ text }) {
  return <button className={styles.btn}>{text}</button>;
}

export default Button;
```

---

# 🧩 6. Conditional Styling

```jsx
function Status({ active }) {
  return (
    <p style={{ color: active ? "green" : "red" }}>
      {active ? "Active" : "Inactive"}
    </p>
  );
}
```

---

# 🌈 7. Tailwind CSS (Modern Utility Framework)

Install Tailwind (if using **Vite**):

```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 📄 `tailwind.config.js`

```js
content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
```

### 📄 `index.css`

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

Now use Tailwind classes 👇

```jsx
function App() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
      <h1 className="text-3xl font-bold text-blue-600">Hello Tailwind 🚀</h1>
      <button className="bg-blue-500 text-white px-4 py-2 rounded-lg mt-4 hover:bg-blue-600">
        Click Me
      </button>
    </div>
  );
}
```

✅ Tailwind = Fast, responsive, and great for React UIs.

---

# 💅 8. Styled Components (CSS in JS)

Install:

```bash
npm install styled-components
```

### 📄 `App.jsx`

```jsx
import styled from "styled-components";

const Button = styled.button`
  background: #ff007f;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 8px;
  cursor: pointer;

  &:hover {
    background: #d6006b;
  }
`;

function App() {
  return (
    <div>
      <h1>Styled Components Example 💅</h1>
      <Button>Click Me</Button>
    </div>
  );
}

export default App;
```

✅ Benefit: scoped, reusable, and dynamic styles directly in JS.

---

# 🧭 9. Responsive Design Example

```jsx
import "./App.css";

function App() {
  return (
    <div className="card">
      <h2>React Responsive Card 📱</h2>
      <p>This adjusts automatically on different screens.</p>
    </div>
  );
}
```

### 📄 `App.css`

```css
.card {
  width: 60%;
  margin: auto;
  padding: 20px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

@media (max-width: 600px) {
  .card {
    width: 90%;
    background: #f0f0f0;
  }
}
```

---

# 🧠 10. Summary

|Method|Description|Use Case|
|---|---|---|
|**External CSS**|Import `.css` file|General/global styles|
|**Inline Style**|Object in JSX|Dynamic one-off styles|
|**CSS Modules**|Scoped CSS|Large apps, avoid conflicts|
|**Tailwind**|Utility classes|Fast & modern UI|
|**Styled Components**|CSS in JS|Dynamic styling & theming|

---

# ✅ Example Combination (Best Practice)

```jsx
import "./App.css";
import styled from "styled-components";

const Btn = styled.button`
  background-color: teal;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
`;

function App() {
  return (
    <div className="container">
      <h1 className="title">React Styling Master 🌈</h1>
      <Btn>Styled Component</Btn>
    </div>
  );
}

export default App;
```

### 📄 `App.css`

```css
.container {
  text-align: center;
  margin-top: 40px;
}

.title {
  color: #007bff;
  font-size: 2rem;
}
```

---
