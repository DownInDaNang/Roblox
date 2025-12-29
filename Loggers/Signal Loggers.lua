local oldnamecall2
oldnamecall2 = hookmetamethod(game, "__namecall", function(self, ...)
    if checkcaller() then
        local method = getnamecallmethod()
        if method == "Connect" or method == "connect" then
            local callback = ...
            local output = "Connect called\n"
            output = output .. "Signal: " .. tostring(self) .. "\n"
            output = output .. "Callback: " .. tostring(callback) .. "\n"
            output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
            
            print("Connect called")
            print("Signal:", tostring(self))
            print("Callback:", tostring(callback))
            print("Call Stack:")
            print(debug.traceback())
            
            setclipboard(output)
        end
    end
    return oldnamecall2(self, ...)
end)
