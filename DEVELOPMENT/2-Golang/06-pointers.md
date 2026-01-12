# Pointers

Pointers are variables that store memory addresses of other variables. They allow you to directly reference and modify values in memory.

## Pointer Basics

```go
// Declare a pointer
var pointer *int

// Get memory address with &
value := 42
pointer = &value

fmt.Println(value)   // 42
fmt.Println(pointer) // 0xc000012028 (memory address)

// Dereference pointer with *
fmt.Println(*pointer) // 42

// Modify value through pointer
*pointer = 100
fmt.Println(value)    // 100
fmt.Println(*pointer) // 100
```

## Pointer Types

```go
var intPtr *int
var stringPtr *string
var boolPtr *bool

// Pointer to struct
type Person struct {
    Name string
    Age  int
}
var personPtr *Person
```

## Creating Pointers

```go
// Method 1: Using & operator
x := 10
ptr := &x

// Method 2: Using new (allocates memory and returns pointer)
ptr := new(int)
*ptr = 10

// Method 3: Pointer to struct
person := &Person{Name: "Alice", Age: 25}
```

## Zero Value

```go
var ptr *int
fmt.Println(ptr) // nil

// Check for nil before dereferencing
if ptr != nil {
    fmt.Println(*ptr)
} else {
    fmt.Println("Pointer is nil")
}
```

## Pointers with Functions

### Pass by Value vs Pass by Pointer

```go
// Pass by value (copy)
func incrementValue(x int) {
    x++
}

value := 10
incrementValue(value)
fmt.Println(value) // 10 (unchanged)

// Pass by pointer (reference)
func incrementPointer(x *int) {
    *x++
}

value := 10
incrementPointer(&value)
fmt.Println(value) // 11 (modified)
```

### Returning Pointers

```go
func createPerson(name string, age int) *Person {
    person := Person{Name: name, Age: age}
    return &person // Safe in Go (escape analysis)
}

p := createPerson("Alice", 25)
fmt.Println(p.Name) // Alice
```

## Pointers to Structs

```go
type Person struct {
    Name string
    Age  int
}

// Create pointer to struct
person := &Person{Name: "Alice", Age: 25}

// Access fields (Go automatically dereferences)
fmt.Println(person.Name) // Alice
person.Age = 26

// Explicit dereferencing (not necessary but valid)
fmt.Println((*person).Name) // Alice
```

### Method Receivers

```go
type Rectangle struct {
    Width  float64
    Height float64
}

// Value receiver (receives copy)
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

// Pointer receiver (receives reference)
func (r *Rectangle) Scale(factor float64) {
    r.Width *= factor
    r.Height *= factor
}

rect := Rectangle{Width: 10, Height: 5}
fmt.Println(rect.Area()) // 50

rect.Scale(2)
fmt.Println(rect.Width)  // 20
fmt.Println(rect.Height) // 10
```

## Pointer to Pointer

```go
value := 42
ptr := &value
ptrToPtr := &ptr

fmt.Println(value)      // 42
fmt.Println(*ptr)       // 42
fmt.Println(**ptrToPtr) // 42

**ptrToPtr = 100
fmt.Println(value) // 100
```

## Pointers with Arrays and Slices

```go
// Array pointer
arr := [3]int{1, 2, 3}
arrPtr := &arr
arrPtr[0] = 10
fmt.Println(arr) // [10 2 3]

// Slices are already reference types
slice := []int{1, 2, 3}
func modifySlice(s []int) {
    s[0] = 10
}
modifySlice(slice)
fmt.Println(slice) // [10 2 3]
```

## Common Use Cases

### Modifying Function Arguments

```go
type Config struct {
    Host string
    Port int
}

func updateConfig(cfg *Config) {
    cfg.Host = "localhost"
    cfg.Port = 8080
}

config := Config{}
updateConfig(&config)
fmt.Println(config) // {localhost 8080}
```

### Optional Values

```go
func findUser(id int) *User {
    // If user not found, return nil
    if id < 0 {
        return nil
    }
    return &User{ID: id, Name: "Alice"}
}

user := findUser(1)
if user != nil {
    fmt.Println(user.Name)
} else {
    fmt.Println("User not found")
}
```

### Large Structs

```go
// Avoid copying large structs
type LargeStruct struct {
    Data [1000000]int
}

// Use pointer to avoid copying
func processLargeStruct(ls *LargeStruct) {
    // Process without copying entire struct
}
```

## Pointer Arithmetic

Unlike C, Go does not support pointer arithmetic for safety reasons.

```go
// This is NOT allowed in Go
ptr := &value
ptr++ // Error: invalid operation
```

## Important Notes

1. **Nil pointers** - Always check for nil before dereferencing
2. **Automatic dereferencing** - Go automatically dereferences pointers to structs
3. **No pointer arithmetic** - Go doesn't allow pointer arithmetic
4. **Escape analysis** - Go compiler determines if variable should be on stack or heap
5. **Pass by pointer for efficiency** - Use pointers for large structs to avoid copying

## When to Use Pointers

Use pointers when:
- You need to modify the original value
- You're working with large structs (avoid copying)
- You need to represent "no value" (nil)
- You're implementing methods that modify the receiver

Don't use pointers when:
- Working with small values (int, bool, small structs)
- The value should not be modified
- You're working with slices, maps, or channels (already reference types)

## Example: Linked List

```go
type Node struct {
    Value int
    Next  *Node
}

func createLinkedList() *Node {
    return &Node{
        Value: 1,
        Next: &Node{
            Value: 2,
            Next: &Node{
                Value: 3,
                Next:  nil,
            },
        },
    }
}

func printList(head *Node) {
    current := head
    for current != nil {
        fmt.Println(current.Value)
        current = current.Next
    }
}

list := createLinkedList()
printList(list)
// Output:
// 1
// 2
// 3
```
