# errTest

A set of `pcall` wrappers that can be used to test error paths in Lua functions.

Its main purpose is for writing test scripts that hit multiple calls to `error()` without halting execution. Care should be taken with functions that modify state before the error paths are hit, and also functions which don't do proper cleanup when raising an error.


## Example

Say we want to test the error handling of public functions in foobar.lua:
```lua
local foobar = {}

function foobar.add(a, b)
	if type(a) ~= "number" then error("arg #1 needs to be a number."); end
	if type(b) ~= "number" then error("arg #2 needs to be a number."); end

	return a + b
end

return foobar
```

Our test script looks like this:
```lua
local foobar = require("foobar")

local errTest = require("err_test")

do
	print("Test: " .. errTest.register(foobar.add, "foobar.add"))
	local ok, res

	print("\n[+] expected behavior")
	ok, res = errTest.expectPass(foobar.add, 1, 2)
	print(ok, res, "<- should say 3")

	print("\n[-] arg #1 bad type")
	ok, res = errTest.expectFail(foobar.add, false, 2)

	print("\n[-] arg #2 bad type")
	ok, res = errTest.expectFail(foobar.add, 1, function() end)
end

print("End of tests.")

errTest.unregisterAll()
```

The script generates this output:
```
Test: foobar.add

[+] expected behavior
(expectPass) foobar.add(1, 2): [Pass]
true	3	<- should say 3

[-] arg #1 bad type
(expectFail) foobar.add(false, 2): [Fail]
-> ./foobar.lua:4: arg #1 needs to be a number.

[-] arg #2 bad type
(expectFail) foobar.add(1, function: 0x55b7f2b1a0d0): [Fail]
-> ./foobar.lua:5: arg #2 needs to be a number.
End of tests.
```

From this, we can see that the error messages are what we expect them to be.

This is a tiny example. Writing tests for large modules can get pretty maddening, and the output becomes difficult to read as well. In any case, if you want to check multiple error scenarios in one step, this is one way to do it.


## Public Functions

`errTest.register(func, label)`: Register a function using the string ID `label`, which will be used in terminal output when running tests. Identical labels can be assigned to multiple functions (not recommended), but an individual function can only have one label assigned at a time. Pass `nil` as the `label` argument to deregister a function.


`function errTest.unregisterAll()`: Remove all functions and labels from the internal registry.


### pcall() wrappers

`errTest.try(func, [...])`: Run a function via `pcall()`, and report if it completed or ended in a call to `error()`.


`errTest.expectPass(func, [...])`: Run a function via `pcall()`, and raise an error if it ended in a call to `error()`.


`errTest.expectFail(func, [...])`: Run a function via `pcall()`, and raise an error if it completed without calling `error()`.


### No pcall()

`errTest.okErrTry(func, [...])`: Run a function, and report if its first return value was truthy or falsy.


`errTest.okErrExpectPass(func, ...)`: Run a function, and raise an error if its first return value was falsy.


`errTest.expectFail(func, [...])`: Run a function, and raise an error if its first return value was truthy.





