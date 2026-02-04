local _hidden = {
    checkcaller = checkcaller,
    setclipboard = setclipboard,
    getgenv = getgenv
}

local oldsetmetatable = setmetatable
local oldgetrawmetatable = getrawmetatable

_hidden.getgenv().setmetatable = function(tbl, mt)
    if _hidden.checkcaller() then
        local output = "setmetatable called\n"
        output = output .. "Table: " .. tostring(tbl) .. "\n"
        output = output .. "Metatable: " .. tostring(mt) .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("setmetatable called")
        print("Table:", tostring(tbl))
        print("Metatable:", tostring(mt))
        print("Call Stack:")
        print(debug.traceback())
        
        _hidden.setclipboard(output)
    end
    return oldsetmetatable(tbl, mt)
end

_hidden.getgenv().getrawmetatable = function(obj)
    if _hidden.checkcaller() then
        local output = "getrawmetatable called\n"
        output = output .. "Object: " .. tostring(obj) .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("getrawmetatable called")
        print("Object:", tostring(obj))
        print("Call Stack:")
        print(debug.traceback())
        
        _hidden.setclipboard(output)
    end
    return oldgetrawmetatable(obj)
end
