# Arrays and Slices

## Arrays

Arrays in Go have a fixed size that must be specified at declaration.

```go
// Declaration with specified size
var array [3]string
array[0] = "Hello"
array[1] = "Golang"
array[2] = "World"

// Declaration and Initialization
values := [5]int{1, 2, 3, 4, 5}

// Array with inferred size
values := [...]int{1, 2, 3, 4, 5}
```

## Slices

Slices are dynamic arrays that can grow and shrink. They are references to underlying arrays.

### Creating Slices

```go
// Slice from array
values := [5]int{1, 2, 3, 4, 5}

// Determining min and max
values[1:3] // {2, 3}

// Determining only max will use min = 0
values[:2] // {1, 2}

// Determining only min will use max = last element
values[3:] // {4, 5}

// Slice literal
slice := []bool{true, true, false}

// make function: create a slice with length and capacity
slice := make([]int, 5, 6) // make(type, len, cap)
```

### Length and Capacity

```go
values := []int{1, 2, 3, 4, 5}

// Length: number of elements that a slice contains
len(values) // 5

// Capacity: number of elements that a slice can contain
cap(values) // 5

// Reslicing
values = values[:2]
len(values) // 2
cap(values) // 5 (capacity remains the same)
```

### Appending to Slices

```go
// Append new element to slice
slice := []int{1, 2}
slice = append(slice, 3)
slice // {1, 2, 3}

// Append multiple elements
slice = append(slice, 3, 2, 1)
slice // {1, 2, 3, 3, 2, 1}

// Append another slice
slice1 := []int{1, 2}
slice2 := []int{3, 4}
slice1 = append(slice1, slice2...)
slice1 // {1, 2, 3, 4}
```

### Iterating Over Slices

```go
// For range: iterate over a slice
slice := []string{"W", "o", "w"}

for i, value := range slice {
    i // 0, then 1, then 2
    value // "W", then "o", then "w"
}

// Skip index
for _, value := range slice {
   value // "W", then "o", then "w"
}

// Skip value
for i := range slice {
    i // 0, then 1, then 2
}
```

### Copying Slices

```go
// Copy slice
source := []int{1, 2, 3}
destination := make([]int, len(source))
copy(destination, source)
destination // {1, 2, 3}
```

### Multi-dimensional Slices

```go
// 2D slice
matrix := [][]int{
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
}

matrix[0][1] // 2
matrix[2][0] // 7
```

## Common Slice Operations

```go
// Remove element at index i
slice := []int{1, 2, 3, 4, 5}
i := 2
slice = append(slice[:i], slice[i+1:]...)
slice // {1, 2, 4, 5}

// Insert element at index i
slice := []int{1, 2, 4, 5}
i := 2
value := 3
slice = append(slice[:i], append([]int{value}, slice[i:]...)...)
slice // {1, 2, 3, 4, 5}

// Filter slice
numbers := []int{1, 2, 3, 4, 5, 6}
var evens []int
for _, n := range numbers {
    if n%2 == 0 {
        evens = append(evens, n)
    }
}
evens // {2, 4, 6}
```
