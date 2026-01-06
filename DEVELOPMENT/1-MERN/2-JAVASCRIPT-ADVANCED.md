
## 🧠 1. Hoisting

**Hoisting** means variable and function declarations are moved to the top of their scope **during compilation**.

```js
console.log(a); // undefined
var a = 10;

greet(); // works even before declared
function greet() {
  console.log("Hello!");
}
```

✅ `var` is hoisted but **initialized as `undefined`**,  
✅ `let` and `const` are hoisted too, but in a **“temporal dead zone”** (cannot be accessed before declaration).

```js
console.log(b); // ❌ ReferenceError
let b = 5;
```

---

## 🧩 2. Scope

- **Global scope:** available everywhere
    
- **Function scope:** inside a function
    
- **Block scope:** within `{ }` (for `let` and `const`)
    

```js
let globalVar = "Global";

function test() {
  let funcVar = "Function";
  if (true) {
    let blockVar = "Block";
    console.log(globalVar, funcVar, blockVar);
  }
  // console.log(blockVar); ❌
}

test();
```

---

## 🎯 3. Closures

A **closure** gives access to an outer function’s variables **even after the function has returned**.

```js
function outer() {
  let count = 0;
  return function inner() {
    count++;
    console.log(count);
  };
}

const counter = outer();
counter(); // 1
counter(); // 2
counter(); // 3
```

✅ Closure retains `count` in memory even after `outer()` has finished.

**Used in:** data hiding, state management, callbacks.

---

## 🔁 4. Higher-Order Functions

Functions that **take other functions as arguments** or **return functions**.

```js
function higherOrder(fn) {
  fn();
}

higherOrder(() => console.log("I am a callback!"));
```

Example: `map`, `filter`, `reduce` are all higher-order functions.

---

## 🧭 5. The `this` Keyword

`this` refers to **the object that owns the current execution context**.

```js
const user = {
  name: "Yuvaraj",
  showName() {
    console.log(this.name);
  },
};

user.showName(); // Yuvaraj
```

### 👉 In Arrow Functions

Arrow functions don’t have their own `this` — they **inherit from the parent scope**.

```js
const obj = {
  name: "Yuva",
  arrowFn: () => console.log(this.name),
  normalFn: function () { console.log(this.name); }
};

obj.arrowFn();  // undefined
obj.normalFn(); // Yuva
```

---

## ⚙️ 6. Prototype & Inheritance

Every JavaScript object has a **prototype**, from which it can inherit properties.

```js
function Person(name) {
  this.name = name;
}

Person.prototype.greet = function() {
  console.log(`Hi, I'm ${this.name}`);
};

const yuva = new Person("Yuvaraj");
yuva.greet(); // Hi, I'm Yuvaraj
```

✅ `greet()` is shared among all Person instances via the prototype — not copied per object.

---

## 🧩 7. Destructuring + Spread/Rest

```js
const user = { name: "Yuvaraj", age: 22 };
const { name, age } = user;
console.log(name, age);

const arr = [1, 2, 3, 4];
const [a, b, ...rest] = arr;
console.log(rest); // [3,4]
```

---

## 🧵 8. Event Loop & Async Execution

JavaScript is **single-threaded**, but handles async operations using:

- **Call Stack**
    
- **Web APIs**
    
- **Callback Queue**
    
- **Event Loop**
    

```js
console.log("Start");

setTimeout(() => console.log("Timeout"), 0);

Promise.resolve().then(() => console.log("Promise"));

console.log("End");
```

🧩 **Output:**

```
Start
End
Promise
Timeout
```

✅ Promises (microtasks) run before setTimeout (macrotasks).

---

## 🕹️ 9. Callbacks, Promises, Async/Await

### Callback Hell ❌

```js
setTimeout(() => {
  console.log("1");
  setTimeout(() => {
    console.log("2");
  }, 1000);
}, 1000);
```

### Promise ✅

```js
const wait = (msg) => new Promise(res => setTimeout(() => res(msg), 1000));

wait("1").then(console.log).then(() => wait("2")).then(console.log);
```

### Async/Await ✅✅

```js
async function run() {
  console.log(await wait("1"));
  console.log(await wait("2"));
}
run();
```

---

## 🧠 10. Currying

Transforming a function with multiple arguments into **a sequence of functions**, each taking one argument.

```js
function add(a) {
  return function(b) {
    return function(c) {
      return a + b + c;
    };
  };
}

console.log(add(1)(2)(3)); // 6
```

---

## 🪄 11. Debouncing & Throttling (Performance)

Used in **search boxes, scroll events**, etc., to control function execution frequency.

### 👉 Debounce (delays until stop typing)

```js
function debounce(fn, delay) {
  let timer;
  return function(...args) {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

window.addEventListener("resize", debounce(() => {
  console.log("Resized!");
}, 500));
```

---

## ⚡ 12. Deep vs Shallow Copy

```js
const obj1 = { name: "Yuvaraj", info: { city: "Chennai" } };

// Shallow Copy
const shallow = { ...obj1 };
shallow.info.city = "Coimbatore";
console.log(obj1.info.city); // Coimbatore ❌

// Deep Copy
const deep = JSON.parse(JSON.stringify(obj1));
deep.info.city = "Madurai";
console.log(obj1.info.city); // Coimbatore ✅
```

---

## 🧩 13. Generators

Functions that can be **paused and resumed** using `yield`.

```js
function* numbers() {
  yield 1;
  yield 2;
  yield 3;
}

const gen = numbers();
console.log(gen.next().value); // 1
console.log(gen.next().value); // 2
console.log(gen.next().value); // 3
```

---

## 🧮 14. Symbols & Iterators

### 👉 Unique identifiers

```js
const id = Symbol("id");
const obj = { [id]: 123 };
console.log(obj[id]);
```

---

## 🧱 15. Optional Chaining & Nullish Coalescing

```js
const user = { profile: { name: "Yuvaraj" } };

console.log(user?.profile?.name); // Yuvaraj
console.log(user?.age ?? 25); // 25 (default value)
```

---

## ⚙️ 16. Event Delegation

One event listener for multiple child elements.

```html
<ul id="list">
  <li>Apple</li>
  <li>Mango</li>
  <li>Banana</li>
</ul>

<script>
document.getElementById("list").addEventListener("click", (e) => {
  if (e.target.tagName === "LI") {
    console.log(`You clicked ${e.target.textContent}`);
  }
});
</script>
```

---

# ✅ SUMMARY CHEAT SHEET

|Concept|Description|Example|
|---|---|---|
|**Hoisting**|Declarations moved to top|`var`, `function`|
|**Scope**|Block / Function / Global|`let`, `const`|
|**Closure**|Inner function keeps access|`counter()`|
|**Prototype**|Inheritance mechanism|`Person.prototype.greet()`|
|**this**|Refers to current context|`obj.method()`|
|**Event Loop**|Async execution order|`Promise vs setTimeout`|
|**Currying**|Function chaining|`add(1)(2)(3)`|
|**Debounce/Throttle**|Control function calls|Used in events|
|**Generator**|Yield-based iterator|`function*`|
|**Optional Chaining**|Safe property access|`obj?.prop`|

---
