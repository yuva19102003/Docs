# Error Handling

Go doesn't support `throw`, `try`, `catch` and other common error handling structures. Instead, errors are values that are returned from functions.

## The Error Interface

```go
type error interface {
    Error() string
}
```

## Basic Error Handling

```go
import "errors"

// Function that returns an error
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}

// Using the function
result, err := divide(10, 2)
if err != nil {
    fmt.Println("Error:", err)
    return
}
fmt.Println("Result:", result) // Result: 5
```

## Creating Errors

### Using errors.New

```go
import "errors"

func validateAge(age int) error {
    if age < 0 {
        return errors.New("age cannot be negative")
    }
    if age > 150 {
        return errors.New("age is too high")
    }
    return nil
}
```

### Using fmt.Errorf

```go
import "fmt"

func findUser(id int) (*User, error) {
    if id < 0 {
        return nil, fmt.Errorf("invalid user ID: %d", id)
    }
    // ...
    return nil, fmt.Errorf("user %d not found", id)
}
```

## Custom Error Types

```go
// Define custom error type
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation error on field '%s': %s", e.Field, e.Message)
}

// Using custom error
func validateEmail(email string) error {
    if !strings.Contains(email, "@") {
        return ValidationError{
            Field:   "email",
            Message: "must contain @ symbol",
        }
    }
    return nil
}

// Check for specific error type
err := validateEmail("invalid")
if err != nil {
    if ve, ok := err.(ValidationError); ok {
        fmt.Printf("Field: %s, Message: %s\n", ve.Field, ve.Message)
    }
}
```

## Error Wrapping (Go 1.13+)

```go
import (
    "errors"
    "fmt"
)

// Wrap errors with context
func readConfig(filename string) error {
    err := openFile(filename)
    if err != nil {
        return fmt.Errorf("failed to read config: %w", err)
    }
    return nil
}

// Unwrap errors
err := readConfig("config.json")
if err != nil {
    // Get the underlying error
    unwrapped := errors.Unwrap(err)
    fmt.Println(unwrapped)
}
```

## Checking for Specific Errors

### Using errors.Is

```go
import "errors"

var ErrNotFound = errors.New("not found")

func findItem(id int) error {
    return ErrNotFound
}

err := findItem(1)
if errors.Is(err, ErrNotFound) {
    fmt.Println("Item not found")
}
```

### Using errors.As

```go
type NetworkError struct {
    Code int
    Msg  string
}

func (e NetworkError) Error() string {
    return fmt.Sprintf("network error %d: %s", e.Code, e.Msg)
}

func makeRequest() error {
    return NetworkError{Code: 500, Msg: "server error"}
}

err := makeRequest()
var netErr NetworkError
if errors.As(err, &netErr) {
    fmt.Printf("Network error code: %d\n", netErr.Code)
}
```

## Sentinel Errors

```go
import "errors"

// Define sentinel errors
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrInvalidInput = errors.New("invalid input")
)

func getUser(id int) (*User, error) {
    if id < 0 {
        return nil, ErrInvalidInput
    }
    // ...
    return nil, ErrNotFound
}

// Usage
user, err := getUser(-1)
if err != nil {
    switch err {
    case ErrNotFound:
        fmt.Println("User not found")
    case ErrUnauthorized:
        fmt.Println("Access denied")
    case ErrInvalidInput:
        fmt.Println("Invalid input")
    }
}
```

## Multiple Return Values

```go
// Common pattern: return result and error
func processData(data string) (string, error) {
    if data == "" {
        return "", errors.New("data is empty")
    }
    result := strings.ToUpper(data)
    return result, nil
}

// Usage
result, err := processData("hello")
if err != nil {
    log.Fatal(err)
}
fmt.Println(result)
```

## Panic and Recover

Use panic for unrecoverable errors. Use recover to catch panics.

```go
// Panic
func mustConnect(url string) {
    if url == "" {
        panic("URL cannot be empty")
    }
    // connect...
}

// Recover
func safeExecute() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered from panic:", r)
        }
    }()
    
    // Code that might panic
    mustConnect("")
}

safeExecute() // Recovered from panic: URL cannot be empty
```

## Best Practices

### 1. Always Check Errors

```go
// Bad
result, _ := doSomething()

// Good
result, err := doSomething()
if err != nil {
    return err
}
```

### 2. Add Context to Errors

```go
// Bad
return err

// Good
return fmt.Errorf("failed to process user %d: %w", userID, err)
```

### 3. Don't Ignore Errors

```go
// Bad
file.Close()

// Good
if err := file.Close(); err != nil {
    log.Printf("failed to close file: %v", err)
}
```

### 4. Return Early

```go
// Good
func process(data string) error {
    if data == "" {
        return errors.New("data is empty")
    }
    
    result, err := transform(data)
    if err != nil {
        return fmt.Errorf("transform failed: %w", err)
    }
    
    if err := save(result); err != nil {
        return fmt.Errorf("save failed: %w", err)
    }
    
    return nil
}
```

## Error Handling Patterns

### Retry Pattern

```go
func retryOperation(maxRetries int, operation func() error) error {
    var err error
    for i := 0; i < maxRetries; i++ {
        err = operation()
        if err == nil {
            return nil
        }
        time.Sleep(time.Second * time.Duration(i+1))
    }
    return fmt.Errorf("operation failed after %d retries: %w", maxRetries, err)
}
```

### Error Aggregation

```go
type MultiError struct {
    Errors []error
}

func (m MultiError) Error() string {
    var msgs []string
    for _, err := range m.Errors {
        msgs = append(msgs, err.Error())
    }
    return strings.Join(msgs, "; ")
}

func validateUser(user User) error {
    var errs []error
    
    if user.Name == "" {
        errs = append(errs, errors.New("name is required"))
    }
    if user.Email == "" {
        errs = append(errs, errors.New("email is required"))
    }
    if user.Age < 0 {
        errs = append(errs, errors.New("age must be positive"))
    }
    
    if len(errs) > 0 {
        return MultiError{Errors: errs}
    }
    return nil
}
```
