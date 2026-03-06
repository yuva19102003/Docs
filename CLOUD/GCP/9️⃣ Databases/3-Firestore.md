# Firestore - Serverless Document Database

Complete guide to Google Cloud Firestore - scalable NoSQL document database with real-time capabilities.

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Data Model](#data-model)
3. [Database Operations](#database-operations)
4. [Queries](#queries)
5. [Real-time Updates](#real-time-updates)
6. [Security Rules](#security-rules)
7. [Indexes](#indexes)
8. [Offline Support](#offline-support)
9. [Performance](#performance)
10. [Cost Optimization](#cost-optimization)
11. [Best Practices](#best-practices)

---

## Introduction

Firestore is a flexible, scalable NoSQL cloud database for mobile, web, and server development.

### Key Features

✅ Serverless and fully managed  
✅ Real-time synchronization  
✅ Offline support  
✅ Automatic scaling  
✅ ACID transactions  
✅ Powerful queries  
✅ Mobile/web SDKs  
✅ Strong consistency  
✅ Multi-region replication  
✅ Built-in security  

### Architecture

```
┌─────────────────────────────────────────────────────┐
│              Firestore Database                     │
├─────────────────────────────────────────────────────┤
│  Collections & Documents                            │
│  /users/{userId}                                    │
│    ├─ name: "John Doe"                              │
│    ├─ email: "john@example.com"                     │
│    ├─ createdAt: timestamp                          │
│    └─ /orders/{orderId}  (Subcollection)            │
│         ├─ items: [...]                             │
│         ├─ total: 100.00                            │
│         └─ status: "pending"                        │
│                                                     │
│  Features:                                          │
│  - Real-time listeners                              │
│  - Offline persistence                              │
│  - Automatic indexing                               │
│  - Security rules                                   │
└─────────────────────────────────────────────────────┘
```

### Firestore vs Realtime Database

| Feature | Firestore | Realtime Database |
|---------|-----------|-------------------|
| **Data Model** | Collections/Documents | JSON tree |
| **Queries** | Advanced | Limited |
| **Scaling** | Automatic | Manual sharding |
| **Offline** | Yes | Yes |
| **Pricing** | Operations | Bandwidth |
| **Recommended** | ✅ Yes | Legacy |

---

## Data Model

### Collections and Documents

```
┌─────────────────────────────────────────┐
│        Data Structure                   │
├─────────────────────────────────────────┤
│  Collection: users                      │
│  ├─ Document: user1                     │
│  │  ├─ name: "John"                     │
│  │  ├─ email: "john@example.com"        │
│  │  └─ Collection: orders               │
│  │     ├─ Document: order1              │
│  │     │  ├─ total: 100                 │
│  │     │  └─ items: [...]               │
│  │     └─ Document: order2              │
│  │        └─ total: 200                 │
│  └─ Document: user2                     │
│     ├─ name: "Jane"                     │
│     └─ email: "jane@example.com"        │
└─────────────────────────────────────────┘
```

### Data Types

| Type | Description | Example |
|------|-------------|---------|
| **String** | Text | "Hello World" |
| **Number** | Integer or float | 123, 45.67 |
| **Boolean** | True/false | true, false |
| **Map** | Nested object | {key: "value"} |
| **Array** | List of values | [1, 2, 3] |
| **Null** | Null value | null |
| **Timestamp** | Date and time | Timestamp.now() |
| **Geopoint** | Latitude/longitude | GeoPoint(37.7, -122.4) |
| **Reference** | Document reference | /users/user1 |

### Document Limits

- Maximum document size: 1 MB
- Maximum field name length: 1,500 bytes
- Maximum depth: 20 levels
- Maximum array size: Unlimited (within 1 MB)
- Maximum writes per second per document: 1

---

## Database Operations

### Initialize Firestore

```python
from google.cloud import firestore

# Initialize client
db = firestore.Client()
```

```javascript
// Web SDK
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
```

### Create Documents

```python
# Add document with auto-generated ID
doc_ref = db.collection('users').add({
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30,
    'createdAt': firestore.SERVER_TIMESTAMP
})

# Add document with custom ID
db.collection('users').document('user123').set({
    'name': 'Jane Smith',
    'email': 'jane@example.com',
    'age': 25,
    'createdAt': firestore.SERVER_TIMESTAMP
})

# Merge with existing document
db.collection('users').document('user123').set({
    'lastLogin': firestore.SERVER_TIMESTAMP
}, merge=True)
```

```javascript
// JavaScript
import { collection, addDoc, doc, setDoc, serverTimestamp } from 'firebase/firestore';

// Add with auto ID
const docRef = await addDoc(collection(db, 'users'), {
  name: 'John Doe',
  email: 'john@example.com',
  age: 30,
  createdAt: serverTimestamp()
});

// Add with custom ID
await setDoc(doc(db, 'users', 'user123'), {
  name: 'Jane Smith',
  email: 'jane@example.com',
  age: 25,
  createdAt: serverTimestamp()
});
```

### Read Documents

```python
# Get single document
doc_ref = db.collection('users').document('user123')
doc = doc_ref.get()

if doc.exists:
    print(f'Document data: {doc.to_dict()}')
else:
    print('No such document!')

# Get all documents in collection
users_ref = db.collection('users')
docs = users_ref.stream()

for doc in docs:
    print(f'{doc.id} => {doc.to_dict()}')
```

```javascript
// JavaScript
import { doc, getDoc, collection, getDocs } from 'firebase/firestore';

// Get single document
const docRef = doc(db, 'users', 'user123');
const docSnap = await getDoc(docRef);

if (docSnap.exists()) {
  console.log('Document data:', docSnap.data());
} else {
  console.log('No such document!');
}

// Get all documents
const querySnapshot = await getDocs(collection(db, 'users'));
querySnapshot.forEach((doc) => {
  console.log(doc.id, ' => ', doc.data());
});
```

### Update Documents

```python
# Update specific fields
doc_ref = db.collection('users').document('user123')
doc_ref.update({
    'age': 31,
    'lastUpdated': firestore.SERVER_TIMESTAMP
})

# Update nested fields
doc_ref.update({
    'address.city': 'San Francisco',
    'address.state': 'CA'
})

# Increment value
doc_ref.update({
    'loginCount': firestore.Increment(1)
})

# Array operations
doc_ref.update({
    'tags': firestore.ArrayUnion(['new-tag']),
    'oldTags': firestore.ArrayRemove(['old-tag'])
})
```

### Delete Documents

```python
# Delete document
db.collection('users').document('user123').delete()

# Delete field
doc_ref.update({
    'fieldToDelete': firestore.DELETE_FIELD
})

# Delete collection (batch delete)
def delete_collection(coll_ref, batch_size=100):
    docs = coll_ref.limit(batch_size).stream()
    deleted = 0

    for doc in docs:
        doc.reference.delete()
        deleted += 1

    if deleted >= batch_size:
        return delete_collection(coll_ref, batch_size)

delete_collection(db.collection('users'))
```

---

## Queries

### Simple Queries

```python
# Where clause
users_ref = db.collection('users')
query = users_ref.where('age', '>=', 18)
docs = query.stream()

# Multiple conditions
query = users_ref.where('age', '>=', 18).where('city', '==', 'San Francisco')

# Order by
query = users_ref.order_by('age', direction=firestore.Query.DESCENDING)

# Limit
query = users_ref.limit(10)

# Pagination
first_query = users_ref.order_by('name').limit(10)
docs = first_query.stream()
last_doc = list(docs)[-1]

next_query = users_ref.order_by('name').start_after(last_doc).limit(10)
```

```javascript
// JavaScript
import { collection, query, where, orderBy, limit, getDocs, startAfter } from 'firebase/firestore';

// Where clause
const q = query(collection(db, 'users'), where('age', '>=', 18));
const querySnapshot = await getDocs(q);

// Multiple conditions
const q2 = query(
  collection(db, 'users'),
  where('age', '>=', 18),
  where('city', '==', 'San Francisco')
);

// Order by and limit
const q3 = query(
  collection(db, 'users'),
  orderBy('age', 'desc'),
  limit(10)
);

// Pagination
const first = query(collection(db, 'users'), orderBy('name'), limit(10));
const documentSnapshots = await getDocs(first);
const lastVisible = documentSnapshots.docs[documentSnapshots.docs.length-1];

const next = query(
  collection(db, 'users'),
  orderBy('name'),
  startAfter(lastVisible),
  limit(10)
);
```

### Advanced Queries

```python
# Array contains
query = users_ref.where('tags', 'array_contains', 'premium')

# Array contains any
query = users_ref.where('tags', 'array_contains_any', ['premium', 'vip'])

# In query
query = users_ref.where('status', 'in', ['active', 'pending'])

# Not in query
query = users_ref.where('status', 'not_in', ['deleted', 'banned'])

# Range query
query = users_ref.where('age', '>=', 18).where('age', '<=', 65)

# Compound query
query = users_ref.where('city', '==', 'San Francisco')\
                 .where('age', '>=', 18)\
                 .order_by('age')\
                 .limit(10)
```

### Collection Group Queries

```python
# Query across all subcollections named 'orders'
orders_ref = db.collection_group('orders')
query = orders_ref.where('status', '==', 'pending')

for doc in query.stream():
    print(f'{doc.id} => {doc.to_dict()}')
```

---

## Real-time Updates

### Listen to Documents

```python
# Listen to document changes
def on_snapshot(doc_snapshot, changes, read_time):
    for doc in doc_snapshot:
        print(f'Received document snapshot: {doc.id}')
        print(f'Data: {doc.to_dict()}')

doc_ref = db.collection('users').document('user123')
doc_watch = doc_ref.on_snapshot(on_snapshot)

# Stop listening
doc_watch.unsubscribe()
```

```javascript
// JavaScript
import { doc, onSnapshot } from 'firebase/firestore';

// Listen to document
const unsub = onSnapshot(doc(db, 'users', 'user123'), (doc) => {
  console.log('Current data:', doc.data());
});

// Stop listening
unsub();

// Listen to collection
const unsub2 = onSnapshot(collection(db, 'users'), (snapshot) => {
  snapshot.docChanges().forEach((change) => {
    if (change.type === 'added') {
      console.log('New user:', change.doc.data());
    }
    if (change.type === 'modified') {
      console.log('Modified user:', change.doc.data());
    }
    if (change.type === 'removed') {
      console.log('Removed user:', change.doc.data());
    }
  });
});
```

### Listen to Queries

```python
# Listen to query results
def on_snapshot(col_snapshot, changes, read_time):
    for change in changes:
        if change.type.name == 'ADDED':
            print(f'New user: {change.document.id}')
        elif change.type.name == 'MODIFIED':
            print(f'Modified user: {change.document.id}')
        elif change.type.name == 'REMOVED':
            print(f'Removed user: {change.document.id}')

query = db.collection('users').where('status', '==', 'active')
query_watch = query.on_snapshot(on_snapshot)
```

---

## Security Rules

### Basic Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write to all documents
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Public read, authenticated write
    match /posts/{postId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Advanced Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function hasRole(role) {
      return isSignedIn() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(userId);
      allow update: if isOwner(userId) || hasRole('admin');
      allow delete: if hasRole('admin');
      
      // Subcollection: orders
      match /orders/{orderId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId) && 
                         request.resource.data.total >= 0 &&
                         request.resource.data.status == 'pending';
        allow update: if isOwner(userId) || hasRole('admin');
      }
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if resource.data.published == true || isOwner(resource.data.authorId);
      allow create: if isSignedIn() && 
                       request.resource.data.authorId == request.auth.uid &&
                       request.resource.data.title.size() > 0;
      allow update: if isOwner(resource.data.authorId);
      allow delete: if isOwner(resource.data.authorId) || hasRole('admin');
    }
    
    // Validation rules
    match /products/{productId} {
      allow create: if request.resource.data.keys().hasAll(['name', 'price', 'stock']) &&
                       request.resource.data.price is number &&
                       request.resource.data.price > 0 &&
                       request.resource.data.stock is int &&
                       request.resource.data.stock >= 0;
    }
  }
}
```

### Deploy Rules

```bash
# Deploy rules
firebase deploy --only firestore:rules

# Test rules locally
firebase emulators:start --only firestore
```

---

## Indexes

### Automatic Indexes

Firestore automatically creates indexes for:
- Single-field queries
- Simple equality queries
- Simple range queries

### Composite Indexes

```python
# This query requires a composite index
query = db.collection('users')\
          .where('city', '==', 'San Francisco')\
          .where('age', '>=', 18)\
          .order_by('age')\
          .order_by('name')
```

**firestore.indexes.json:**
```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "city",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "age",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "name",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

### Collection Group Indexes

```json
{
  "indexes": [
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

### Deploy Indexes

```bash
# Deploy indexes
firebase deploy --only firestore:indexes

# View indexes
gcloud firestore indexes list
```

---

## Offline Support

### Enable Offline Persistence

```python
# Python (server-side, always online)
# Offline support is for mobile/web clients
```

```javascript
// Web SDK
import { enableIndexedDbPersistence } from 'firebase/firestore';

enableIndexedDbPersistence(db)
  .catch((err) => {
    if (err.code == 'failed-precondition') {
      // Multiple tabs open
    } else if (err.code == 'unimplemented') {
      // Browser doesn't support
    }
  });

// Multi-tab support
import { enableMultiTabIndexedDbPersistence } from 'firebase/firestore';

enableMultiTabIndexedDbPersistence(db);
```

### Offline Behavior

```
┌─────────────────────────────────────────┐
│        Offline Support                  │
├─────────────────────────────────────────┤
│  Online:                                │
│  - Read from server                     │
│  - Write to server                      │
│  - Cache locally                        │
│                                         │
│  Offline:                               │
│  - Read from cache                      │
│  - Write to local queue                 │
│  - Sync when online                     │
│                                         │
│  Reconnect:                             │
│  - Sync pending writes                  │
│  - Update cache                         │
│  - Trigger listeners                    │
└─────────────────────────────────────────┘
```

---

## Performance

### Batch Operations

```python
# Batch write (up to 500 operations)
batch = db.batch()

# Add operations to batch
for i in range(100):
    doc_ref = db.collection('users').document(f'user{i}')
    batch.set(doc_ref, {'name': f'User {i}', 'index': i})

# Commit batch
batch.commit()
```

### Transactions

```python
# Transaction
@firestore.transactional
def transfer_money(transaction, from_ref, to_ref, amount):
    from_snapshot = from_ref.get(transaction=transaction)
    to_snapshot = to_ref.get(transaction=transaction)
    
    from_balance = from_snapshot.get('balance')
    to_balance = to_snapshot.get('balance')
    
    if from_balance < amount:
        raise ValueError('Insufficient funds')
    
    transaction.update(from_ref, {'balance': from_balance - amount})
    transaction.update(to_ref, {'balance': to_balance + amount})

# Execute transaction
transaction = db.transaction()
from_ref = db.collection('accounts').document('account1')
to_ref = db.collection('accounts').document('account2')

transfer_money(transaction, from_ref, to_ref, 100)
```

### Optimization Tips

✅ Use batch writes for multiple operations  
✅ Minimize document reads  
✅ Use transactions for atomic operations  
✅ Denormalize data when appropriate  
✅ Use subcollections for large datasets  
✅ Implement pagination  
✅ Cache frequently accessed data  
✅ Use collection group queries efficiently  

---

## Cost Optimization

### Pricing Components

**Operations:**
- Document reads: $0.06 per 100,000
- Document writes: $0.18 per 100,000
- Document deletes: $0.02 per 100,000
- Storage: $0.18/GB/month
- Network egress: Standard rates

### Optimization Strategies

**1. Minimize reads:**

```python
# Bad: Read entire collection
users = db.collection('users').stream()

# Good: Query specific documents
users = db.collection('users').where('status', '==', 'active').limit(10).stream()
```

**2. Use offline persistence:**

```javascript
// Reduces server reads
enableIndexedDbPersistence(db);
```

**3. Batch operations:**

```python
# Bad: Individual writes
for i in range(100):
    db.collection('users').document(f'user{i}').set({'name': f'User {i}'})

# Good: Batch write
batch = db.batch()
for i in range(100):
    doc_ref = db.collection('users').document(f'user{i}')
    batch.set(doc_ref, {'name': f'User {i}'})
batch.commit()
```

**4. Optimize data structure:**

```python
# Bad: Many small documents
for item in items:
    db.collection('items').add(item)

# Good: Array in single document (if < 1 MB)
db.collection('data').document('items').set({'items': items})
```

**5. Delete old data:**

```python
# Delete documents older than 1 year
from datetime import datetime, timedelta

cutoff = datetime.now() - timedelta(days=365)
old_docs = db.collection('logs').where('createdAt', '<', cutoff).stream()

batch = db.batch()
count = 0
for doc in old_docs:
    batch.delete(doc.reference)
    count += 1
    if count >= 500:
        batch.commit()
        batch = db.batch()
        count = 0

if count > 0:
    batch.commit()
```

### Cost Example

**Scenario:** Mobile app with 10,000 users

```
Daily operations:
- 100,000 reads (with caching)
- 20,000 writes
- 5,000 deletes
- 1 GB storage

Monthly cost:
- Reads: 100K × 30 × $0.06/100K = $1.80
- Writes: 20K × 30 × $0.18/100K = $10.80
- Deletes: 5K × 30 × $0.02/100K = $0.30
- Storage: 1 GB × $0.18 = $0.18
- Total: $13.08/month

With optimization (50% fewer reads):
- Reads: $0.90
- Writes: $10.80
- Deletes: $0.30
- Storage: $0.18
- Total: $12.18/month
- Savings: 7%
```

---

## Best Practices

### Data Modeling

✅ Denormalize data for read performance  
✅ Use subcollections for large datasets  
✅ Keep documents under 1 MB  
✅ Use arrays for small lists  
✅ Use references for relationships  
✅ Plan for scalability  
✅ Consider query patterns  
✅ Use appropriate data types  

### Security

✅ Implement security rules  
✅ Validate data in rules  
✅ Use authentication  
✅ Implement role-based access  
✅ Test security rules  
✅ Regular security audits  
✅ Minimize public access  
✅ Use server-side validation  

### Performance

✅ Use indexes for queries  
✅ Implement pagination  
✅ Use batch operations  
✅ Enable offline persistence  
✅ Cache frequently accessed data  
✅ Minimize document reads  
✅ Use transactions appropriately  
✅ Monitor query performance  

### Cost Management

✅ Minimize reads with caching  
✅ Use batch operations  
✅ Delete old data  
✅ Optimize data structure  
✅ Monitor usage  
✅ Use offline persistence  
✅ Implement pagination  
✅ Regular cost reviews  

---

## Troubleshooting

### Permission Denied

```javascript
// Check security rules
// Verify authentication
// Test with Firebase emulator

firebase emulators:start --only firestore
```

### Query Performance

```python
# Check if index is needed
# View index creation link in error message
# Create composite index

# Monitor query performance
import time

start = time.time()
docs = db.collection('users').where('city', '==', 'SF').stream()
list(docs)
print(f'Query time: {time.time() - start}s')
```

### Offline Issues

```javascript
// Check persistence status
import { getDoc, getDocFromCache, getDocFromServer } from 'firebase/firestore';

// Try cache first
try {
  const doc = await getDocFromCache(docRef);
} catch (e) {
  // Fallback to server
  const doc = await getDocFromServer(docRef);
}
```

---

## Next Steps

- **[Bigtable](4-Bigtable.md)** - Wide-column NoSQL database
- **[Memorystore](5-Memorystore.md)** - In-memory cache
- **[Best Practices](7-Best-Practices.md)** - Production guidelines

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
