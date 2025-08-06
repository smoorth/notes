# 30-Day Python Microlearning Plan

## Table of Contents

- [30-Day Python Microlearning Plan](#30-day-python-microlearning-plan)
  - [Table of Contents](#table-of-contents)
  - [Day 1: What is Python?](#day-1-what-is-python)
  - [Day 2: Variables](#day-2-variables)
  - [Day 3: Basic Math](#day-3-basic-math)
  - [Day 4: Print Statements](#day-4-print-statements)
  - [Day 5: Operators](#day-5-operators)
  - [Day 6: If Statements (Conditions)](#day-6-if-statements-conditions)
  - [Day 7: Loops (For \& While)](#day-7-loops-for--while)
  - [Day 8: Lists (Create \& Access)](#day-8-lists-create--access)
  - [Day 9: Dictionaries (Key-Value Pairs)](#day-9-dictionaries-key-value-pairs)
  - [Day 10: Functions (Define \& Use)](#day-10-functions-define--use)
  - [Day 11: Read \& Write Files](#day-11-read--write-files)
  - [Day 12: Error Handling (Try-Except)](#day-12-error-handling-try-except)
  - [Day 13: List Comprehensions](#day-13-list-comprehensions)
  - [Day 14: Strings (Format \& Manipulate)](#day-14-strings-format--manipulate)
  - [Day 15: Time \& Datetime](#day-15-time--datetime)
  - [Day 16: Modules](#day-16-modules)
  - [Day 17: Objects \& Classes (OOP Basics)](#day-17-objects--classes-oop-basics)
  - [Day 18: Get Data from APIs](#day-18-get-data-from-apis)
  - [Day 19: Data Analysis with Pandas](#day-19-data-analysis-with-pandas)
  - [Day 20: Mini-Project (Combine Skills)](#day-20-mini-project-combine-skills)
  - [Day 21: Tuples \& Sets](#day-21-tuples--sets)
  - [Day 22: Advanced OOP (Inheritance \& Polymorphism)](#day-22-advanced-oop-inheritance--polymorphism)
  - [Day 23: Regular Expressions](#day-23-regular-expressions)
  - [Day 24: Virtual Environments \& Packaging](#day-24-virtual-environments--packaging)
  - [Day 25: Debugging \& Logging](#day-25-debugging--logging)
  - [Day 26: Testing](#day-26-testing)
  - [Day 27: Concurrency \& Threading](#day-27-concurrency--threading)
  - [Day 28: Generator Functions \& yield](#day-28-generator-functions--yield)
  - [Day 29: Decorators](#day-29-decorators)
  - [Day 30: Final Mini-Project or Wrap-Up](#day-30-final-mini-project-or-wrap-up)

## Day 1: What is Python?

**Goal:** Understand what Python is and how to run it.

**What to Learn:**

Python as a high-level, interpreted language.

Use cases (web dev, data analysis, scripting, etc.).

Basic setup (run Python locally or in an online environment like Replit or Google Colab).

**Example Activity:**

```python
import sys
print("Hello, Python!")
print("Python version:", sys.version)
```

**Task:** Print a short introduction about yourself to confirm Python is running correctly.

## Day 2: Variables

**Goal:** Learn how to store and reference data in Python.

**What to Learn:**

Variable naming conventions (snake_case).

Assigning values (x = 10, name = "Alice").

Dynamic typing in Python.

**Example Activity:**

```python
age = 25
name = "Alice"
is_student = True

print("Name:", name)
print("Age:", age)
print("Is Student:", is_student)
```

**Task:** Modify these variables and print them again.

## Day 3: Basic Math

**Goal:** Perform arithmetic and understand numeric types.

**What to Learn:**

Arithmetic operators: + - * / // % **

Integer vs. float division (/ vs. //)

Order of operations

**Example Activity:**

```python
a = 5
b = 2

print("Addition:", a + b)
print("Division (float):", a / b)
print("Floor Division (int):", a // b)
print("Exponent:", a ** b)
```

**Task:** Change values of a and b and see how the results change.

## Day 4: Print Statements

**Goal:** Explore printing and basic output formatting.

**What to Learn:**

print() function usage

Concatenating strings and variables

Basic string formatting (f-strings, format())

**Example Activity:**

```python
name = "Alice"
age = 25

# Using f-strings
print(f"My name is {name} and I am {age} years old.")

# Using string concatenation
print("My name is " + name + " and I am " + str(age) + " years old.")
```

**Task:** Experiment with different string formatting methods to display your own text.

## Day 5: Operators

**Goal:** Use comparison, logical, and assignment operators.

**What to Learn:**

Comparison operators: ==, !=, >, <, >=, <=

Logical operators: and, or, not

Assignment operators: +=, -=, etc.

**Example Activity:**

```python
x = 10
y = 3

print("x == y:", x == y)
print("x > y:", x > y)
print("x < y:", x < y)

# Logical operators
print("True and False:", True and False)
print("True or False:", True or False)
```

**Task:** Create a small expression using and, or, and not to see different outcomes.

## Day 6: If Statements (Conditions)

**Goal:** Control flow with conditional statements.

**What to Learn:**

if, elif, else structure

Importance of indentation in Python

**Example Activity:**

```python
number = 7

if number > 10:
    print("Number is greater than 10")
elif number == 10:
    print("Number is exactly 10")
else:
    print("Number is less than 10")
```

**Task:** Change number to test different branches.

## Day 7: Loops (For & While)

**Goal:** Automate repetitive tasks using loops.

**What to Learn:**

for loops (iterating over sequences)

while loops (repeating until a condition changes)

Loop control statements: break, continue

**Example Activity:**

```python
# For loop
fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)

# While loop
count = 0
while count < 3:
    print("Count is:", count)
    count += 1
```

**Task:** Use break or continue in a loop to see how it changes the flow.

## Day 8: Lists (Create & Access)

**Goal:** Store ordered data in lists and learn basic manipulation.

**What to Learn:**

Creating lists

Indexing and slicing

Adding/removing items (append, remove, pop)

**Example Activity:**

```python
my_list = [10, 20, 30, 40]
print("First item:", my_list[0])
print("Last item:", my_list[-1])

my_list.append(50)
print("After append:", my_list)

my_list.pop()
print("After pop:", my_list)
```

**Task:** Slice the list to get the middle elements.

## Day 9: Dictionaries (Key-Value Pairs)

**Goal:** Store data in key-value pairs and learn how to access them.

**What to Learn:**

Creating dictionaries

Accessing values by keys

Adding/updating/removing key-value pairs

**Example Activity:**

```python
person = {
    "name": "Alice",
    "age": 25,
    "city": "New York"
}
print("Name:", person["name"])

person["age"] = 26
person["country"] = "USA"
print("Updated dictionary:", person)
```

**Task:** Access a non-existent key and handle it with .get().

## Day 10: Functions (Define & Use)

**Goal:** Write reusable blocks of code.

**What to Learn:**

Defining a function with def

Parameters and return values

Basic scope (local vs. global variables)

**Example Activity:**

```python
def greet(name):
    return f"Hello, {name}!"

message = greet("Alice")
print(message)
```

**Task:** Write a function that takes two numbers and returns their sum.

## Day 11: Read & Write Files

**Goal:** Interact with external text files.

**What to Learn:**

Opening files in different modes ("r", "w", "a")

Reading file contents (.read(), .readlines())

Writing to files

**Example Activity:**

```python
# Write to a file
with open("sample.txt", "w") as f:
    f.write("Hello World!\nThis is a test.")

# Read from the file
with open("sample.txt", "r") as f:
    content = f.read()
    print(content)
```

**Task:** Modify the file content and observe the changes.

## Day 12: Error Handling (Try-Except)

**Goal:** Manage exceptions and keep your program running smoothly.

**What to Learn:**

try-except blocks

Catching specific vs. general exceptions

Using finally if needed

**Example Activity:**

```python
try:
    number = int(input("Enter a number: "))
    print("You entered:", number)
except ValueError:
    print("That was not a valid number!")
finally:
    print("End of try-except block.")
```

**Task:** Trigger different exceptions by entering invalid inputs.

## Day 13: List Comprehensions

**Goal:** Create lists in a concise, Pythonic way.

**What to Learn:**

Basic syntax: [expression for item in iterable if condition]

Filtering and transforming list items

**Example Activity:**

```python
numbers = [1, 2, 3, 4, 5]
squares = [x**2 for x in numbers]
even_numbers = [x for x in numbers if x % 2 == 0]

print("Squares:", squares)
print("Even numbers:", even_numbers)
```

**Task:** Create a list of words from another list, but only keep words starting with a certain letter.

## Day 14: Strings (Format & Manipulate)

**Goal:** Work with text effectively.

**What to Learn:**

String methods: .upper(), .lower(), .split(), .replace()

Trimming whitespace: .strip()

Advanced formatting with f-strings

**Example Activity:**

```python
text = "  Hello Python  "
print("Original:", text)
print("Upper:", text.upper())
print("Lower:", text.lower())
print("Strip:", text.strip())
print("Replace:", text.replace("Python", "World"))
```

**Task:** Split a sentence into words and rejoin them with commas.

## Day 15: Time & Datetime

**Goal:** Work with dates, times, and durations.

**What to Learn:**

time module basics

datetime module for current time, date manipulation

Formatting dates with strftime/strptime

**Example Activity:**

```python
import datetime

now = datetime.datetime.now()
print("Current date and time:", now)

formatted = now.strftime("%Y-%m-%d %H:%M:%S")
print("Formatted:", formatted)
```

**Task:** Parse a string date into a datetime object and print the day of the week.

## Day 16: Modules

**Goal:** Organize code and use external libraries.

**What to Learn:**

Importing modules (import math)

Using specific functions (from math import sqrt)

Creating your own module (optional)

**Example Activity:**

```python
import math

num = 16
print("Square root of 16:", math.sqrt(num))
```

**Task:** Explore other math functions like pow, sin, cos.

## Day 17: Objects & Classes (OOP Basics)

**Goal:** Understand object-oriented programming fundamentals.

**What to Learn:**

Defining a class with class

Constructor method __init__()

Creating instances (objects)

**Example Activity:**

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def greet(self):
        print(f"Hello, my name is {self.name} and I am {self.age} years old.")

p1 = Person("Alice", 25)
p1.greet()
```

**Task:** Add another method or attribute to the class.

## Day 18: Get Data from APIs

**Goal:** Fetch external data using HTTP requests.

**What to Learn:**

requests library (or urllib.request if requests not available)

Parsing JSON data with the json module

**Example Activity:**

```python
import requests

url = "https://api.github.com"
response = requests.get(url)
if response.status_code == 200:
    data = response.json()
    print("API data:", data)
else:
    print("Failed to fetch data. Status code:", response.status_code)
```

**Task:** Try accessing another public API (e.g., an open weather API) and print a specific piece of data.

## Day 19: Data Analysis with Pandas

**Goal:** Get a quick glimpse of data manipulation in Python.

**What to Learn:**

Installing/using Pandas (pip install pandas)

Reading CSV data

Basic data inspection (.head(), .describe())

**Example Activity:**

```python
import pandas as pd

data = {
    "Name": ["Alice", "Bob", "Charlie"],
    "Age": [25, 30, 35],
    "City": ["NY", "LA", "Chicago"]
}

df = pd.DataFrame(data)
print(df)
print(df.describe())
```

**Task:** Filter rows by a condition (e.g., df[df["Age"] > 25]).

## Day 20: Mini-Project (Combine Skills)

**Goal:** Use everything you’ve learned so far in a small project.

What to Build:

A short script that:

Reads data from a file (or fetches from an API).

Processes it (using loops, conditions, or Pandas).

Prints or visualizes a small result.

**Example (Simple Weather Reporter):**

```python
import requests

def get_weather():
    # Demo: open-meteo free endpoint (adjust lat/long as needed)
    url = "https://api.open-meteo.com/v1/forecast?latitude=35&longitude=139&hourly=temperature_2m"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        print(data["hourly"]["temperature_2m"][:5])  # First 5 data points
    else:
        print("Error fetching weather data.")

if __name__ == "__main__":
    get_weather()
```

**Task:** Adapt it to your own idea—e.g., read a local CSV, compute something, then print results or a chart.

## Day 21: Tuples & Sets

**Goal:** Learn about immutable sequences (tuples) and unique collections (sets).

**What to Learn:**

Tuples: Immutable sequences

Sets: Unordered collections of unique elements

Set operations (union, intersection, etc.)

**Example Activity:**

```python
# Tuples
my_tuple = (10, 20, 30)
print("First element of tuple:", my_tuple[0])
# my_tuple[0] = 15  # This will raise an error (tuples are immutable)

# Sets
my_set = {1, 2, 3, 2}
print("Set content (unique):", my_set)
my_set.add(4)
print("After adding 4:", my_set)
```

**Task:** Practice set methods like .difference() or .intersection().

## Day 22: Advanced OOP (Inheritance & Polymorphism)

**Goal:** Dive deeper into OOP features.

**What to Learn:**

Inheritance: Child class from a parent class

Method overriding and polymorphism

**Example Activity:**

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        print("Some generic animal sound")

class Dog(Animal):
    def speak(self):
        print("Woof!")

class Cat(Animal):
    def speak(self):
        print("Meow!")

animals = [Dog("Rex"), Cat("Whiskers")]
for animal in animals:
    animal.speak()  # Polymorphic call
```

**Task:** Create another subclass (e.g., Bird) and override speak().

## Day 23: Regular Expressions

**Goal:** Use the re module for pattern matching.

**What to Learn:**

Common regex patterns (\d, \w, ^, $, etc.)

Searching, matching, replacing text

**Example Activity:**

```python
import re

text = "My phone number is 123-456-7890."
pattern = r"\d{3}-\d{3}-\d{4}"
match = re.search(pattern, text)

if match:
    print("Found phone number:", match.group())
else:
    print("No match found.")
```

**Task:** Write a regex to find all email addresses in a string.

## Day 24: Virtual Environments & Packaging

**Goal:** Learn to isolate project dependencies.

**What to Learn:**

Why virtual environments?

Creating and activating a venv (python -m venv venv)

Basic packaging (pip install, requirements.txt)

**Example Activity (Command-line example):**

```bash
# Unix/macOS
python3 -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
venv\Scripts\activate

pip install requests
pip freeze > requirements.txt
```

**Task:** Create a virtual environment, install a library, and list dependencies.

## Day 25: Debugging & Logging

**Goal:** Diagnose issues and track program behavior.

**What to Learn:**

Debugging with print statements or an IDE/debugger

Using the built-in logging module (DEBUG, INFO, WARNING, ERROR, CRITICAL)

**Example Activity:**

```python
import logging

logging.basicConfig(level=logging.INFO)

def divide(a, b):
    logging.debug(f"divide called with a={a}, b={b}")
    try:
        result = a / b
        logging.info(f"Result: {result}")
        return result
    except ZeroDivisionError:
        logging.error("Attempted to divide by zero!")
        return None

divide(10, 2)
divide(5, 0)
```

**Task:** Experiment with different logging levels and messages.

## Day 26: Testing

**Goal:** Write tests to ensure code reliability.

**What to Learn:**

Unit testing with unittest or pytest

Writing test cases

Basic assertions

Example Activity (using unittest):

```python
# my_code.py
def add_numbers(a, b):
    return a + b

# test_my_code.py
import unittest
from my_code import add_numbers

class TestMyCode(unittest.TestCase):
    def test_add_numbers(self):
        self.assertEqual(add_numbers(2, 3), 5)
        self.assertNotEqual(add_numbers(2, 3), 6)

if __name__ == "__main__":
    unittest.main()
```

**Task:** Add more test cases for edge scenarios (e.g., negative numbers, zero).

## Day 27: Concurrency & Threading

**Goal:** Run parts of your program in parallel.

**What to Learn:**

Threading basics in Python

The Global Interpreter Lock (GIL)

When threading is beneficial

**Example Activity:**

```python
import threading
import time

def worker(name):
    print(f"Starting worker: {name}")
    time.sleep(1)
    print(f"Worker {name} done.")

thread1 = threading.Thread(target=worker, args=("Thread-1",))
thread2 = threading.Thread(target=worker, args=("Thread-2",))

thread1.start()
thread2.start()
thread1.join()
thread2.join()
print("All threads finished.")
```

**Task:** Experiment with multiple threads and observe the output order.

## Day 28: Generator Functions & yield

**Goal:** Create iterators for memory-efficient data processing.

**What to Learn:**

Writing generator functions with yield

Benefits of generators vs. normal functions

**Example Activity:**

```python
def countdown(n):
    while n > 0:
        yield n
        n -= 1

for number in countdown(5):
    print(number)
```

**Task:** Write a generator that yields even numbers in a range.

## Day 29: Decorators

**Goal:** Modify function behavior without changing the function code.

**What to Learn:**

Function decorators (@decorator_name)

How decorators wrap a function

**Example Activity:**

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        print("Before the function call")
        result = func(*args, **kwargs)
        print("After the function call")
        return result
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()
```

**Task:** Create a decorator that measures how long a function takes to run.

## Day 30: Final Mini-Project or Wrap-Up

**Goal:** Combine advanced topics in a final project.

What to Build (Idea):

A small CLI or simple web app that:

Fetches data from an API **(Day 18)**.

Uses a generator **(Day 28)** to process data in chunks.

Logs the process with logging **(Day 25)**.

Has a simple test file **(Day 26)** to validate main functions.

**Stretch Goal:**

Use a virtual environment **(Day 24)** and package your project with requirements.txt.
