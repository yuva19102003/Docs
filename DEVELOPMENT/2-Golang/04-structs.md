# Structs

Structs are a way to arrange data in specific formats. They are similar to classes in other languages but without inheritance.

## Defining Structs

```go
// Declaring a struct
type Person struct {
    Name string
    Age  int
}

// Struct with multiple types
type Employee struct {
    ID        int
    FirstName string
    LastName  string
    Email     string
    Salary    float64
    IsActive  bool
}
```

## Creating Struct Instances

```go
// Method 1: Positional initialization
person := Person{"John", 34}
person.Name // "John"
person.Age // 34

// Method 2: Named fields
person2 := Person{
    Name: "Alice",
    Age:  20,
}
person2.Name // "Alice"
person2.Age // 20

// Method 3: Zero value initialization
person3 := Person{}
person3.Name // ""
person3.Age // 0

// Method 4: Using new (returns pointer)
person4 := new(Person)
person4.Name // ""
person4.Age // 0
```

## Accessing and Modifying Fields

```go
type Person struct {
    Name string
    Age  int
}

person := Person{"John", 30}

// Access fields
fmt.Println(person.Name) // John

// Modify fields
person.Age = 31
fmt.Println(person.Age) // 31
```

## Nested Structs

```go
type Address struct {
    Street  string
    City    string
    ZipCode string
}

type Person struct {
    Name    string
    Age     int
    Address Address
}

person := Person{
    Name: "John",
    Age:  30,
    Address: Address{
        Street:  "123 Main St",
        City:    "New York",
        ZipCode: "10001",
    },
}

fmt.Println(person.Address.City) // New York
```

## Embedded Structs (Composition)

```go
type Address struct {
    Street string
    City   string
}

type Person struct {
    Name string
    Age  int
    Address // Embedded struct
}

person := Person{
    Name: "John",
    Age:  30,
    Address: Address{
        Street: "123 Main St",
        City:   "New York",
    },
}

// Can access embedded fields directly
fmt.Println(person.Street) // 123 Main St
fmt.Println(person.City)   // New York

// Or through the embedded struct
fmt.Println(person.Address.Street) // 123 Main St
```

## Anonymous Structs

```go
// Useful for one-time use
person := struct {
    Name string
    Age  int
}{
    Name: "John",
    Age:  30,
}

fmt.Println(person.Name) // John
```

## Struct Tags

```go
// Tags provide metadata about fields
type User struct {
    ID        int    `json:"id" db:"user_id"`
    FirstName string `json:"first_name" db:"first_name"`
    LastName  string `json:"last_name" db:"last_name"`
    Email     string `json:"email" validate:"required,email"`
}

// Used by packages like encoding/json
import "encoding/json"

user := User{
    ID:        1,
    FirstName: "John",
    LastName:  "Doe",
    Email:     "john@example.com",
}

jsonData, _ := json.Marshal(user)
fmt.Println(string(jsonData))
// {"id":1,"first_name":"John","last_name":"Doe","email":"john@example.com"}
```

## Comparing Structs

```go
type Point struct {
    X int
    Y int
}

p1 := Point{1, 2}
p2 := Point{1, 2}
p3 := Point{2, 3}

fmt.Println(p1 == p2) // true
fmt.Println(p1 == p3) // false

// Note: Structs with slices, maps, or functions cannot be compared
```

## Copying Structs

```go
type Person struct {
    Name string
    Age  int
}

person1 := Person{"John", 30}

// Shallow copy
person2 := person1
person2.Name = "Jane"

fmt.Println(person1.Name) // John (unchanged)
fmt.Println(person2.Name) // Jane
```

## Struct Methods

Methods are covered in detail in the Methods and Interfaces section, but here's a quick example:

```go
type Rectangle struct {
    Width  float64
    Height float64
}

// Method with value receiver
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

// Method with pointer receiver
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

## Constructor Pattern

```go
type Person struct {
    name string // unexported
    age  int    // unexported
}

// Constructor function
func NewPerson(name string, age int) *Person {
    return &Person{
        name: name,
        age:  age,
    }
}

// Getter methods
func (p *Person) Name() string {
    return p.name
}

func (p *Person) Age() int {
    return p.age
}

// Setter methods
func (p *Person) SetAge(age int) {
    if age > 0 {
        p.age = age
    }
}

person := NewPerson("John", 30)
fmt.Println(person.Name()) // John
```
