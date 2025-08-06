# Getting Started with Python Functions

## Introduction

Python is a powerful and easy-to-learn programming language. One of the most important features of Python is **functions**, which allow you to organize code into reusable blocks.

## What is a Function?

A function is a block of code that performs a specific task. It helps to:

- Organize code into smaller parts
- Avoid repetition
- Make code easier to read and maintain

## Defining a Function

In Python, you define a function using the `def` keyword.

```python
def function_name(parameters):
    """Optional docstring describing the function."""
    # Function body
    return result  # Optional
```

```python
def greet(name):
    """This function greets the user by name."""
    print(f"Hello, {name}!")

# Calling the function
greet("Alice")
```

**Output:**

```code
Hello, Alice!
```

## Function Parameters and Arguments

Functions can take inputs called **parameters**.

```python
def add_numbers(a, b):
    """Returns the sum of two numbers."""
    return a + b

# Calling the function
result = add_numbers(3, 5)
print(result)
```

**Output:**

```code
8
```

## Default Parameters

You can set default values for parameters.

```python
def greet(name="Guest"):
    print(f"Hello, {name}!")

greet()  # Uses default value
greet("Bob")  # Overrides default value
```

**Output:**

```code
Hello, Guest!
Hello, Bob!
```

## Returning Values

Functions can return results using `return`.

```python
def square(number):
    return number * number

print(square(4))
```

**Output:**

```code
16
```

## Variable Scope

Variables inside a function are **local** to that function unless specified otherwise.

```python
def example():
    x = 10  # Local variable
    print(x)

example()
# print(x)  # This would cause an error because x is not defined outside the function
```

## Lambda Functions (Anonymous Functions)

A **lambda function** is a small, one-line function.

```python
square = lambda x: x * x
print(square(5))
```

**Output:**

```code
25
```

## Recursion

A function can call itself. This is called **recursion**.

```python
def factorial(n):
    if n == 1:
        return 1
    return n * factorial(n - 1)

print(factorial(5))
```

**Output:**

```code
120
```

## Conclusion

Functions are a core part of Python that help in writing clean, modular, and reusable code. Mastering functions will improve your ability to write efficient and scalable programs.

### Next Steps

- Practice writing functions with different parameters and return values.
- Learn about built-in Python functions.
- Explore advanced topics like function decorators and higher-order functions.
