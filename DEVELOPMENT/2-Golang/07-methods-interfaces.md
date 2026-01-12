# Methods and Interfaces

Go doesn't have classes, but you can define methods on types and use interfaces for polymorphism.

## Methods

Methods are functions with a special receiver argument.

### Value Receivers

```go
type Rectangle struct {
    Width  float64
    Height float64
}

// Method with value receiver
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func (r Rectangle) Perimeter() float64 {
    return 2 * (r.Width + r.Height)
}

rect := Rectangle{Width: 10, Height: 5}
fmt.Println(rect.Area())      // 50
fmt.Println(rect.Perimeter()) // 30
```

### Pointer Receivers

```go
type Rectangle struct {
    Width  float64
    Height float64
}

// Method with pointer receiver (can modify the receiver)
func (r *Rectangle) Scale(factor float64) {
    r.Width *= factor
    r.Height *= factor
}

func (r *Rectangle) SetWidth(width float64) {
    r.Width = width
}

rect := Rectangle{Width: 10, Height: 5}
rect.Scale(2)
fmt.Println(rect.Width)  // 20
fmt.Println(rect.Height) // 10
```

### When to Use Pointer Receivers

Use pointer receivers when:
1. The method needs to modify the receiver
2. The receiver is a large struct (avoid copying)
3. Consistency - if some methods have pointer receivers, all should

```go
type Counter struct {
    count int
}

// Pointer receiver - modifies the receiver
func (c *Counter) Increment() {
    c.count++
}

// Value receiver - doesn't modify the receiver
func (c Counter) Value() int {
    return c.count
}

counter := Counter{}
counter.Increment()
counter.Increment()
fmt.Println(counter.Value()) // 2
```

## Interfaces

Interfaces define behavior (method sets). Types implement interfaces implicitly.

### Defining Interfaces

```go
type Shape interface {
    Area() float64
    Perimeter() float64
}

type Rectangle struct {
    Width  float64
    Height float64
}

type Circle struct {
    Radius float64
}

// Rectangle implements Shape
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func (r Rectangle) Perimeter() float64 {
    return 2 * (r.Width + r.Height)
}

// Circle implements Shape
func (c Circle) Area() float64 {
    return 3.14159 * c.Radius * c.Radius
}

func (c Circle) Perimeter() float64 {
    return 2 * 3.14159 * c.Radius
}
```

### Using Interfaces

```go
func printShapeInfo(s Shape) {
    fmt.Printf("Area: %.2f\n", s.Area())
    fmt.Printf("Perimeter: %.2f\n", s.Perimeter())
}

rect := Rectangle{Width: 10, Height: 5}
circle := Circle{Radius: 7}

printShapeInfo(rect)   // Works!
printShapeInfo(circle) // Works!
```

### Empty Interface

The empty interface `interface{}` (or `any` in Go 1.18+) can hold values of any type.

```go
func printAnything(value interface{}) {
    fmt.Println(value)
}

printAnything(42)
printAnything("hello")
printAnything(true)
printAnything([]int{1, 2, 3})

// Using 'any' (Go 1.18+)
func printAnything(value any) {
    fmt.Println(value)
}
```

### Type Assertions

```go
var i interface{} = "hello"

// Type assertion
s := i.(string)
fmt.Println(s) // hello

// Type assertion with check
s, ok := i.(string)
if ok {
    fmt.Println(s) // hello
}

// This would panic
// f := i.(float64) // panic: interface conversion

// Safe type assertion
f, ok := i.(float64)
if !ok {
    fmt.Println("Not a float64")
}
```

### Type Switches

```go
func describe(i interface{}) {
    switch v := i.(type) {
    case int:
        fmt.Printf("Integer: %d\n", v)
    case string:
        fmt.Printf("String: %s\n", v)
    case bool:
        fmt.Printf("Boolean: %t\n", v)
    default:
        fmt.Printf("Unknown type: %T\n", v)
    }
}

describe(42)      // Integer: 42
describe("hello") // String: hello
describe(true)    // Boolean: true
describe(3.14)    // Unknown type: float64
```

## Common Interfaces

### Stringer Interface

```go
type Stringer interface {
    String() string
}

type Person struct {
    Name string
    Age  int
}

func (p Person) String() string {
    return fmt.Sprintf("%s (%d years old)", p.Name, p.Age)
}

person := Person{Name: "Alice", Age: 25}
fmt.Println(person) // Alice (25 years old)
```

### Error Interface

```go
type error interface {
    Error() string
}

type MyError struct {
    Code    int
    Message string
}

func (e MyError) Error() string {
    return fmt.Sprintf("Error %d: %s", e.Code, e.Message)
}

func doSomething() error {
    return MyError{Code: 404, Message: "Not found"}
}

err := doSomething()
if err != nil {
    fmt.Println(err) // Error 404: Not found
}
```

### Reader and Writer Interfaces

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// Example: Custom writer
type ConsoleWriter struct{}

func (cw ConsoleWriter) Write(p []byte) (n int, err error) {
    n, err = fmt.Print(string(p))
    return
}

var w Writer = ConsoleWriter{}
w.Write([]byte("Hello, World!")) // Hello, World!
```

## Interface Composition

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}

// Composed interface
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

## Polymorphism Example

```go
type Animal interface {
    Speak() string
}

type Dog struct {
    Name string
}

func (d Dog) Speak() string {
    return "Woof!"
}

type Cat struct {
    Name string
}

func (c Cat) Speak() string {
    return "Meow!"
}

func makeAnimalSpeak(a Animal) {
    fmt.Println(a.Speak())
}

dog := Dog{Name: "Rex"}
cat := Cat{Name: "Whiskers"}

makeAnimalSpeak(dog) // Woof!
makeAnimalSpeak(cat) // Meow!
```

## Interface Values

```go
var shape Shape

// Interface value is nil
fmt.Println(shape == nil) // true

// Assign concrete type
shape = Rectangle{Width: 10, Height: 5}
fmt.Println(shape == nil) // false

// Interface holds (value, type) pair
fmt.Printf("(%v, %T)\n", shape, shape) // ({10 5}, main.Rectangle)
```

## Best Practices

1. **Keep interfaces small** - Prefer many small interfaces over large ones
2. **Accept interfaces, return structs** - Functions should accept interfaces but return concrete types
3. **Define interfaces where they're used** - Not where types are defined
4. **Use standard library interfaces** - io.Reader, io.Writer, fmt.Stringer, etc.

```go
// Good: Accept interface
func ProcessData(r io.Reader) error {
    // ...
}

// Good: Return concrete type
func NewReader() *MyReader {
    return &MyReader{}
}
```

## Example: Dependency Injection

```go
// Define interface
type Database interface {
    Save(data string) error
    Load(id string) (string, error)
}

// Concrete implementation
type PostgresDB struct{}

func (db PostgresDB) Save(data string) error {
    fmt.Println("Saving to Postgres:", data)
    return nil
}

func (db PostgresDB) Load(id string) (string, error) {
    return "data from Postgres", nil
}

// Service depends on interface, not concrete type
type UserService struct {
    db Database
}

func NewUserService(db Database) *UserService {
    return &UserService{db: db}
}

func (s *UserService) SaveUser(name string) error {
    return s.db.Save(name)
}

// Usage
db := PostgresDB{}
service := NewUserService(db)
service.SaveUser("Alice")
```
