local _hidden = {
    hookmetamethod = hookmetamethod,
    checkcaller = checkcaller,
    getnamecallmethod = getnamecallmethod,
    setclipboard = setclipboard
}

local oldnamecall
oldnamecall = _hidden.hookmetamethod(game, "__namecall", function(self, ...)
    if _hidden.checkcaller() then
        local method = _hidden.getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local args = {...}
            local argsStr = ""
            for i, arg in args do
                argsStr = argsStr .. tostring(arg)
                if i < #args then argsStr = argsStr .. ", " end
            end
            
            local output = "Method: " .. method .. "\n"
            output = output .. "Remote: " .. tostring(self) .. "\n"
            output = output .. "Path: " .. self:GetFullName() .. "\n"
            output = output .. "Args: " .. argsStr .. "\n"
            output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
            
            print("Method:", method)
            print("Remote:", tostring(self))
            print("Path:", self:GetFullName())
            print("Args:", argsStr)
            print("Call Stack:")
            print(debug.traceback())
            
            _hidden.setclipboard(output)
        end
    end
    return oldnamecall(self, ...)
end)
