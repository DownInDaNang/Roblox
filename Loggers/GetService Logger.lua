local oldnamecall4
oldnamecall4 = hookmetamethod(game, "__namecall", function(self, ...)
    if checkcaller() then
        local method = getnamecallmethod()
        if method == "GetService" then
            local service = ...
            local output = "GetService called\n"
            output = output .. "Service: " .. tostring(service) .. "\n"
            output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
            
            print("GetService called")
            print("Service:", tostring(service))
            print("Call Stack:")
            print(debug.traceback())
            
            setclipboard(output)
        end
    end
    return oldnamecall4(self, ...)
end)
