local _hidden = {
    hookmetamethod = hookmetamethod,
    checkcaller = checkcaller,
    getnamecallmethod = getnamecallmethod,
    setclipboard = setclipboard
}

local oldnamecall4
oldnamecall4 = _hidden.hookmetamethod(game, "__namecall", function(self, ...)
    if _hidden.checkcaller() then
        local method = _hidden.getnamecallmethod()
        if method == "GetService" then
            local service = ...
            local output = "GetService called\n"
            output = output .. "Service: " .. tostring(service) .. "\n"
            output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
            
            print("GetService called")
            print("Service:", tostring(service))
            print("Call Stack:")
            print(debug.traceback())
            
            _hidden.setclipboard(output)
        end
    end
    return oldnamecall4(self, ...)
end)
