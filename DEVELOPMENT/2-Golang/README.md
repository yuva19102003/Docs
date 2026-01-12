# Go Programming Guide

Complete guide to Go programming language with practical examples and best practices.

## Getting Started

- [00 - Project Setup](00-project-setup.md) - Initialize projects, install packages, Docker builds

## Core Concepts

- [01 - Basics](01-basics.md) - Types, variables, operators, conditionals, loops
- [02 - Arrays and Slices](02-arrays-slices.md) - Working with arrays and slices
- [03 - Functions](03-functions.md) - Functions, closures, defer, variadic functions
- [04 - Structs](04-structs.md) - Struct types, methods, composition
- [05 - Maps](05-maps.md) - Hash maps and key-value pairs
- [06 - Pointers](06-pointers.md) - Memory addresses and references
- [07 - Methods and Interfaces](07-methods-interfaces.md) - OOP in Go
- [08 - Errors](08-errors.md) - Error handling patterns
- [09 - Testing](09-testing.md) - Unit tests, benchmarks, examples
- [10 - Concurrency](10-concurrency.md) - Goroutines, channels, patterns
- [11 - Standard Library](11-packages.md) - Common packages (fmt, strings, time, etc.)

## Quick Reference

### Hello World

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
```

### Run and Build

```bash
# Run
go run main.go

# Build
go build -o myapp

# Test
go test ./...
```

### Project Structure

```
my-project/
├── go.mod
├── go.sum
├── main.go
├── cmd/
├── internal/
└── pkg/
```

## Resources

- [Official Documentation](https://go.dev/doc/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://go.dev/doc/effective_go)
