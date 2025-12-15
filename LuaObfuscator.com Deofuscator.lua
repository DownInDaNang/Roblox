--[[
@DownInDaNang
ONLY works for luaobfuscator.com scripts

why their obfuscator is ass:
- only encrypts strings with basic xor
- leaves the decrypt function right there in the code

how to crack it:
1. copy their decrypt function (they left it there lol)
2. find all the encrypted strings
3. decrypt them
4. done

just change the url at the bottom and run
copies deobfuscated code to clipboard
you can beautify with https://codebeautify.org/lua-beautifier
]]--

local function deof(url)
    local s = game:HttpGet(url)
    if not s:find("LuaObfuscator.com") then return "not a luaobfuscator.com script" end
    
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
print("deobfuscated - copied to clip")
