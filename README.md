**Version:** 2.0.0

# errTest

A testing library for Lua scripts.

For a usage example, please see the test script for [utf8Tools](https://github.com/rabbitboots/utf8_tools).


# API


## errTest.new

Creates a new tester instance.

`local test = errTest.new([name], [verbosity])`

* `name`: (string) An optional test name.

* `verbosity`: (number) The test's output verbosity level when printing to the terminal.

**Returns:** The tester object.


**Notes:**

* The verbosity levels are:
  * `0`: nothing
  * `1`: final results
  * `2`: + test names, test results, warnings
  * `3`: + job headers
  * `4`: + all job output
  * `5`: + messages from built-in assertions


# Tester: Setup and Configuration

## Tester:registerFunction

Registers a function (which is *to be tested*) with a human-readable name, or removes the function from the tester's registry.

`Tester:registerFunction([label], func)`

* `[label]`: (string) The name to assign the function, or `nil` to remove the function from the registry.

* `func`: (function) The function to register or remove.


## Tester:registerJob

Registers a job function (which will *conduct tests*) with an optional human-readable name.

`Tester:registerJob([desc], func)`

* `[desc]` (string) Optional description to print when running the job.

* `func` (function) The job function.


**Notes:**

* Running a specific job function more than once in a test is treated as an error.


## Tester:runJobs

Runs the tester. Each job is wrapped in a `pcall`, and they are executed in the order of registration. Check the final results by calling `local ok = Tester:allGood()` or checking the values in `Tester.counter`.

`Tester:runJobs()`


## Tester:allGood

Checks if all jobs passed.

`local ok = Tester:allGood()`

**Returns:** True if all jobs passed, false if not.

**Notes:**

* A tester with zero jobs will always return true.


# Tester: Job Methods

The following methods are intended to be called within job functions.

## Tester:print

Wrapper for Lua's `print()` that only prints if an appropriate verbosity level is set.

`Tester:print(level, ...)`

* `level`: The verbosity level of this message. If the tester's verbosity is lower, the message is not printed.

* `...`: Arguments for `print()`.


## Tester:write

Wrapper for Lua's `io.write()` that only prints if an appropriate verbosity level is set.

`Tester:write(level, str)`

* `level`: The verbosity level of this message. If the tester's verbosity is lower, the message is not printed.

* `str`: The string for `io.write()`.


## Tester:warn

Increments the tester's warning counter, and prints a message to the terminal *if* the tester's verbosity level is 2 or greater.

`Tester:warn(str)`

* `str`: The string to conditionally print.


## Tester:expectLuaReturn

Runs a function, expecting it to return without raising a Lua error. If an error is raised, then the job fails.

`Tester:expectLuaReturn([desc], func, ...)`

* `[desc]`: (string) Optional string description for the job.

* `func`: (function) The function to test.

* `...`: varargs list to be passed to `func`.


## Tester:expectLuaError

Runs a function, expecting it to raise a Lua error. If the function returns, then the job fails.

`Tester:expectLuaError([desc], func, ...)`

* `[desc]`: (string) Optional string description for the job.

* `func`: (function) The function to test.

* `...`: varargs list to be passed to `func`.


**Notes:**

* Care should be taken with functions that modify global state before error paths are hit, and also functions which do not clean up their allocations or other state when raising a Lua error.


# Tester Assertion Methods

The tester instance includes the following assertion methods:

+---------------------------------------------------------------+
| Method                          | Pass Condition              |
+---------------------------------+-----------------------------+
| Tester:isEqual(a, b)            | a == b                      |
| Tester:isNotEqual(a, b)         | a ~= b                      |
| Tester:isBoolTrue(a)            | a == true                   |
| Tester:isBoolFalse(a)           | a == false                  |
| Tester:isEvalTrue(a)            | a ~= false and a ~= nil     |
| Tester:isEvalFalse(a)           | a == false or a == nil      |
| Tester:isNil(a)                 | a == nil                    |
| Tester:isNotNil(a)              | a ~= nil                    |
| Tester:isNan(a)                 | a ~= a                      |
| Tester:isNotNan(a)              | a == a                      |
| Tester:isType(val, expected)    | *type(val) in expected*     |
| Tester:isNotType(val, expected) | *type(val) not in expected* |
+---------------------------------------------------------------+

For the last two, `expected` is a string with Lua type tags that are separated by non-alphanumeric characters. For example, to assert that a value is a string or a boolean, you could call `Tester:isType(val, "string, boolean")`.


# License (MIT)

Copyright (c) 2022 - 2024 RBTS

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
