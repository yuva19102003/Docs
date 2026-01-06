
---

# 🌱 1. Variables and Data Types

### 👉 `var`, `let`, `const`

```js
var a = 10;       // function-scoped
let b = 20;       // block-scoped
const c = 30;     // constant

b = 25; // ✅ allowed
// c = 40; ❌ TypeError
```

### 👉 Data Types

```js
let str = "Hello";      // string
let num = 42;           // number
let bool = true;        // boolean
let obj = { name: "Yuvaraj" }; // object
let arr = [1, 2, 3];    // array
let und;                 // undefined
let n = null;            // null
```

---

# 🧮 2. Operators

```js
let a = 5, b = 2;

// Arithmetic
console.log(a + b, a - b, a * b, a / b, a % b);

// Comparison
console.log(a > b, a = b, a ! b);

// Logical
console.log(a > 1 && b < 3);  // AND
console.log(a < 1 || b < 3);  // OR
console.log(!true);           // NOT
```

---

# 🧩 3. Functions

### 👉 Normal Function

```js
function add(x, y) {
  return x + y;
}
console.log(add(5, 3));
```

### 👉 Arrow Function

```js
const multiply = (x, y) => x * y;
console.log(multiply(2, 4));
```

### 👉 Default & Rest Parameters

```js
function greet(name = "Guest") {
  console.log(`Hello, ${name}`);
}

function sum(...nums) {
  return nums.reduce((a, b) => a + b, 0);
}

greet("Yuvaraj"); // Hello, Yuvaraj
console.log(sum(1, 2, 3, 4)); // 10
```

---

# 🔁 4. Conditionals and Loops

```js
let age = 20;
if (age >= 18) console.log("Adult");
else console.log("Minor");

// Loop
for (let i = 1; i <= 3; i++) {
  console.log("Count:", i);
}

// While loop
let n = 0;
while (n < 3) {
  console.log("n =", n);
  n++;
}
```

---

# 🧰 5. Arrays

### 👉 Common Methods

```js
const nums = [1, 2, 3, 4, 5];

console.log(nums.map(n => n * 2));       // [2,4,6,8,10]
console.log(nums.filter(n => n > 2));    // [3,4,5]
console.log(nums.reduce((a, b) => a + b)); // 15
console.log(nums.find(n => n === 3));    // 3
```

---

# 🧱 6. Objects

```js
const user = {
  name: "Yuvaraj",
  age: 22,
  greet() {
    console.log(`Hello, I'm ${this.name}`);
  }
};

user.greet();
console.log(user.age);
```

### 👉 Destructuring

```js
const { name, age } = user;
console.log(name, age);
```

---

# 🎯 7. ES6 Features

### 👉 Template Literals

```js
let role = "Developer";
console.log(`I am a ${role} 🧑‍💻`);
```

### 👉 Spread & Rest

```js
let arr1 = [1, 2];
let arr2 = [...arr1, 3, 4]; // Spread
console.log(arr2);

function logArgs(...args) {
  console.log(args);
}
logArgs("a", "b", "c"); // Rest
```

---

# 🧠 8. Asynchronous JavaScript

### 👉 Callbacks

```js
function fetchData(callback) {
  setTimeout(() => {
    callback("Data loaded ✅");
  }, 1000);
}

fetchData(console.log);
```

### 👉 Promises

```js
const getData = new Promise((resolve) => {
  setTimeout(() => resolve("Promise resolved ✅"), 1000);
});

getData.then(console.log);
```

### 👉 Async / Await

```js
async function load() {
  const data = await getData;
  console.log(data);
}
load();
```

---

# 🌍 9. Fetch API (Promise Example)

```js
fetch("https://jsonplaceholder.typicode.com/users/1")
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => console.log("Error:", err));
```

or with **async/await**:

```js
async function getUser() {
  const res = await fetch("https://jsonplaceholder.typicode.com/users/1");
  const data = await res.json();
  console.log(data.name);
}
getUser();
```

---

# 🧩 10. DOM Manipulation (Browser)

```html
<div id="app"></div>
<button id="btn">Click</button>

<script>
  const app = document.getElementById("app");
  const btn = document.getElementById("btn");

  btn.addEventListener("click", () => {
    app.innerText = "Button Clicked 🚀";
  });
</script>
```

---

# 🧱 11. Classes and OOP

```js
class User {
  constructor(name, role) {
    this.name = name;
    this.role = role;
  }

  greet() {
    console.log(`Hello, I'm ${this.name}, a ${this.role}`);
  }
}

const yuva = new User("Yuvaraj", "Full Stack Dev");
yuva.greet();
```

---

# 📦 12. Modules (ES Modules)

### 👉 Export (file: math.js)

```js
export const add = (a, b) => a + b;
export const sub = (a, b) => a - b;
```

### 👉 Import (file: app.js)

```js
import { add, sub } from './math.js';
console.log(add(5, 2), sub(5, 2));
```

---

# 🧹 13. Error Handling

```js
try {
  let result = riskyFunction(); // not defined
} catch (err) {
  console.error("Error occurred:", err.message);
} finally {
  console.log("Cleanup complete");
}
```

---

# 🧭 14. JSON Basics

```js
const obj = { name: "Yuvaraj", age: 22 };
const json = JSON.stringify(obj);  // Object → JSON string
const parsed = JSON.parse(json);   // JSON → Object

console.log(json);
console.log(parsed.name);
```

---

# 🚀 Summary

|Concept|Key Idea|
|---|---|
|Variables|`var`, `let`, `const`|
|Data Types|string, number, boolean, object, array|
|Functions|normal & arrow|
|Arrays/Objects|`map`, `filter`, destructuring|
|Async|callbacks → promises → async/await|
|DOM|manipulate HTML dynamically|
|Classes|OOP in JS|
|Modules|code reusability (`import` / `export`)|

---
