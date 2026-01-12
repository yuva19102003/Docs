# Concurrency

One of Go's main features is its built-in support for concurrency using goroutines and channels.

## Goroutines

Goroutines are lightweight threads managed by the Go runtime.

### Basic Goroutines

```go
func show(from string) {
    for i := 0; i < 3; i++ {
        fmt.Printf("%s : %d\n", from, i)
    }
}

// Sequential execution
func main() {
    show("blocking1")
    show("blocking2")
    fmt.Println("done")
}
// Output:
// blocking1: 0
// blocking1: 1
// blocking1: 2
// blocking2: 0
// blocking2: 1
// blocking2: 2
// done

// Concurrent execution with goroutines
func main() {
    go show("routine1")
    go show("routine2")
    
    go func() {
        fmt.Println("anonymous goroutine")
    }()
    
    time.Sleep(time.Second) // Wait for goroutines
    fmt.Println("done")
}
// Output (order may vary):
// routine2: 0
// routine1: 0
// anonymous goroutine
// routine2: 1
// routine1: 1
// routine2: 2
// routine1: 2
// done
```

## Channels

Channels are used to communicate between goroutines.

### Creating Channels

```go
// Create a channel
messages := make(chan string)

// Send value to channel
messages <- "ping"

// Receive value from channel
msg := <-messages
```

### Basic Channel Example

```go
func main() {
    messages := make(chan string)
    
    go func() {
        messages <- "ping"
    }()
    
    msg := <-messages
    fmt.Println(msg) // ping
}
```

### Buffered Channels

```go
// Unbuffered channel (blocks until received)
ch := make(chan int)

// Buffered channel (can hold N values)
ch := make(chan int, 2)

ch <- 1
ch <- 2
// ch <- 3 // Would block until a value is received

fmt.Println(<-ch) // 1
fmt.Println(<-ch) // 2
```

### Channel Directions

```go
// Send-only channel
func sender(ch chan<- string) {
    ch <- "hello"
}

// Receive-only channel
func receiver(ch <-chan string) {
    msg := <-ch
    fmt.Println(msg)
}

func main() {
    ch := make(chan string)
    go sender(ch)
    receiver(ch)
}
```

### Closing Channels

```go
func main() {
    ch := make(chan int, 3)
    
    ch <- 1
    ch <- 2
    ch <- 3
    
    close(ch) // Close the channel
    
    // Receive all values
    for value := range ch {
        fmt.Println(value)
    }
    // Output: 1, 2, 3
}

// Check if channel is closed
value, ok := <-ch
if !ok {
    fmt.Println("Channel is closed")
}
```

## Select Statement

Select lets you wait on multiple channel operations.

```go
func main() {
    c1 := make(chan string)
    c2 := make(chan string)
    
    go func() {
        time.Sleep(1 * time.Second)
        c1 <- "one"
    }()
    
    go func() {
        time.Sleep(2 * time.Second)
        c2 <- "two"
    }()
    
    for i := 0; i < 2; i++ {
        select {
        case msg1 := <-c1:
            fmt.Println("received", msg1)
        case msg2 := <-c2:
            fmt.Println("received", msg2)
        }
    }
}
// Output:
// received one
// received two
```

### Select with Default

```go
select {
case msg := <-messages:
    fmt.Println("received", msg)
default:
    fmt.Println("no message received")
}
```

### Select with Timeout

```go
select {
case msg := <-messages:
    fmt.Println("received", msg)
case <-time.After(1 * time.Second):
    fmt.Println("timeout")
}
```

## WaitGroups

WaitGroups wait for a collection of goroutines to finish.

```go
import "sync"

func worker(id int, wg *sync.WaitGroup) {
    defer wg.Done() // Decrement counter when done
    
    fmt.Printf("Worker %d starting\n", id)
    time.Sleep(time.Second)
    fmt.Printf("Worker %d done\n", id)
}

func main() {
    var wg sync.WaitGroup
    
    for i := 1; i <= 5; i++ {
        wg.Add(1) // Increment counter
        go worker(i, &wg)
    }
    
    wg.Wait() // Block until counter is 0
    fmt.Println("All workers done")
}
```

