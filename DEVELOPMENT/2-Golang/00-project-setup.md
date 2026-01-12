# Go Project Setup Guide

## Table of Contents
- [Prerequisites](#prerequisites)
- [Creating a New Project](#creating-a-new-project)
- [Installing Packages](#installing-packages)
- [Creating Packages](#creating-packages)
- [Running and Building](#running-and-building)
- [Docker Build](#docker-build)
- [Multi-Stage Docker Build](#multi-stage-docker-build)

## Prerequisites

Ensure Go is installed on your system:

```bash
# Check Go version
go version

# View Go environment variables
go env
```

## Creating a New Project

### Initialize a New Module

```bash
# Create project directory
mkdir my-go-project
cd my-go-project

# Initialize Go module
go mod init github.com/username/my-go-project
```

**Module Naming Convention:**
- Format: `domain.com/user/module/package`
- Example: `github.com/spf13/cobra`

This creates a `go.mod` file that tracks your dependencies.

### Project Structure

```
my-go-project/
├── go.mod              # Module definition and dependencies
├── go.sum              # Dependency checksums
├── main.go             # Entry point
├── cmd/                # Command-line applications
├── internal/           # Private application code
├── pkg/                # Public library code
└── vendor/             # Vendored dependencies (optional)
```

### Basic Hello World

Create `main.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
```

## Installing Packages

### Install External Dependencies

```bash
# Add a dependency and install it
go get github.com/gin-gonic/gin

# Install a specific version
go get github.com/gin-gonic/gin@v1.9.0

# Install all dependencies from go.mod
go mod download

# Update dependencies
go get -u ./...

# Tidy up dependencies (remove unused)
go mod tidy
```

### Vendor Dependencies (Optional)

```bash
# Copy dependencies to vendor/ directory
go mod vendor
```

## Creating Packages

### Local Package

**1. Create a local package directory:**

```bash
mkdir -p pkg/calculator
```

**2. Create package file `pkg/calculator/calculator.go`:**

```go
package calculator

// Add returns the sum of two integers
func Add(a, b int) int {
    return a + b
}

// Multiply returns the product of two integers
func Multiply(a, b int) int {
    return a * b
}
```

**3. Use the local package in `main.go`:**

```go
package main

import (
    "fmt"
    "github.com/username/my-go-project/pkg/calculator"
)

func main() {
    result := calculator.Add(5, 3)
    fmt.Println("5 + 3 =", result)
}
```

### Remote Package (Publishing)

**1. Create a GitHub repository:**
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/my-go-project.git
git push -u origin main
```

**2. Tag a version:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**3. Others can now install your package:**
```bash
go get github.com/username/my-go-project
```

### Package Visibility Rules

- **Exported (Public):** Start with uppercase letter
  ```go
  func PublicFunction() {}  // Accessible from other packages
  ```

- **Unexported (Private):** Start with lowercase letter
  ```go
  func privateFunction() {}  // Only accessible within the package
  ```

## Running and Building

### Run Code Directly

```bash
# Run main.go
go run main.go

# Run with multiple files
go run main.go utils.go

# Run all files in current directory
go run .
```

### Build Executable

```bash
# Build for current platform
go build

# Build with custom output name
go build -o myapp

# Build for specific package
go build ./cmd/myapp

# Build with optimizations (smaller binary)
go build -ldflags="-s -w" -o myapp
```

### Cross-Platform Builds

```bash
# Build for Linux
GOOS=linux GOARCH=amd64 go build -o myapp-linux

# Build for Windows
GOOS=windows GOARCH=amd64 go build -o myapp.exe

# Build for macOS
GOOS=darwin GOARCH=amd64 go build -o myapp-mac

# Build for ARM (Raspberry Pi, etc.)
GOOS=linux GOARCH=arm64 go build -o myapp-arm
```

### Install Binary

```bash
# Install to $GOPATH/bin
go install

# The binary will be available globally if $GOPATH/bin is in your PATH
```

## Docker Build

### Basic Dockerfile

Create `Dockerfile`:

```dockerfile
# Use official Go image
FROM golang:1.21-alpine

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN go build -o main .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./main"]
```

### Build and Run

```bash
# Build Docker image
docker build -t my-go-app:latest .

# Run container
docker run -p 8080:8080 my-go-app:latest

# Run with environment variables
docker run -p 8080:8080 -e ENV=production my-go-app:latest
```

## Multi-Stage Docker Build

Multi-stage builds create smaller, more secure images by separating the build and runtime environments.

### Optimized Multi-Stage Dockerfile

Create `Dockerfile`:

```dockerfile
# Stage 1: Build
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application with optimizations
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-s -w" -o main .

# Stage 2: Runtime
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /home/appuser

# Copy binary from builder
COPY --from=builder /app/main .

# Change ownership
RUN chown -R appuser:appuser /home/appuser

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Run the application
CMD ["./main"]
```

### Build Flags Explained

- `CGO_ENABLED=0`: Disable CGO for static binary
- `-a`: Force rebuilding of packages
- `-installsuffix cgo`: Add suffix to package directory
- `-ldflags="-s -w"`: Strip debug info and symbol table (smaller binary)

### Build and Run Multi-Stage

```bash
# Build multi-stage image
docker build -t my-go-app:latest .

# Check image size (should be much smaller)
docker images my-go-app

# Run container
docker run -p 8080:8080 my-go-app:latest
```

### Docker Compose Example

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - ENV=production
      - PORT=8080
    restart: unless-stopped
```

Run with Docker Compose:

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Additional Commands

```bash
# Format code
go fmt ./...

# Lint code (requires golangci-lint)
golangci-lint run

# Run tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# List all packages
go list ./...

# Clean build cache
go clean -cache
```

## Best Practices

1. **Always use `go mod tidy`** after adding/removing dependencies
2. **Use semantic versioning** for releases (v1.0.0, v1.1.0, etc.)
3. **Keep binaries small** with build flags: `-ldflags="-s -w"`
4. **Use multi-stage Docker builds** for production
5. **Run as non-root user** in Docker containers
6. **Vendor dependencies** for reproducible builds
7. **Use `.dockerignore`** to exclude unnecessary files

### .dockerignore Example

```
.git
.gitignore
README.md
*.md
.env
.vscode
.idea
vendor/
```
