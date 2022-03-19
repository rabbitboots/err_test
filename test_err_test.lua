local path = ... and (...):match("(.-)[^%.]+$") or ""
--[[
	Hits error paths in errTest public functions.
--]]
--[[
	Copyright (c) 2022 RBTS

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
--]]

local errTest = require(path .. "err_test")
local strict = require(path .. "test.lib.strict")

-- We're going to need some throwaway functions for some calls.
local function dummyFactory()
	return function() return; end
end
local dum_func = dummyFactory()

local function dummyAlwaysError()
	error("This function intentionally raises an error.")
end

local function dummyOK()
	return true
end
local function dummyNotOK()
	return false, "This function intentionally returns false + this string."
end


-- Test disabling the display of pointer addresses for a moment
errTest.type_hide["function"] = true
print("(Test function address hiding)")
errTest.expectPass(errTest.try, dummyFactory())
io.write("\n")
errTest.type_hide["function"] = false


-- Onto the main tests.

print("Testing: errTest.register")
errTest.register(errTest.register, "errTest.register")

print("\n[+] Registration")
errTest.expectPass(errTest.register, dum_func, "good_type")
io.write("\n")

print("\n[-] Duplicate Registration")
errTest.expectFail(errTest.register, dum_func, "good_type")
io.write("\n")

local temp_dum_func = dummyFactory()
print("\n[+] Registering an empty string is discouraged, but acceptable")
errTest.expectPass(errTest.register, temp_dum_func, "")
io.write("\n")

print("\n[+] Unregister empty string label")
errTest.expectPass(errTest.register, temp_dum_func, nil)
io.write("\n")

print("\n[-] Arg #2 Bad type")
errTest.expectFail(errTest.register, dummyFactory(), dum_func, false)
print("")


print("Testing: errTest.try()\n")
errTest.register(errTest.try, "errTest.try")

print("\n[+] Expected operation")
errTest.expectPass(errTest.try, dummyFactory())
io.write("\n")

print("\n[-] Arg #1 Bad type")
errTest.expectFail(errTest.try, nil)
io.write("\n")


print("Testing: errTest.expectPass()\n")
errTest.register(errTest.expectPass, "errTest.expectPass")

print("\n[+] Expected operation")
errTest.expectPass(errTest.expectPass, dummyFactory())
io.write("\n")

print("\n[-] Arg #1 Bad type")
errTest.expectFail(errTest.expectPass, nil)
io.write("\n")


print("Testing: errTest.expectFail()\n")
errTest.register(errTest.expectFail, "errTest.expectFail")

print("\n[+] Expected operation")
errTest.expectPass(errTest.expectFail, dummyAlwaysError)
io.write("\n")

print("\n[-] Arg #1 Bad type")
errTest.expectFail(errTest.expectFail, nil)
io.write("\n")


print("Testing: errTest.okErrTry()\n")
errTest.register(errTest.okErrTry, "errTest.okErrTry")

print("\n[+] Expected operation")
errTest.expectPass(errTest.okErrTry, dummyOK)
io.write("\n")

print("\n[+] Expected operation - negative result")
errTest.expectPass(errTest.okErrTry, dummyNotOK)
io.write("\n")

print("\n[-] Arg #1 bad type")
errTest.expectFail(errTest.okErrTry, nil)
io.write("\n")


print("Testing: errTest.okErrExpectPass()\n")
errTest.register(errTest.okErrExpectPass, "errTest.okErrExpectPass")

print("\n[+] Expected operation")
errTest.expectPass(errTest.okErrExpectPass, dummyOK)
io.write("\n")

print("\n[-] Test failed")
errTest.expectFail(errTest.okErrExpectPass, dummyNotOK)
io.write("\n")

print("\n[-] Arg #1 bad type")
errTest.expectFail(errTest.okErrExpectPass, nil)
io.write("\n")


print("Testing: errTest.okErrExpectFail()\n")
errTest.register(errTest.okErrExpectFail, "errTest.okErrExpectFail")

print("\n[+] Expected operation")
errTest.expectPass(errTest.okErrExpectFail, dummyNotOK)
io.write("\n")

print("\n[-] Test passed (which is bad)")
errTest.expectFail(errTest.okErrExpectFail, dummyOK)
io.write("\n")

print("\n[-] Arg #1 bad type")
errTest.expectFail(errTest.okErrExpectFail, nil)
io.write("\n")

print("\nEnd of tests.\n")

errTest.unregisterAll()

