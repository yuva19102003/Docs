
## 🧠 1. What is MongoDB?

- **NoSQL (document-oriented)** database
    
- Stores data as **JSON-like documents** (BSON format)
    
- Very flexible → no strict schema
    
- Perfect for JavaScript/Node.js (data in same JSON format)
    

### Example Document

```json
{
  "_id": "672b9f3...",
  "name": "Yuvaraj",
  "age": 22,
  "skills": ["Node", "React", "AWS"]
}
```

---

## ⚙️ 2. Basic Commands (Mongo Shell)

### 👉 Show Databases

```bash
show dbs
```

### 👉 Create / Use a Database

```bash
use myDB
```

### 👉 Show Collections

```bash
show collections
```

---

## 🗄️ 3. CRUD Operations

### ➕ Create

```bash
db.users.insertOne({ name: "Yuvaraj", age: 22, city: "Chennai" })

db.users.insertMany([
  { name: "Arun", age: 25 },
  { name: "Keerthi", age: 23 }
])
```

---

### 🔍 Read

```bash
db.users.find()                     // all users
db.users.find({ age: 22 })          // filter
db.users.find({ age: { $gt: 20 } }) // condition
db.users.find({}, { name: 1 })      // projection (only name)
```

---

### ✏️ Update

```bash
db.users.updateOne(
  { name: "Yuvaraj" },
  { $set: { city: "Bangalore" } }
)

db.users.updateMany(
  { age: { $gt: 21 } },
  { $inc: { age: 1 } }
)
```

---

### ❌ Delete

```bash
db.users.deleteOne({ name: "Arun" })
db.users.deleteMany({ age: { $lt: 20 } })
```

---

## 🧩 4. Query Operators

|Operator|Description|Example|
|---|---|---|
|`$gt`, `$lt`, `$gte`, `$lte`|Greater/Less than|`{ age: { $gt: 20 } }`|
|`$in`, `$nin`|In/Not in|`{ city: { $in: ["Chennai","Delhi"] } }`|
|`$or`, `$and`|Logical|`{ $or: [{ age: 22 }, { city: "Delhi" }] }`|
|`$exists`|Check field presence|`{ city: { $exists: true } }`|
|`$regex`|Pattern matching|`{ name: /yuva/i }`|

---

## 📦 5. Indexing (for performance)

Indexes speed up queries by avoiding full collection scans.

```bash
db.users.createIndex({ name: 1 }) // ascending
db.users.createIndex({ age: -1 }) // descending
db.users.getIndexes()
```

✅ Always index frequently searched or sorted fields.

---

## 🧮 6. Aggregation Framework

Used for advanced data analysis and transformations.

### 👉 Basic Example

```bash
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$customer", totalAmount: { $sum: "$amount" } } },
  { $sort: { totalAmount: -1 } }
])
```

### 👉 Common Aggregation Stages

|Stage|Purpose|
|---|---|
|`$match`|Filter documents|
|`$group`|Group data and aggregate|
|`$sort`|Sort results|
|`$project`|Include/rename fields|
|`$limit`|Limit number of docs|
|`$lookup`|Join with another collection|

---

## 🔗 7. Relationships (Referencing vs Embedding)

### 👉 Embedding (Nested documents)

Good for small, related data.

```js
{
  name: "Yuvaraj",
  address: { city: "Chennai", pincode: 600001 }
}
```

### 👉 Referencing (Using ObjectId)

Good for large or reusable data.

```js
// users
{ _id: ObjectId("u1"), name: "Yuvaraj" }

// posts
{ title: "Hello", userId: ObjectId("u1") }
```

You can join them using `$lookup`:

```bash
db.posts.aggregate([
  { 
    $lookup: {
      from: "users",
      localField: "userId",
      foreignField: "_id",
      as: "userDetails"
    }
  }
])
```

---

## ⚙️ 8. Using MongoDB with Node.js (Mongoose)

Install dependencies:

```bash
npm install mongoose
```

### 👉 Connect to MongoDB

```js
const mongoose = require("mongoose");

mongoose.connect("mongodb://localhost:27017/mernDB")
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));
```

---

### 👉 Define Schema & Model

```js
const userSchema = new mongoose.Schema({
  name: String,
  age: Number,
  city: String
});

const User = mongoose.model("User", userSchema);
```

---

### 👉 CRUD in Mongoose

#### Create

```js
await User.create({ name: "Yuvaraj", age: 22, city: "Chennai" });
```

#### Read

```js
const users = await User.find({ age: { $gte: 20 } });
console.log(users);
```

#### Update

```js
await User.updateOne({ name: "Yuvaraj" }, { $set: { city: "Bangalore" } });
```

#### Delete

```js
await User.deleteOne({ name: "Yuvaraj" });
```

---

## 🔄 9. Validation & Defaults (in Schema)

```js
const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, min: 1 },
  inStock: { type: Boolean, default: true }
});
```

---

## 🔐 10. Indexing in Mongoose

```js
userSchema.index({ name: 1 });
```

---

## 📊 11. Pagination

```js
const page = 2;
const limit = 5;
const users = await User.find()
  .skip((page - 1) * limit)
  .limit(limit);
```

---

## 🧠 12. Aggregation in Mongoose

```js
const result = await User.aggregate([
  { $group: { _id: "$city", count: { $sum: 1 } } }
]);
console.log(result);
```

---

## 💾 13. Relationships in Mongoose (Population)

### 👉 Referencing Example

```js
const postSchema = new mongoose.Schema({
  title: String,
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
});

const Post = mongoose.model("Post", postSchema);

// Fetch posts with user details
const posts = await Post.find().populate("user");
```

---

## 🚀 14. Mongoose Middleware (Hooks)

```js
userSchema.pre("save", function(next) {
  console.log("Saving user:", this.name);
  next();
});
```

---

## 🧰 15. Backup & Restore

```bash
# Backup
mongodump --db=myDB --out=backup/

# Restore
mongorestore --db=myDB backup/myDB
```

---

## 🧾 16. Best Practices

✅ Always use indexes on frequently queried fields  
✅ Use Mongoose validation for data integrity  
✅ Avoid large embedded arrays (>16MB limit)  
✅ Use `.lean()` for read-only queries (improves performance)  
✅ Use `$lookup` or `.populate()` for relations  
✅ Monitor with MongoDB Compass or Atlas

---

# 🗺️ Quick Summary

|Concept|Command / Example|
|---|---|
|Create|`insertOne()`|
|Read|`find()`|
|Update|`updateOne()`|
|Delete|`deleteOne()`|
|Query|`$gt`, `$in`, `$or`, `$regex`|
|Aggregation|`$match`, `$group`, `$sort`, `$lookup`|
|Index|`createIndex()`|
|Relationship|`$lookup`, `.populate()`|
|Validation|`{ type, required, default }`|
|Pagination|`.skip().limit()`|

---
