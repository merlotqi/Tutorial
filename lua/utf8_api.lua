-- utf8_api.lua
-- 介绍 Lua utf8 模块的常用 API 及用例

-- utf8.len(s [, i [, j]]): 返回字符串 s 的 UTF-8 字符数，可选起止位置
local s = "你好Lua"
print("utf8.len(s) =", utf8.len(s))             -- 5
print("utf8.len(s, 2, 4) =", utf8.len(s, 2, 4)) -- 3

-- utf8.codepoint(s [, i [, j]]): 返回 s 中指定范围的 Unicode 码点
local cp1 = utf8.codepoint(s, 1, 2)
print("utf8.codepoint(s, 1, 2) =", cp1) -- 20320

-- utf8.char(...): 根据码点返回对应字符
print("utf8.char(20320, 22909) =", utf8.char(20320, 22909)) -- "你好"

-- utf8.offset(s, n [, i]): 返回第 n 个 UTF-8 字符的字节位置
print("utf8.offset(s, 2) =", utf8.offset(s, 2)) -- 4

-- utf8.codes(s): 迭代字符串 s 的所有码点
for p, c in utf8.codes(s) do
    print(string.format("pos: %d, codepoint: %d", p, c))
end

-- utf8模块常用API说明：
-- utf8.len(s [, i [, j]])      -- 统计UTF-8字符数
-- utf8.codepoint(s [, i [, j]]) -- 获取码点
-- utf8.char(...)              -- 码点转字符
-- utf8.offset(s, n [, i])     -- 获取第n个字符的字节位置
-- utf8.codes(s)               -- 迭代所有码点
