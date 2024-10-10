-- errTest v2.1.4
-- https://github.com/rabbitboots/err_test

--[[
MIT License

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
--]]


local errTest = {}


errTest.lang = {
	err_dupe_job = "attempt to run job twice.",
	err_add_dupe_job = "tried to add a duplicate job function",
	err_empty_var_list = "empty varargs list",
	err_missing_func = "no job function at index $1",
	err_type_bad = "argument #$1: bad type (expected [$2], got $3)",
	fail_eq = "expected value equality",
	fail_bool_false = "expected boolean false",
	fail_bool_true = "expected boolean true",
	fail_eval_false = "expected false evaluation (falsy)",
	fail_eval_true = "expected true evaluation (truthy)",
	fail_missing_nan = "expected NaN value",
	fail_neq = "expected inequality",
	fail_nil = "expected nil",
	fail_not_nil = "expected not nil",
	fail_unwanted_nan = "unwanted NaN value",
	fail_type_check = "expected type [$1], got $2",
	fail_not_type_check = "expected not to receive type [$1], got $2",
	job_msg_pre = "($1/$2) $3",
	msg_warn = "[warn]: $1",
	test_begin = "*** Begin test: $1 ***",
	test_end = "*** End test: $1 ***",
	test_expect_pass = "[expectReturn] $1: $2 ($3): ",
	test_expect_fail = "[expectError] $1: $2 ($3): ",
	test_expect_fail_passed = "Expected failing call passed:",
	test_totals = "$1 jobs passed. Warnings: $2",
	tostring_fail = "('tostring()' failed)"
}
local lang = errTest.lang


-- guard against bad '__tostring' metamethods in 5.1, 5.2 and LuaJIT.
-- 5.3 and 5.4 check that the return value is a string.
local function _tostring(s)
	s = tostring(s)
	return type(s) == "string" and s or lang.tostring_fail
end


-- From PILE Base v1.1.2: pile_interp.lua / interp()
local interp
do
	local v = {}
	local function c()
		for k in pairs(v) do
			v[k] = nil
		end
		v["$"] = "$"
	end
	c()
	interp = function(s, ...)
		for i = 1, math.min(10, select("#", ...)) do
			v[tostring(i)] = tostring(select(i, ...))
		end
		local r = tostring(s):gsub("%$(.)", v)
		c()
		return r
	end
end


-- From PILE Base v1.1.2: pile_arg_check.lua / argCheck.type()
local function _argType(n, v, ...)
	local typ = type(v)
	for i = 1, select("#", ...) do
		if typ == select(i, ...) then
			return
		end
	end
	error(interp(lang.err_type_bad, n, table.concat({...}, ", "), typ), 2)
end


local _mt_test = {}
_mt_test.__index = _mt_test


local function varargsToString(self, ...)
	local n_args = select("#", ...)
	if n_args == 0 then
		return ""
	end

	local temp = {...}
	for i = 1, n_args do
		temp[i] = _tostring(temp[i])
	end

	return table.concat(temp, ", ")
end


local function getLabel(self, func)
	return self.reg[func] or ""
end


function errTest.new(name, verbosity)
	_argType(1, name, "nil", "string")
	_argType(2, verbosity, "nil", "number")

	local self = {
		name = name or "",
		verbosity = verbosity or 4,

		reg = {},
		jobs = {},

		lf_count = 0,

		warnings = 0,
	}

	return setmetatable(self, _mt_test)
end


function _mt_test:registerFunction(label, func)
	_argType(1, label, "nil", "string")
	_argType(2, func, "function")

	self.reg[func] = label
end


function _mt_test:registerJob(desc, func)
	_argType(1, desc, "nil", "string")
	_argType(2, func, "function")

	for i, job in ipairs(self.jobs) do
		if job[2] == func then
			error(lang.err_add_dupe_job, 2)
		end
	end

	table.insert(self.jobs, {desc or "", func})
end


