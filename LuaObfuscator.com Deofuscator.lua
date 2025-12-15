--[[
@DownInDaNang
deobfuscator for luaobfuscator.com
works for: alpha 0.10.9 string encryption mode (the one with v7 xor function)
does NOT work for: "OBFUSCATE (old)", "OBFUSCATE v1", or any vm/bytecode modes

why the string encryption mode is ass:
- only encrypts strings with basic xor
- leaves the decrypt function right there in the code

just change the url at the bottom and run
copies deobfuscated code to clipboard
]]--

local function deof(url)
    local s = game:HttpGet(url)
    if not s:find("LuaObfuscator.com") or not s:find("v7%(") then 
        return "wrong obfuscator mode - only works for string encryption (alpha 0.10.9)"
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
    
    out = out:gsub("local v0=string%.char;.-return v5%(v30%);end ", ""):gsub("%-%-%[%[.-%]%]%-%-\n", "")
    out = out:gsub("%d+ %- %(%d+%)", function(x) return loadstring("return " .. x)() end)
    out = out:gsub("%d+ %+ %d+", function(x) return loadstring("return " .. x)() end)
    out = out:gsub("%d+ %- %d+", function(x) return loadstring("return " .. x)() end)
    
    return out
end

setclipboard(deof("https://pastebin.com/raw/k4p16peZ"))
print("deobfuscated - check clipboard")
