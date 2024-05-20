local path = ... and (...):match("(.-)[^%.]+$") or ""


local errTest = require(path .. "err_test")
local strict = require(path .. "test.lib.strict")


local function dummyAlwaysError()
	error("This function intentionally raises an error.")
end

local function dummyOK()
	return true
end
local function dummyNotOK()
	return false, "This function intentionally returns false + this string."
end


local self = errTest.new("errTest self-test")
local _mt_test = getmetatable(errTest.new("tester"))


-- the verbosity of the tester instances being tested.
local sub_ver = 0


-- [===[
self:registerFunction("errTest.new()", errTest.new)

self:registerJob("errTest.new()", function(self)
	self:expectLuaError("arg #1 bad type", errTest.new, {})
	self:expectLuaError("arg #2 bad type", errTest.new, "foobar", "oops")

	self:expectLuaReturn("arg #1 nil description is OK", errTest.new)
	self:expectLuaReturn("arg #2 any verbosity number is permitted", errTest.new, "foobar", -5)
end
)
--]===]


-- [===[
self:registerFunction("Tester:registerFunction()", _mt_test.registerFunction)

self:registerJob("Tester:registerFunction()", function(self)
	do
		local tester = errTest.new("tester", sub_ver)
		self:expectLuaError("arg #1 bad type", _mt_test.registerFunction, tester, {}, function() end)
		self:expectLuaError("arg #2 bad type", _mt_test.registerFunction, tester, "foo", "oops")

		self:expectLuaReturn("arg #1 nil description is OK", _mt_test.registerFunction, tester, nil, function() end)
	end
end
)
--]===]

-- [===[
self:registerFunction("Tester:registerJob()", _mt_test.registerJob)

self:registerJob("Tester:registerJob()", function(self)
	do
		local tester = errTest.new("tester", sub_ver)
		self:expectLuaError("arg #1 bad type", _mt_test.registerJob, tester, {}, function() end)
		self:expectLuaError("arg #2 bad type", _mt_test.registerJob, tester, "foo", "oops")
	end

	do
		local tester = errTest.new("tester", sub_ver)
		self:print(2, "[-] attempt to add a job function that is already registered")
		local dupe = function() end
		tester:registerJob("first job", dupe)
		self:expectLuaError("attempt to add dupe job", _mt_test.registerJob, tester, "dupe job", dupe)
	end

	do
		local tester = errTest.new("tester", sub_ver)
		self:expectLuaReturn("arg #1 nil description is OK", _mt_test.registerJob, tester, nil, function() end)
	end
end
)
--]===]


-- [===[
self:registerFunction("Tester:runJobs()", _mt_test.runJobs)

self:registerJob("Tester:runJobs()", function(self)
	do
		local tester = errTest.new("tester", sub_ver)
		local dupe = function() end
		tester.jobs = {
			{"dupe1", dupe},
			{"dupe2", dupe},
		}
		self:expectLuaError("attempt to run the same job function twice", _mt_test.runJobs, tester)
	end

	do
		local tester = errTest.new("tester", sub_ver)
		tester.jobs = {
			{"func1", function() end},
			{"missing_function"},
		}
		self:expectLuaError("missing function in job table", _mt_test.runJobs, tester)
	end
end
)
--]===]


-- [===[
self:registerFunction("Tester:allGood()", _mt_test.allGood)

self:registerJob("Tester:allGood()", function(self)
	do
		local tester = errTest.new("tester", sub_ver)

		self:print(2, "zero jobs = pass by default")
		local ok = tester:allGood()
		self:isEvalTrue(ok)
	end

	do
		local tester = errTest.new("tester", sub_ver)

		self:print(2, "50% jobs passed")
		tester:registerJob("one", function() end)
		tester:registerJob("two", dummyAlwaysError)

		tester:runJobs()
		local ok = tester:allGood()
		self:isEvalFalse(ok)
		self:isEqual(tester.counters.pass, 1)
	end

	do
		local tester = errTest.new("tester", sub_ver)

		self:print(2, "100% jobs passed")
		tester:registerJob("one", function() end)
		tester:registerJob("two", function() end)

		tester:runJobs()
		local ok = tester:allGood()
		self:isEvalTrue(ok)
		self:isEqual(tester.counters.pass, 2)
	end
end
)
--]===]


-- skip Tester:print(), Tester:write() and Tester:warn().


-- [===[
self:registerFunction("Tester:expectLuaReturn()", _mt_test.expectLuaReturn)

self:registerJob("Tester:expectLuaReturn()", function(self)
	do
		local tester = errTest.new("tester", sub_ver)
		self:expectLuaError("arg #1 bad type", _mt_test.expectLuaReturn, tester, {}, function() end)
		self:expectLuaError("arg #2 bad type", _mt_test.expectLuaReturn, tester, "foo", "oops")

		self:expectLuaReturn("expect return", _mt_test.expectLuaReturn, tester, "success", dummyOK)
	end
end
)
--]===]


