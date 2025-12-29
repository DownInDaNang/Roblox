local camera = workspace.CurrentCamera
local mt = getrawmetatable(camera)
setreadonly(mt, false)
local oldnewindex = mt.__newindex

mt.__newindex = function(self, key, value)
    if checkcaller() and self == camera then
        local output = "Camera property changed\n"
        output = output .. "Property: " .. tostring(key) .. "\n"
        output = output .. "Old: " .. tostring(self[key]) .. "\n"
        output = output .. "New: " .. tostring(value) .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("Camera property changed")
        print("Property:", tostring(key))
        print("Old:", tostring(self[key]))
        print("New:", tostring(value))
        print("Call Stack:")
        print(debug.traceback())
        
        setclipboard(output)
    end
    return oldnewindex(self, key, value)
end

setreadonly(mt, true)
