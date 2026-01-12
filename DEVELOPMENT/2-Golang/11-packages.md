# Standard Library Packages

## Package fmt

Formatted I/O with functions analogous to C's printf and scanf.

```go
import "fmt"

// Print to console
fmt.Print("Hello")           // No newline
fmt.Println("Hello World")   // With newline
fmt.Printf("Name: %s, Age: %d\n", "Alice", 25) // Formatted

// Format strings
s := fmt.Sprintf("User: %s", "Bob")

// Print errors
err := fmt.Errorf("error code: %d", 404)

// Scan input
var name string
fmt.Scan(&name)
fmt.Scanf("%s", &name)
```

### Format Verbs

```go
// General
%v    // Default format
%+v   // With field names (structs)
%#v   // Go-syntax representation
%T    // Type
%%    // Literal %

// Boolean
%t    // true or false

// Integer
%d    // Decimal
%b    // Binary
%o    // Octal
%x    // Hexadecimal (lowercase)
%X    // Hexadecimal (uppercase)

// Float
%f    // Decimal point
%e    // Scientific notation
%g    // Compact representation

// String
%s    // String
%q    // Quoted string
```

## Package strings

String manipulation functions.

```go
import "strings"

// Contains
strings.Contains("hello", "ll")  // true

// Count
strings.Count("cheese", "e")     // 3

// Split
strings.Split("a,b,c", ",")      // ["a", "b", "c"]

// Join
strings.Join([]string{"a", "b"}, "-")  // "a-b"

// Replace
strings.Replace("foo foo", "foo", "bar", 1)  // "bar foo"
strings.ReplaceAll("foo foo", "foo", "bar")  // "bar bar"

// Trim
strings.TrimSpace("  hello  ")   // "hello"
strings.Trim("!!!hello!!!", "!") // "hello"

// Case
strings.ToUpper("hello")         // "HELLO"
strings.ToLower("HELLO")         // "hello"

// Prefix/Suffix
strings.HasPrefix("hello", "he") // true
strings.HasSuffix("hello", "lo") // true
```

## Package strconv

String conversions.

```go
import "strconv"

// String to int
i, err := strconv.Atoi("42")

// Int to string
s := strconv.Itoa(42)

// Parse
b, _ := strconv.ParseBool("true")
f, _ := strconv.ParseFloat("3.14", 64)
i, _ := strconv.ParseInt("42", 10, 64)

// Format
s := strconv.FormatBool(true)
s := strconv.FormatFloat(3.14, 'f', 2, 64)
s := strconv.FormatInt(42, 10)
```

## Package time

Time and duration functions.

```go
import "time"

// Current time
now := time.Now()

// Create time
t := time.Date(2024, time.January, 1, 0, 0, 0, 0, time.UTC)

// Format time
now.Format("2006-01-02 15:04:05")
now.Format(time.RFC3339)

// Parse time
t, _ := time.Parse("2006-01-02", "2024-01-01")

// Duration
d := 5 * time.Second
time.Sleep(d)

// Add/Sub
future := now.Add(24 * time.Hour)
diff := future.Sub(now)

// Compare
now.Before(future)  // true
now.After(future)   // false
now.Equal(future)   // false
```

## Package os

Operating system functionality.

```go
import "os"

// Environment variables
os.Getenv("PATH")
os.Setenv("KEY", "value")

// File operations
file, err := os.Open("file.txt")
file, err := os.Create("file.txt")
os.Remove("file.txt")
os.Rename("old.txt", "new.txt")

// Directory operations
os.Mkdir("dir", 0755)
os.MkdirAll("path/to/dir", 0755)
os.Remove("dir")
os.RemoveAll("path/to/dir")

// Working directory
wd, _ := os.Getwd()
os.Chdir("/path")

// Exit
os.Exit(0)
```

## Package io

I/O primitives.

```go
import "io"

// Copy
io.Copy(dst, src)

// Read all
data, err := io.ReadAll(reader)

// Write string
io.WriteString(writer, "hello")

// Pipe
r, w := io.Pipe()
```

## Package json

JSON encoding and decoding.

```go
import "encoding/json"

type Person struct {
    Name string `json:"name"`
    Age  int    `json:"age"`
}

// Marshal (encode)
person := Person{Name: "Alice", Age: 25}
jsonData, _ := json.Marshal(person)
// {"name":"Alice","age":25}

// Unmarshal (decode)
var p Person
json.Unmarshal(jsonData, &p)

// Pretty print
jsonData, _ := json.MarshalIndent(person, "", "  ")
```

## Package http

HTTP client and server.

```go
import "net/http"

// HTTP server
http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hello"))
})
http.ListenAndServe(":8080", nil)

// HTTP client
resp, err := http.Get("https://api.example.com")
defer resp.Body.Close()
body, _ := io.ReadAll(resp.Body)

// POST request
resp, err := http.Post(url, "application/json", bytes.NewBuffer(data))
```

## Package log

Simple logging.

```go
import "log"

log.Print("message")
log.Printf("formatted %s", "message")
log.Println("message with newline")

log.Fatal("fatal error")  // Calls os.Exit(1)
log.Panic("panic")        // Calls panic()
```
