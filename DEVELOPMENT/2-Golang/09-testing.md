# Testing

Go has a built-in testing framework in the `testing` package.

## Basic Test Structure

```go
// math.go
package math

func Add(a, b int) int {
    return a + b
}

func Subtract(a, b int) int {
    return a - b
}
```

```go
// math_test.go
package math

import "testing"

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    expected := 5
    
    if result != expected {
        t.Errorf("Add(2, 3) = %d; want %d", result, expected)
    }
}

func TestSubtract(t *testing.T) {
    result := Subtract(5, 3)
    expected := 2
    
    if result != expected {
        t.Errorf("Subtract(5, 3) = %d; want %d", result, expected)
    }
}
```

## Running Tests

```bash
# Run all tests in current package
go test

# Run tests with verbose output
go test -v

# Run specific test
go test -run TestAdd

# Run tests in all packages
go test ./...

# Run tests with coverage
go test -cover

# Generate coverage report
go test -coverprofile=coverage.out
go tool cover -html=coverage.out
```

## Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -2, -3, -5},
        {"mixed numbers", -2, 3, 1},
        {"zeros", 0, 0, 0},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", 
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

## Test Helper Functions

```go
func assertEqual(t *testing.T, got, want interface{}) {
    t.Helper() // Marks this as a helper function
    if got != want {
        t.Errorf("got %v; want %v", got, want)
    }
}

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    assertEqual(t, result, 5)
}
```

## Subtests

```go
func TestMath(t *testing.T) {
    t.Run("Addition", func(t *testing.T) {
        result := Add(2, 3)
        if result != 5 {
            t.Errorf("Add(2, 3) = %d; want 5", result)
        }
    })
    
    t.Run("Subtraction", func(t *testing.T) {
        result := Subtract(5, 3)
        if result != 2 {
            t.Errorf("Subtract(5, 3) = %d; want 2", result)
        }
    })
}
```

## Testing with Setup and Teardown

```go
func TestMain(m *testing.M) {
    // Setup
    fmt.Println("Setting up tests...")
    
    // Run tests
    code := m.Run()
    
    // Teardown
    fmt.Println("Cleaning up...")
    
    os.Exit(code)
}

func TestSomething(t *testing.T) {
    // Test code
}
```

## Benchmarking

```go
func BenchmarkAdd(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Add(2, 3)
    }
}

func BenchmarkSubtract(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Subtract(5, 3)
    }
}
```

Run benchmarks:

```bash
# Run benchmarks
go test -bench=.

# Run benchmarks with memory stats
go test -bench=. -benchmem

# Run specific benchmark
go test -bench=BenchmarkAdd
```

## Example Tests

```go
func ExampleAdd() {
    result := Add(2, 3)
    fmt.Println(result)
    // Output: 5
}

func ExampleSubtract() {
    result := Subtract(5, 3)
    fmt.Println(result)
    // Output: 2
}
```

## Testing HTTP Handlers

```go
import (
    "net/http"
    "net/http/httptest"
    "testing"
)

func HelloHandler(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hello, World!"))
}

func TestHelloHandler(t *testing.T) {
    req := httptest.NewRequest("GET", "/hello", nil)
    w := httptest.NewRecorder()
    
    HelloHandler(w, req)
    
    if w.Code != http.StatusOK {
        t.Errorf("Expected status 200, got %d", w.Code)
    }
    
    expected := "Hello, World!"
    if w.Body.String() != expected {
        t.Errorf("Expected %s, got %s", expected, w.Body.String())
    }
}
```

## Mocking

```go
// Interface for dependency
type Database interface {
    GetUser(id int) (*User, error)
}

// Mock implementation
type MockDatabase struct {
    GetUserFunc func(id int) (*User, error)
}

func (m *MockDatabase) GetUser(id int) (*User, error) {
    return m.GetUserFunc(id)
}

// Service that uses the interface
type UserService struct {
    db Database
}

func (s *UserService) GetUserName(id int) (string, error) {
    user, err := s.db.GetUser(id)
    if err != nil {
        return "", err
    }
    return user.Name, nil
}

// Test with mock
func TestGetUserName(t *testing.T) {
    mockDB := &MockDatabase{
        GetUserFunc: func(id int) (*User, error) {
            return &User{ID: id, Name: "Alice"}, nil
        },
    }
    
    service := UserService{db: mockDB}
    name, err := service.GetUserName(1)
    
    if err != nil {
        t.Fatalf("Unexpected error: %v", err)
    }
    
    if name != "Alice" {
        t.Errorf("Expected Alice, got %s", name)
    }
}
```

## Test Coverage

```bash
# Run tests with coverage
go test -cover

# Generate coverage profile
go test -coverprofile=coverage.out

# View coverage in browser
go tool cover -html=coverage.out

# Show coverage by function
go tool cover -func=coverage.out
```

## Testing Best Practices

1. **Test file naming**: `filename_test.go`
2. **Test function naming**: `TestFunctionName`
3. **Use table-driven tests** for multiple test cases
4. **Use t.Helper()** in helper functions
5. **Test edge cases** and error conditions
6. **Keep tests simple** and focused
7. **Use meaningful test names**
8. **Don't test implementation details**

## Common Testing Patterns

### Testing Errors

```go
func TestDivideByZero(t *testing.T) {
    _, err := Divide(10, 0)
    if err == nil {
        t.Error("Expected error for division by zero")
    }
}
```

### Testing Panics

```go
func TestPanic(t *testing.T) {
    defer func() {
        if r := recover(); r == nil {
            t.Error("Expected panic")
        }
    }()
    
    FunctionThatPanics()
}
```

### Parallel Tests

```go
func TestParallel(t *testing.T) {
    t.Parallel() // Run this test in parallel
    
    // Test code
}
```

### Skip Tests

```go
func TestSomething(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping test in short mode")
    }
    
    // Long-running test
}
```

Run with:
```bash
go test -short
```
