--[[
@DownInDaNang
deobfuscator for luaobfuscator.com
ONLY works for "Chaotic Good" mode

how to know if it works on ur script:
- obfuscated script has "local v0=string.char" at top
- has a function called "v7" 
- NO "LOL!" hex string anywhere (LOL! = their bytecode signature)

if u see "LOL!" in the code = wont work, thats a different mode (vm/bytecode)
this only cracks the basic string encryption
]]--

local function deof(url)
    local s = game:HttpGet(url)
    
    if s:find("LOL!") then
        return "wont work - script has LOL! bytecode. only works for chaotic good mode (string encryption)"
    end
    
    if not s:find("LuaObfuscator.com") or not s:find("v7%(") then 
        return "wrong mode - need chaotic good (the one with v7 function)"
    end
    
    local bit = bit32 or bit
    local function v7(a, b)
        local r = {}
        for i = 1, #a do
            table.insert(r, string.char(bit.bxor(string.byte(string.sub(a, i, i + 1)), string.byte(string.sub(b, 1 + (i % #b), 1 + (i % #b) + 1))) % 256))
        end
        return table.concat(r)
    end
    
    local out = s
    for m in s:gmatch('v7%b()') do
        local s1, s2 = m:match('v7%((".-")%s*,%s*(".-")%)')
        if s1 and s2 then
            s1, s2 = loadstring("return " .. s1)(), loadstring("return " .. s2)()
            out = out:gsub(m:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"), '"' .. v7(s1, s2) .. '"', 1)
        end
    end
    
    local varMap = {}
    
    for v in out:gmatch("(v%d+)%s*=%s*game:GetService%s*%(%s*\"Players\"%s*%)") do varMap[v] = "Players" end
    for v in out:gmatch("(v%d+)%s*=%s*game:GetService%s*%(%s*\"Workspace\"%s*%)") do varMap[v] = "Workspace" end
    for v in out:gmatch("(v%d+)%s*=%s*game:GetService%s*%(%s*\"ReplicatedStorage\"%s*%)") do varMap[v] = "ReplicatedStorage" end
    for v in out:gmatch("(v%d+)%s*=%s*game:GetService%s*%(%s*\"RunService\"%s*%)") do varMap[v] = "RunService" end
    for v in out:gmatch("(v%d+)%s*=%s*game:GetService%s*%(%s*\"UserInputService\"%s*%)") do varMap[v] = "UserInputService" end
    for v in out:gmatch("(v%d+)%s*=%s*game:GetService%s*%(%s*\"TweenService\"%s*%)") do varMap[v] = "TweenService" end
    for v in out:gmatch("(v%d+)%s*=%s*game:GetService%s*%(%s*\"HttpService\"%s*%)") do varMap[v] = "HttpService" end
    for v in out:gmatch("(v%d+)%s*=%s*game%.Players") do varMap[v] = "Players" end
    for v in out:gmatch("(v%d+)%s*=%s*game%.Workspace") do varMap[v] = "Workspace" end
    for v in out:gmatch("(v%d+)%s*=%s*game%.ReplicatedStorage") do varMap[v] = "ReplicatedStorage" end
    for v in out:gmatch("(v%d+)%s*=%s*[%w_]+%.LocalPlayer") do varMap[v] = "LocalPlayer" end
    for v in out:gmatch("(v%d+)%s*=%s*LocalPlayer%.Character") do varMap[v] = "Character" end
    for v in out:gmatch("(v%d+)%s*=%s*Character:FindFirstChild") do varMap[v] = "Part" end
    for v in out:gmatch("(v%d+)%s*=%s*Character:WaitForChild") do varMap[v] = "Part" end
    for v in out:gmatch("(v%d+)%s*=%s*Instance%.new%s*%(%s*\"RemoteEvent") do varMap[v] = "RemoteEvent" end
    for v in out:gmatch("(v%d+)%s*=%s*Instance%.new%s*%(%s*\"RemoteFunction") do varMap[v] = "RemoteFunction" end
    for v in out:gmatch("(v%d+)%s*=%s*Instance%.new%s*%(%s*\"BindableEvent") do varMap[v] = "BindableEvent" end
    for v in out:gmatch("(v%d+)%s*=%s*Instance%.new%s*%(%s*\"Part") do varMap[v] = "Part" end
    for v in out:gmatch("(v%d+)%s*=%s*Instance%.new") do if not varMap[v] then varMap[v] = "Instance" end end
    for v in out:gmatch("function%s*%((v%d+)%)") do if not varMap[v] then varMap[v] = "arg" end end
    for v in out:gmatch("Connect%s*%(%s*function%s*%((v%d+)%)") do if not varMap[v] then varMap[v] = "player" end end
    
    for old, new in pairs(varMap) do
        out = out:gsub("([^%w])" .. old .. "([^%w])", "%1" .. new .. "%2")
    end
    
    local codeStart = out:find("local%s+%w+%s*=%s*game") or out:find("game") or out:find("print")
    if codeStart then
        out = out:sub(codeStart)
    end
    
    out = out:gsub("%-%-%[%[.-%]%]%-%-", "")
    out = out:gsub("%d+ %- %(%d+%)", function(x) return loadstring("return " .. x)() end)
    out = out:gsub("%d+ %+ %d+", function(x) return loadstring("return " .. x)() end)
    out = out:gsub("%d+ %- %d+", function(x) return loadstring("return " .. x)() end)
    
    return out
end

setclipboard(deof("https://pastebin.com/raw/k4p16peZ")) -- link here (must be a RAW)
print("done - copied")
