-- coroutine_api.lua
-- 用玩家与NPC对话的例子介绍 Lua coroutine 模块所有 API

-- 玩家与NPC对话流程

Player_Name = nil

local function npc_dialog()
    print("NPC: 欢迎来到村庄，旅行者！")
    local name = coroutine.yield("NPC: 你叫什么名字？")
    print("NPC: 很高兴认识你，" .. name .. "！")
    local need_help = coroutine.yield("NPC: 你需要帮助吗？(yes/no)")
    if need_help == "yes" then
        coroutine.yield("NPC: 好的，我可以帮你。")
    else
        coroutine.yield("NPC: 好的，祝你旅途愉快！")
    end
end

local co = coroutine.create(npc_dialog)
local ok, question = coroutine.resume(co)
print(question)
Player_Name = io.read() -- 玩家输入
ok, question = coroutine.resume(co, Player_Name)
print(question)
io.write(Player_Name .. "：")
local need_help = io.read() -- 玩家输入
ok, question = coroutine.resume(co, need_help)
print(question)
