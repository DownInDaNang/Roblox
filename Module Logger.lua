local modules = {}
local oldreq = require

local function valueToString(value)
    if value == nil then return "nil" end
    if type(value) == "table" then
        local result = "{"
        local count = 0
        for k, v in pairs(value) do
            count = count + 1
            if count > 5 then
                result = result .. " ... " 
                break
            end
            if count > 1 then result = result .. ", " end
            result = result .. tostring(k) .. "=" .. tostring(v)
        end
        return result .. "}"
    else
        return tostring(value)
    end
end

local function hookTable(tbl, modname, path, original)
    path = path or ""
    
    for k, v in pairs(tbl) do
        if type(v) == "table" and type(k) ~= "function" then
            local newpath = path == "" and k or (path .. "." .. k)
            
            local proxy = setmetatable({}, {
                __index = v,
                __newindex = function(t, key, val)
                    local oldval = v[key]
                    local fullpath = newpath .. "." .. key
                    local output = ""
                    
                    if val == nil then
                        output = output .. "deleted: " .. modname .. "." .. fullpath .. "\n"
                        output = output .. "old: " .. valueToString(oldval) .. "\n"
                        print("deleted:", modname .. "." .. fullpath)
                        print("old:", valueToString(oldval))
                    else
                        output = output .. "modified: " .. modname .. "." .. fullpath .. "\n"
                        output = output .. "old: " .. valueToString(oldval) .. "\n"
                        output = output .. "new: " .. valueToString(val) .. "\n"
                        print("modified:", modname .. "." .. fullpath)
                        print("old:", valueToString(oldval))
                        print("new:", valueToString(val))
                    end
                    
                    local trace = debug.traceback()
                    output = output .. "modified by:\n" .. trace .. "\n"
                    print("modified by:")
                    print(trace)
                    
                    v[key] = val
                    
                    if val == nil then
                        output = output .. "all changes:\n"
                        output = output .. "  " .. fullpath .. " deleted\n"
                        output = output .. "    old: " .. valueToString(oldval) .. "\n"
                        print("all changes:")
                        print("  " .. fullpath .. " deleted")
                        print("    old:", valueToString(oldval))
                    else
                        output = output .. "all changes:\n"
                        output = output .. "  " .. fullpath .. " value changed\n"
                        output = output .. "    old: " .. valueToString(oldval) .. "\n"
                        output = output .. "    new: " .. valueToString(val) .. "\n"
                        print("all changes:")
                        print("  " .. fullpath .. " value changed")
                        print("    old:", valueToString(oldval))
                        print("    new:", valueToString(val))
                    end
                    
                    setclipboard(output)
                end
            })
            
            rawset(tbl, k, proxy)
            hookTable(v, modname, newpath, original)
        end
    end
end

getgenv().require = function(mod)
    if not checkcaller() then
        return oldreq(mod)
    end
    
    local modname = tostring(mod)
    print("required:", modname)
    
    local result = oldreq(mod)
    
    if type(result) == "table" then
        hookTable(result, modname, "", result)
    end
    
    return result
end