function _mt_test:runJobs()
	self:print(1, interp(lang.test_begin, self.name))
	self:lf(2)

	local dupes = {}
	for i, job in ipairs(self.jobs) do
		local desc, func = job[1], job[2]

		if not func then
			error(interp(lang.err_missing_func, i), 2)
		end

		if dupes[func] then
			error(lang.err_dupe_job)
		end
		dupes[func] = true

		self:write(2, interp(lang.job_msg_pre, i, #self.jobs, desc))
		self:lf(2)

		func(self)
		self:lf(3)
	end

	self:lf(2)
	self:print(1, interp(lang.test_end, self.name))
	self:print(1, interp(lang.test_totals, #self.jobs, self.warnings))
end


function _mt_test:lf(level)
	if self.lf_count <= 2 and self.verbosity >= level then
		--io.write("LF " .. self.lf_count .. " > " .. self.lf_count + 1 .. ", LEVEL " .. level .. ":" .. self.verbosity)
		self.lf_count = self.lf_count + 1
		io.write("\n")
	end
end


function _mt_test:print(level, ...)
	if self.verbosity >= level then
		print(...)
		self.lf_count = 1
	end
end


function _mt_test:write(level, str)
	if self.verbosity >= level then
		io.write(str)
		io.flush()
		self.lf_count = 0
	end
end


function _mt_test:warn(str)
	self.warnings = self.warnings + 1
	if self.verbosity >= 2 then
		self.lf_count = 1
		print(interp(lang.msg_warn, str))
	end
end


local function _str(...)
	local s = ""
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		s = s .. _tostring(v ~= nil and v or "")
		if i < select("#", ...) then
			s = s .. ", "
		end
	end
	return s
end


function _mt_test:expectLuaReturn(desc, func, ...)
	_argType(1, desc, "nil", "string")
	_argType(2, func, "function")

	self:write(3, interp(lang.test_expect_pass, desc or "", getLabel(self, func), varargsToString(self, ...)))

	local a,b,c,d,e,f = func(...)

	self:lf(4)

	return a,b,c,d,e,f
end


function _mt_test:expectLuaError(desc, func, ...)
	_argType(1, desc, "nil", "string")
	_argType(2, func, "function")

	self:write(3, interp(lang.test_expect_fail, desc or "", getLabel(self, func), varargsToString(self, ...)))

	local ok, a,b,c,d,e,f = pcall(func, ...)
	if ok == true then
		error(lang.test_expect_fail_passed .. "\n" .. _str(a,b,c,d,e,f))
	end

	self:lf(4)
	self:write(4, " >  " .. _str(a))
	self:lf(4)
	self:lf(3)
end


function _mt_test:isEqual(a, b) self:print(4, "isEqual()", a, b); if a ~= b then error(lang.fail_eq, 2) end end
function _mt_test:isNotEqual(a, b) self:print(4, "isNotEqual()", a, b) if a == b then error(lang.fail_neq, 2) end end

function _mt_test:isBoolTrue(a) self:print(4, "isBoolTrue()", a) if a ~= true then error(lang.fail_bool_true, 2) end end
function _mt_test:isBoolFalse(a) self:print(4, "isBoolFalse()", a) if a ~= false then error(lang.fail_bool_false, 2) end end

function _mt_test:isEvalTrue(a) self:print(4, "isEvalTrue()", a) if not a then error(lang.fail_eval_true, 2) end end
function _mt_test:isEvalFalse(a) self:print(4, "isEvalFalse()", a) if a then error(lang.fail_eval_false, 2) end end

function _mt_test:isNil(a) self:print(4, "isNil()", a) if a ~= nil then error(lang.fail_nil, 2) end end
function _mt_test:isNotNil(a) self:print(4, "isNotNil()", a) if a == nil then error(lang.fail_not_nil, 2) end end

function _mt_test:isNan(a) self:print(4, "isNan()", a) if a == a then error(lang.fail_missing_nan, 2) end end
function _mt_test:isNotNan(a) self:print(4, "isNotNan()", a) if a ~= a then error(lang.fail_unwanted_nan, 2) end end


function _mt_test:isType(val, ...)
	local exp_arr = {...}
	if #exp_arr == 0 then
		error(lang.err_empty_var_list)
	end
	for i, expected in ipairs(exp_arr) do
		_argType(i + 1, expected, "string")
	end
	local exp_str = table.concat(exp_arr, ", ")
	self:print(4, "isType", type(val), ";", exp_str)
	for i, expected in ipairs(exp_arr) do
		if type(val) == expected then
			return
		end
	end

	error(interp(lang.fail_type_check, exp_str, type(val)), 2)
end


function _mt_test:isNotType(val, ...)
	local nexp_arr = {...}
	if #nexp_arr == 0 then
		error(lang.err_empty_var_list)
	end
	for i, not_expected in ipairs(nexp_arr) do
		_argType(i + 1, not_expected, "string")
	end
	local nexp_str = table.concat(nexp_arr, ", ")
	self:print(4, "isNotType", type(val), ";", nexp_str)
	for i, not_expected in ipairs(nexp_arr) do
		if type(val) == not_expected then
			error(interp(lang.fail_not_type_check, nexp_str, type(val)), 2)
		end
	end
end


return errTest
