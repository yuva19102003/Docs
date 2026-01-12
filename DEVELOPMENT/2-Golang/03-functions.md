# Functions

## Basic Functions

```go
// Functions acts as a scoped block of code
func sayHello() {
    fmt.Println("Hello World!")
}
sayHello() // Hello World!
```

## Parameters and Return Values

```go
// Functions can take zero or more parameters, as so return zero or more parameters
func sum(x int, y int) int {
    return x + y
}
sum(3, 7) // 10

// Shortened parameter syntax (same type)
func sum(x, y int) int {
    return x + y
}

// Multiple return values
func swap(x, y string) (string, string) {
    return y, x
}
a, b := swap("hello", "world")
// a = "world"
// b = "hello"
```

## Named Return Values

```go
// Returned values can be named and be used inside the function
func doubleAndTriple(x int) (double, triple int) {
    double = x * 2
    triple = x * 3
    return
}
d, t := doubleAndTriple(5)
// d = 10
// t = 15

// Skipping one of the returned values
_, t := doubleAndTriple(3)
// t = 9
```

## Variadic Functions

```go
// Accept variable number of arguments
func sum(numbers ...int) int {
    total := 0
    for _, num := range numbers {
        total += num
    }
    return total
}

sum(1, 2, 3) // 6
sum(1, 2, 3, 4, 5) // 15

// Pass slice to variadic function
nums := []int{1, 2, 3, 4}
sum(nums...) // 10
```

## Defer

```go
// Defered commands are runned in a stack order (LIFO)
// after the execution and returning of a function
func example() {
    defer fmt.Println("world")
    fmt.Println("hello")
}
example()
// Output:
// hello
// world

// Multiple defers
func example() {
    defer fmt.Println("1")
    defer fmt.Println("2")
    defer fmt.Println("3")
}
example()
// Output:
// 3
// 2
// 1

// Common use case: cleanup
func readFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer file.Close() // Ensures file is closed when function returns
    
    // Read file...
    return nil
}
```

## Anonymous Functions

```go
// Anonymous function
func() {
    fmt.Println("Anonymous function")
}()

// Assign to variable
greet := func(name string) {
    fmt.Printf("Hello, %s!\n", name)
}
greet("Alice") // Hello, Alice!
```

## Functions as Values

```go
// Functions can be handled as values
func calc(fn func(int, int) int) int {
    return fn(2, 6)
}

func sum(x, y int) int {
    return x + y
}

func mult(x, y int) int {
    return x * y
}

calc(sum) // 8
calc(mult) // 12
calc(
    func(x, y int) int {
        return x / y
    }
) // 0 (integer division: 2/6)
```

## Closures

```go
// Function closures: a function that returns a function
// that remembers the original context
func calc() func(int) int {
    value := 0
    return func(x int) int {
        value += x
        return value
    }
}

calculator := calc()
calculator(3) // 3
calculator(45) // 48
calculator(12) // 60

// Another closure example
func counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}

c1 := counter()
c1() // 1
c1() // 2
c1() // 3

c2 := counter()
c2() // 1 (separate counter)
```

## Recursion

```go
// Factorial
func factorial(n int) int {
    if n == 0 {
        return 1
    }
    return n * factorial(n-1)
}
factorial(5) // 120

// Fibonacci
func fibonacci(n int) int {
    if n <= 1 {
        return n
    }
    return fibonacci(n-1) + fibonacci(n-2)
}
fibonacci(7) // 13
```

## Function Types

```go
// Define function type
type operation func(int, int) int

func add(a, b int) int {
    return a + b
}

func subtract(a, b int) int {
    return a - b
}

func calculate(op operation, a, b int) int {
    return op(a, b)
}

calculate(add, 5, 3) // 8
calculate(subtract, 5, 3) // 2
```
