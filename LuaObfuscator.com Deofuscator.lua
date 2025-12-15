--[[
@DownInDaNang
deobfuscator for luaobfuscator.com
ONLY works for "Chaotic Good" mode

how to know if it works on ur script:
- obfuscated script has "local v0=string.char" at top
- has a function called "v7" 
- NO "LOL!" hex string anywhere (LOL! = their bytecode signature)

if u see "LOL!" in the code = wont work, thats a different mode (vm/bytecode)
this only cracks the basic string encryption mode
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
    for varName, value in out:gmatch("local%s+(v%d+)%s*=%s*(.-)[\n;]") do
        local newName = varName
        if value:find("game%.Players") then
            newName = "Players"
        elseif value:find("%.LocalPlayer") then
            newName = "LocalPlayer"
        elseif value:find("game:GetService") then
            local service = value:match('"(.-)"')
            if service then newName = service end
        end
        varMap[varName] = newName
    end
    
    for old, new in pairs(varMap) do
        out = out:gsub("([^%w])" .. old .. "([^%w])", "%1" .. new .. "%2")
    end
    
    local codeStart = out:find("local%s+%w+%s*=%s*game") or out:find("print") or out:find("game:")
    if codeStart then
        out = out:sub(codeStart)
    end
    
    out = out:gsub("%-%-%[%[.-%]%]%-%-", "")
    out = out:gsub("%d+ %- %(%d+%)", function(x) return loadstring("return " .. x)() end)
    out = out:gsub("%d+ %+ %d+", function(x) return loadstring("return " .. x)() end)
    out = out:gsub("%d+ %- %d+", function(x) return loadstring("return " .. x)() end)
    
    return out
end

setclipboard(deof("https://pastebin.com/raw/k4p16peZ")) -- replace link here (MUST BE A RAW)
print("done - copied")
