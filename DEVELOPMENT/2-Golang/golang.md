# Go Programming Language

Complete guide to Go programming with organized topics and practical examples.

## Documentation Structure

This guide is organized into separate files for easier navigation:

### Getting Started
- **[00 - Project Setup](00-project-setup.md)** - How to initialize projects, install packages, create local/remote packages, run/build applications, and Docker builds (including multi-stage)

### Core Concepts
- **[01 - Basics](01-basics.md)** - Basic types, variables, operators, conditionals, and loops
- **[02 - Arrays and Slices](02-arrays-slices.md)** - Working with arrays and slices
- **[03 - Functions](03-functions.md)** - Functions, closures, defer, and variadic functions
- **[04 - Structs](04-structs.md)** - Struct types, methods, and composition
- **[05 - Maps](05-maps.md)** - Hash maps and key-value pairs
- **[06 - Pointers](06-pointers.md)** - Memory addresses and references
- **[07 - Methods and Interfaces](07-methods-interfaces.md)** - Object-oriented programming in Go
- **[08 - Errors](08-errors.md)** - Error handling patterns and best practices
- **[09 - Testing](09-testing.md)** - Unit tests, benchmarks, and examples
- **[10 - Concurrency](10-concurrency.md)** - Goroutines, channels, and concurrency patterns
- **[11 - Standard Library](11-packages.md)** - Common packages (fmt, strings, time, io, http, etc.)

## Quick Start

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
# Run directly
go run main.go

# Build executable
go build -o myapp

# Run tests
go test ./...
```

## Go CLI Commands Reference

```bash
# Compile & Run
go run [file.go]

# Build executable
go build [file.go]
go build -o [output-name]

# Test packages
go test ./...
go test -v
go test -cover

# Install packages/modules
go get [module]
go install [package]

# Manage dependencies
go mod init [module-name]
go mod tidy
go mod download

# Format code
go fmt ./...

# List packages
go list ./...

# View documentation
go doc [package]

# Environment info
go env
go version
```

## Project Structure

```
my-project/
├── go.mod              # Module definition
├── go.sum              # Dependency checksums
├── main.go             # Entry point
├── cmd/                # Command-line apps
├── internal/           # Private code
├── pkg/                # Public libraries
└── vendor/             # Vendored dependencies (optional)
```

## Resources

- [Official Go Documentation](https://go.dev/doc/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Tour](https://go.dev/tour/)

---

**Note:** This file serves as an index. Click on the links above to explore each topic in detail.


