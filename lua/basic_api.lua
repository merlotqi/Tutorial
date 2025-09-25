-- Example use cases for basic Lua APIs

-- _G: global environment table
print("_G.print == print:", _G.print == print)

-- _VERSION: Lua version string
print("_VERSION =", _VERSION)

-- assert(v [, message]): error if v is false/nil
assert(1 == 1)
-- assert(1 == 2, "Values are not equal!") -- error

-- collectgarbage([opt [, arg]]): control garbage collector
print("collectgarbage('count') =", collectgarbage("count"))

-- dofile([filename]): execute Lua file
-- dofile("other.lua")

-- error(message [, level]): raise error
-- error("Something went wrong!")

-- getmetatable(obj): get metatable
print("getmetatable('abc') =", getmetatable("abc"))

-- ipairs(t): iterate array part of table
for i, v in ipairs({ 10, 20, 30 }) do print(i, v) end

-- load(chunk [, chunkname [, mode [, env]]]): compile chunk
f = load("return 123")
print("load() result:", f())

-- loadfile([filename [, mode [, env]]]): compile file
-- f = loadfile("other.lua")

-- next(table [, index]): next key-value
local tbl = { a = 1, b = 2 }
k, v = next(tbl)
print("next(tbl) =", k, v)

-- pairs(t): iterate all key-value pairs
for k, v in pairs(tbl) do print(k, v) end

-- pcall(f, ...): protected call
ok, res = pcall(function() return 1 / 0 end)
print("pcall result:", ok, res)

-- print(...): print values
print("Hello", "World", 123)

-- rawequal(v1, v2): raw equality
print("rawequal(1, 1) =", rawequal(1, 1))

-- rawget(table, index): raw get
print("rawget(tbl, 'a') =", rawget(tbl, "a"))

-- rawlen(v): raw length
print("rawlen({1,2,3}) =", rawlen({ 1, 2, 3 }))

-- rawset(table, index, value): raw set
rawset(tbl, "c", 3)
print("tbl.c =", tbl.c)

-- require(modname): load module
-- local m = require("math")

-- select(index, ...): select arguments
function test(...)
    print("select('#', ...):", select('#', ...))
    print("select(2, ...):", select(2, ...))
end

test(1, 2, 3, 4)

-- setmetatable(table, metatable): set metatable
local mt = { __index = function() return "default" end }
local t = {}
setmetatable(t, mt)
print("t.x =", t.x)

-- tonumber(e [, base]): convert to number
print("tonumber('123') =", tonumber("123"))
print("tonumber('123', 16) =", tonumber("123", 16))

-- tostring(v): convert to string
print("tostring(123) =", tostring(123))

-- type(v): type of value
print("type(123) =", type(123))

-- warn(...): print warning (Lua 5.4+)
-- warn("This is a warning!")

-- xpcall(f, msgh [, ...]): protected call with custom error handler
function err(msg) return "Error: " .. msg end

ok, res = xpcall(function() error("fail") end, err)
print("xpcall result:", ok, res)