## Mutexes

Mutexes provide safe access to shared data.

```go
import "sync"

type Counter struct {
    mu    sync.Mutex
    value int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

func (c *Counter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.value
}

func main() {
    counter := Counter{}
    var wg sync.WaitGroup
    
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }
    
    wg.Wait()
    fmt.Println(counter.Value()) // 1000
}
```

## Worker Pools

```go
func worker(id int, jobs <-chan int, results chan<- int) {
    for job := range jobs {
        fmt.Printf("Worker %d processing job %d\n", id, job)
        time.Sleep(time.Second)
        results <- job * 2
    }
}

func main() {
    jobs := make(chan int, 100)
    results := make(chan int, 100)
    
    // Start 3 workers
    for w := 1; w <= 3; w++ {
        go worker(w, jobs, results)
    }
    
    // Send 5 jobs
    for j := 1; j <= 5; j++ {
        jobs <- j
    }
    close(jobs)
    
    // Collect results
    for a := 1; a <= 5; a++ {
        <-results
    }
}
```

## Rate Limiting

```go
func main() {
    requests := make(chan int, 5)
    for i := 1; i <= 5; i++ {
        requests <- i
    }
    close(requests)
    
    // Rate limiter: 1 request per 200ms
    limiter := time.Tick(200 * time.Millisecond)
    
    for req := range requests {
        <-limiter // Wait for limiter
        fmt.Println("request", req, time.Now())
    }
}
```

## Context

Context carries deadlines, cancellation signals, and request-scoped values.

```go
import "context"

func worker(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            fmt.Println("Worker cancelled")
            return
        default:
            fmt.Println("Working...")
            time.Sleep(500 * time.Millisecond)
        }
    }
}

func main() {
    ctx, cancel := context.WithCancel(context.Background())
    
    go worker(ctx)
    
    time.Sleep(2 * time.Second)
    cancel() // Cancel the context
    
    time.Sleep(1 * time.Second)
}
```

### Context with Timeout

```go
func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()
    
    go worker(ctx)
    
    <-ctx.Done()
    fmt.Println("Main: context cancelled")
}
```

## Atomic Operations

```go
import "sync/atomic"

func main() {
    var counter int64
    var wg sync.WaitGroup
    
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            atomic.AddInt64(&counter, 1)
        }()
    }
    
    wg.Wait()
    fmt.Println(atomic.LoadInt64(&counter)) // 1000
}
```

## Common Patterns

### Fan-Out, Fan-In

```go
func producer(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        for _, n := range nums {
            out <- n
        }
        close(out)
    }()
    return out
}

func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        for n := range in {
            out <- n * n
        }
        close(out)
    }()
    return out
}

func main() {
    // Fan-out
    in := producer(1, 2, 3, 4)
    
    // Multiple workers
    c1 := square(in)
    c2 := square(in)
    
    // Fan-in
    for n := range merge(c1, c2) {
        fmt.Println(n)
    }
}

func merge(cs ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup
    
    for _, c := range cs {
        wg.Add(1)
        go func(ch <-chan int) {
            defer wg.Done()
            for n := range ch {
                out <- n
            }
        }(c)
    }
    
    go func() {
        wg.Wait()
        close(out)
    }()
    
    return out
}
```

## Best Practices

1. **Don't communicate by sharing memory; share memory by communicating**
2. **Always close channels from the sender side**
3. **Use buffered channels carefully** - they can hide deadlocks
4. **Use context for cancellation** and timeouts
5. **Avoid goroutine leaks** - ensure goroutines can exit
6. **Use WaitGroups** to wait for goroutines
7. **Protect shared state** with mutexes or channels
8. **Keep critical sections small** when using mutexes