-- [===[
self:registerFunction("Tester:expectLuaError()", _mt_test.expectLuaError)

self:registerJob("Tester:expectLuaError()", function(self)
	do
		local tester = errTest.new("tester", sub_ver)

		self:expectLuaError("arg #1 bad type", _mt_test.expectLuaError, tester, {}, function() end)
		self:expectLuaError("arg #2 bad type", _mt_test.expectLuaError, tester, "foo", "oops")

		self:expectLuaReturn("expect return", _mt_test.expectLuaError, tester, "success", dummyAlwaysError)
	end
end
)
--]===]


-- [===[
self:registerFunction("Tester:isEqual()", _mt_test.isEqual)
self:registerFunction("Tester:isNotEqual()", _mt_test.isNotEqual)
self:registerFunction("Tester:isBoolTrue()", _mt_test.isBoolTrue)
self:registerFunction("Tester:isBoolFalse()", _mt_test.isBoolFalse)
self:registerFunction("Tester:isEvalTrue()", _mt_test.isEvalTrue)
self:registerFunction("Tester:isEvalFalse()", _mt_test.isEvalFalse)
self:registerFunction("Tester:isNil()", _mt_test.isNil)
self:registerFunction("Tester:isNotNil()", _mt_test.isNotNil)
self:registerFunction("Tester:isNan()", _mt_test.isNan)
self:registerFunction("Tester:isNotNan()", _mt_test.isNotNan)
self:registerFunction("Tester:isType()", _mt_test.isType)
self:registerFunction("Tester:isNotType()", _mt_test.isNotType)

self:registerJob("Tester: <various assertion methods>", function(self)
	do
		local tester = errTest.new("tester", sub_ver)

		self:expectLuaError("a ~= b", _mt_test.isEqual, tester, 1, 2)
		self:expectLuaReturn("a == b", _mt_test.isEqual, tester, 1, 1)

		self:expectLuaError("a == b", _mt_test.isNotEqual, tester, 1, 1)
		self:expectLuaReturn("a ~= b", _mt_test.isNotEqual, tester, 1, 2)

		self:expectLuaError("a ~= true", _mt_test.isBoolTrue, tester, false)
		self:expectLuaReturn("a == true", _mt_test.isBoolTrue, tester, true)

		self:expectLuaError("a ~= false", _mt_test.isBoolFalse, tester, true)
		self:expectLuaReturn("a == false", _mt_test.isBoolFalse, tester, false)

		self:expectLuaError("a == false", _mt_test.isEvalTrue, tester, false)
		self:expectLuaError("a == nil", _mt_test.isEvalTrue, tester, nil)
		self:expectLuaReturn("a ~= false and a ~= nil", _mt_test.isEvalTrue, tester, true)

		self:expectLuaError("a ~= false and a ~= nil", _mt_test.isEvalFalse, tester, true)
		self:expectLuaReturn("a == nil", _mt_test.isEvalFalse, tester, nil)
		self:expectLuaReturn("a == false", _mt_test.isEvalFalse, tester, false)

		self:expectLuaError("a ~= nil", _mt_test.isNil, tester, 1)
		self:expectLuaReturn("a == nil", _mt_test.isNil, tester, nil)

		self:expectLuaError("a == nil", _mt_test.isNotNil, tester, nil)
		self:expectLuaReturn("a ~= nil", _mt_test.isNotNil, tester, 1)

		self:expectLuaError("a == a", _mt_test.isNan, tester, 0, 0)
		self:expectLuaReturn("a ~= a", _mt_test.isNan, tester, 0/0, 0/0)

		self:expectLuaError("a ~= a", _mt_test.isNotNan, tester, 0/0, 0/0)
		self:expectLuaReturn("a == a", _mt_test.isNotNan, tester, 0, 0)

		self:expectLuaError("#2 bad type", _mt_test.isType, tester, "foo", function() end)
		self:expectLuaError("type not in arg #2", _mt_test.isType, tester, "foo", "nil/number/table/userdata")
		self:expectLuaReturn("type is in arg #2", _mt_test.isType, tester, "foo", "number/string")

		self:expectLuaError("#2 bad type", _mt_test.isNotType, tester, "foo", function() end)
		self:expectLuaError("type is in arg #2", _mt_test.isNotType, tester, "foo", "number/string")
		self:expectLuaReturn("type not in arg #2", _mt_test.isNotType, tester, "foo", "nil/number/table/userdata")
	end
end
)
--]===]


self:runJobs()
