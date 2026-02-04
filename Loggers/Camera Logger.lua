local _hidden = {
    getrawmetatable = getrawmetatable,
    setreadonly = setreadonly,
    checkcaller = checkcaller,
    setclipboard = setclipboard
}

local camera = workspace.CurrentCamera
local mt = _hidden.getrawmetatable(camera)
_hidden.setreadonly(mt, false)
local oldnewindex = mt.__newindex

mt.__newindex = function(self, key, value)
    if _hidden.checkcaller() and self == camera then
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
        
        _hidden.setclipboard(output)
    end
    return oldnewindex(self, key, value)
end

_hidden.setreadonly(mt, true)
