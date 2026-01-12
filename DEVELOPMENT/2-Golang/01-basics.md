# Go Basics

## Table of Contents
- [Basic Types](#basic-types)
- [Variables](#variables)
- [Operators](#operators)
- [Conditional Statements](#conditional-statements)
- [Loops](#loops)

## Basic Types

|    Type    |               Set of Values                |                    Values                     |
| :--------: | :----------------------------------------: | :-------------------------------------------: |
|    bool    |                  boolean                   |                  true/false                   |
|   string   |            array of characters             |             needs to be inside ""             |
|    int     |                  integers                  |             32 or 64 bit integer              |
|    int8    |               8-bit integers               |                 [ -128, 128 ]                 |
|   int16    |              16-bit integers               |               [ -32768, 32767]                |
|   int32    |              32-bit integers               |          [ -2147483648, 2147483647]           |
|   int64    |              64-bit integers               | [ -9223372036854775808, 9223372036854775807 ] |
|   uint8    |          8-bit unsigned integers           |                  [ 0, 255 ]                   |
|   uint16   |          16-bit unsigned integers          |                 [ 0, 65535 ]                  |
|   uint32   |          32-bit unsigned integers          |               [ 0, 4294967295 ]               |
|   uint64   |          64-bit unsigned integers          |          [ 0, 18446744073709551615 ]          |
|  float32   |                32-bit float                |                                               |
|  float64   |                64-bit float                |                                               |
| complex64  | 32-bit float with real and imaginary parts |                                               |
| complex128 | 64-bit float with real and imaginary parts |                                               |
|    byte    |                sets of bits                |                alias for uint8                |
|    rune    |             Unicode characters             |                alias for int32                |

## Variables

```go
// Declaration
var value int

// Initialization
value = 10

// Declaration + Initialization + Type inference
var isActive = true

// Short declaration (only inside functions)
text := "Hello"

// Multi declaration
var i, j, k = 1, 2, 3

// Variable not initialized = Zero values
// Numeric: 0
// Boolean: false
// String: ""
// Special value: nil (same as null)

var number int // 0
var text string // ""
var boolean bool // false

// Type conversions
// T(v) converts v to type T

i := 1.234 // float
int(i) // 1

// Constants
const pi = 3.1415
```

## Operators

### Arithmetic Operators
| Symbol | Operation | Valid Types |
|:---------:|:-------------:|:-------------:|
| `+` | Sum | integers, floats, complex values, strings |
| `-` | Difference | integers, floats, complex values |
| `*` | Product | integers, floats, complex values |
| `/` | Quotient | integers, floats, complex values |
| `%` | Remainder | integers |
| `&` | Bitwise AND | integers |
| `|` | Bitwise OR | integers |
| `^` | Bitwise XOR | integers |
| `&^` | Bit clear (AND NOT) | integers |
| `<<` | Left shift | integer << unsigned integer |
| `>>` | Right shift | integer >> unsigned integer |

### Comparison Operators
| Symbol | Operation |
|:---------:|:-------------:|
| `==` | Equal |
| `!=` | Not equal |
| `<` | Less |
| `<=` | Less or equal |
| `>` | Greater |
| `>=` | Greater or equal |

### Logical Operators
| Symbol | Operation |
|:---------:|:-------------:|
| `&&` | Conditional AND |
| `||` | Conditional OR |
| `!` | NOT |

## Conditional Statements

```go
// If / Else
i := 1

if i > 0 {
    // Condition is True! i is greater than zero
} else {
    // Condition is False! i is lower or equal to zero
}

// Else if
i := 1

if i > 0 {
    // Condition is True! i is greater than zero
} else if i > 0 && i < 2 {
    // Condition is True! i greater than zero and lower than two
} else if i > 1 && i < 4 {
    // Condition is True! i greater than one and lower than four
} else {
    // None of the above conditions is True, so it falls here
}

// If with short statements
i := 2.567

if j := int(i); j == 2 {
    // Condition is True! j, the integer value of i, is equal to two
} else {
    // Condition is False! j, the integer value of i, is not equal to two
}

// Switch
text := "hey"

switch text {
    case "hey":
        // 'Hello!'
    case "bye":
        // 'Byee'
    default:
        // 'Ok'
}

// Switch without condition
value := 5

switch {
    case value < 2:
        // 'Hello!'
    case value >= 2 && value < 6:
        // 'Byee'
    default:
        // 'Ok'
}
```

## Loops

```go
// Golang only has the for loop
for i := 0; i < 10; i++ {
    // i
}

// The first and third parameters are ommitable
// For as a while
i := 0;

for i < 10 {
    i++
}

// Forever loop
for {

}
```
