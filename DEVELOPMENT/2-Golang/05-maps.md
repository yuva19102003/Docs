# Maps

Maps are data structures that hold key-value pairs. They are similar to dictionaries in Python or objects in JavaScript.

## Creating Maps

```go
// Declaring a map
var cities map[string]string

// Initializing with make
cities = make(map[string]string)

// Declaration and initialization
cities := map[string]string{
    "NY": "USA",
    "London": "UK",
    "Tokyo": "Japan",
}

// Empty map literal
cities := map[string]string{}
```

## Basic Operations

### Insert or Update

```go
cities := make(map[string]string)

// Insert
cities["NY"] = "USA"
cities["London"] = "UK"

// Update
cities["NY"] = "United States"
```

### Retrieve

```go
cities := map[string]string{
    "NY": "USA",
    "London": "UK",
}

// Retrieve value
country := cities["NY"]
fmt.Println(country) // USA

// Retrieve non-existent key returns zero value
country := cities["Paris"]
fmt.Println(country) // "" (empty string)
```

### Check if Key Exists

```go
cities := map[string]string{
    "NY": "USA",
}

// Check if key exists
value, ok := cities["NY"]
if ok {
    fmt.Println("Found:", value) // Found: USA
}

value, ok := cities["Paris"]
if !ok {
    fmt.Println("Not found") // Not found
}
```

### Delete

```go
cities := map[string]string{
    "NY": "USA",
    "London": "UK",
}

// Delete a key
delete(cities, "NY")

// Deleting non-existent key is safe (no error)
delete(cities, "Paris")
```

## Iterating Over Maps

```go
cities := map[string]string{
    "NY": "USA",
    "London": "UK",
    "Tokyo": "Japan",
}

// Iterate over key-value pairs
for city, country := range cities {
    fmt.Printf("%s is in %s\n", city, country)
}

// Iterate over keys only
for city := range cities {
    fmt.Println(city)
}

// Iterate over values only
for _, country := range cities {
    fmt.Println(country)
}
```

## Map with Different Types

```go
// Map with int keys
ages := map[string]int{
    "Alice": 25,
    "Bob": 30,
    "Charlie": 35,
}

// Map with struct values
type Person struct {
    Name string
    Age  int
}

people := map[string]Person{
    "alice": {Name: "Alice", Age: 25},
    "bob": {Name: "Bob", Age: 30},
}

// Map with slice values
groups := map[string][]string{
    "fruits": {"apple", "banana", "orange"},
    "vegetables": {"carrot", "broccoli"},
}
```

## Nested Maps

```go
// Map of maps
countries := map[string]map[string]string{
    "USA": {
        "capital": "Washington DC",
        "language": "English",
    },
    "Japan": {
        "capital": "Tokyo",
        "language": "Japanese",
    },
}

// Access nested values
fmt.Println(countries["USA"]["capital"]) // Washington DC
```

## Map Length

```go
cities := map[string]string{
    "NY": "USA",
    "London": "UK",
    "Tokyo": "Japan",
}

// Get number of key-value pairs
length := len(cities)
fmt.Println(length) // 3
```

## Copying Maps

```go
// Maps are reference types
original := map[string]int{"a": 1, "b": 2}
copy := original

copy["a"] = 10
fmt.Println(original["a"]) // 10 (original is modified!)

// To create a true copy, iterate and copy manually
original := map[string]int{"a": 1, "b": 2}
copy := make(map[string]int)
for k, v := range original {
    copy[k] = v
}

copy["a"] = 10
fmt.Println(original["a"]) // 1 (original unchanged)
```

## Map as Function Parameter

```go
// Maps are passed by reference
func updateMap(m map[string]int) {
    m["key"] = 100
}

myMap := map[string]int{"key": 1}
updateMap(myMap)
fmt.Println(myMap["key"]) // 100 (modified)
```

## Common Patterns

### Count Occurrences

```go
words := []string{"apple", "banana", "apple", "orange", "banana", "apple"}

counts := make(map[string]int)
for _, word := range words {
    counts[word]++
}

fmt.Println(counts) // map[apple:3 banana:2 orange:1]
```

### Group By

```go
type Person struct {
    Name string
    Age  int
}

people := []Person{
    {"Alice", 25},
    {"Bob", 30},
    {"Charlie", 25},
    {"David", 30},
}

// Group by age
byAge := make(map[int][]Person)
for _, person := range people {
    byAge[person.Age] = append(byAge[person.Age], person)
}
```

### Set Implementation

```go
// Use map[T]bool or map[T]struct{} for sets
set := make(map[string]bool)

// Add elements
set["apple"] = true
set["banana"] = true

// Check membership
if set["apple"] {
    fmt.Println("apple is in set")
}

// Remove element
delete(set, "apple")

// Using struct{} (more memory efficient)
set := make(map[string]struct{})
set["apple"] = struct{}{}

if _, exists := set["apple"]; exists {
    fmt.Println("apple is in set")
}
```

## Important Notes

1. **Maps are not ordered** - iteration order is random
2. **Maps are not safe for concurrent use** - use sync.Map or mutex for concurrent access
3. **Map keys must be comparable** - can't use slices, maps, or functions as keys
4. **Zero value of a map is nil** - must initialize before use

```go
var m map[string]int
// m is nil, cannot add elements
// m["key"] = 1 // panic: assignment to entry in nil map

// Must initialize
m = make(map[string]int)
m["key"] = 1 // OK
```
