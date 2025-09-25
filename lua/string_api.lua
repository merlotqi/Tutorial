-- Lua String API Usage
-- This file introduces string module APIs with optional parameters explained.

-- string.len: returns length of string
print(string.len("hello")) -- 5

-- string.sub: substring extraction
-- string.sub(s, i [, j])
print(string.sub("abcdef", 2, 4)) -- "bcd"
print(string.sub("abcdef", 3))    -- "cdef"

-- string.find: find pattern in string
-- string.find(s, pattern [, init [, plain]])
print(string.find("hello world", "world"))      -- 7 11
print(string.find("hello world", "l", 5))       -- 10 10
print(string.find("hello world", "l", 1, true)) -- 3 3

-- string.match: match pattern
-- string.match(s, pattern [, init])
print(string.match("hello world", "%w+"))   -- "hello"
print(string.match("hello world", "world")) -- "world"

-- string.gmatch: iterator for pattern matches
-- string.gmatch(s, pattern)
for w in string.gmatch("one two three", "%w+") do
    print(w)
end

-- string.gsub: global substitution
-- string.gsub(s, pattern, repl [, n])
print(string.gsub("hello world", "l", "L"))    -- "heLLo worLd", 3
print(string.gsub("hello world", "l", "L", 1)) -- "heLlo world", 1

-- string.format: formatted string
print(string.format("Pi = %.2f", math.pi))
print(string.format("%d + %d = %d", 2, 3, 2 + 3))

-- string.reverse: reverse string
print(string.reverse("abc")) -- "cba"

-- string.upper/lower: case conversion
print(string.upper("abc")) -- "ABC"
print(string.lower("ABC")) -- "abc"

-- string.pack: pack values into a binary string
-- string.pack(fmt, v1, v2, ...): 按照格式字符串fmt将参数打包为二进制字符串
-- fmt格式如"i4"表示4字节整数，"f"表示浮点数，"cN"表示N字节字符串等
local packed = string.pack("i4f", 123, 3.14)
print("string.pack('i4f', 123, 3.14) =", packed)

-- string.packsize(fmt): 返回格式字符串fmt对应的字节数
local size = string.packsize("i4f")
print("string.packsize('i4f') =", size)

-- 更多格式说明：
-- i1/i2/i4/i8: 1/2/4/8字节整数
-- f: 浮点数
-- d: 双精度浮点数
-- cN: N字节字符串
-- s: 以长度前缀的字符串
-- z: 以\0结尾的字符串

-- string.char(...): 根据参数的整数值返回对应的字符，支持多个参数
print("string.char(65, 66, 67) =", string.char(65, 66, 67)) -- "ABC"

-- string.rep(s, n [, sep]): 返回字符串s重复n次，可选分隔符sep
print("string.rep('Lua', 3) =", string.rep("Lua", 3)) -- "LuaLuaLua"
print("string.rep('Lua', 3, '-') =", string.rep("Lua", 3, "-")) -- "Lua-Lua-Lua"
