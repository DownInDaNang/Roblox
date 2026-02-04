local _hidden = {
    hookmetamethod = hookmetamethod,
    checkcaller = checkcaller,
    getnamecallmethod = getnamecallmethod,
    setclipboard = setclipboard
}

local oldnamecall2
oldnamecall2 = _hidden.hookmetamethod(game, "__namecall", function(self, ...)
    if _hidden.checkcaller() then
        local method = _hidden.getnamecallmethod()
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
            
            _hidden.setclipboard(output)
        end
    end
    return oldnamecall2(self, ...)
end)
