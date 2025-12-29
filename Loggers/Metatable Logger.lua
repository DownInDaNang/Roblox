local oldsetmetatable = setmetatable
local oldgetrawmetatable = getrawmetatable

getgenv().setmetatable = function(tbl, mt)
    if checkcaller() then
        local output = "setmetatable called\n"
        output = output .. "Table: " .. tostring(tbl) .. "\n"
        output = output .. "Metatable: " .. tostring(mt) .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("setmetatable called")
        print("Table:", tostring(tbl))
        print("Metatable:", tostring(mt))
        print("Call Stack:")
        print(debug.traceback())
        
        setclipboard(output)
    end
    return oldsetmetatable(tbl, mt)
end

getgenv().getrawmetatable = function(obj)
    if checkcaller() then
        local output = "getrawmetatable called\n"
        output = output .. "Object: " .. tostring(obj) .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("getrawmetatable called")
        print("Object:", tostring(obj))
        print("Call Stack:")
        print(debug.traceback())
        
        setclipboard(output)
    end
    return oldgetrawmetatable(obj)
end
