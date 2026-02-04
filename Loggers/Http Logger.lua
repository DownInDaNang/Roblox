local _hidden = {
    request = request,
    hookmetamethod = hookmetamethod,
    checkcaller = checkcaller,
    getnamecallmethod = getnamecallmethod,
    setclipboard = setclipboard,
    getgenv = getgenv
}

local oldrequest = _hidden.request
local oldhttpget = game.HttpGet

_hidden.getgenv().request = function(options)
    if _hidden.checkcaller() then
        local output = "request called\n"
        output = output .. "URL: " .. tostring(options.Url or options.url) .. "\n"
        output = output .. "Method: " .. tostring(options.Method or "GET") .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("request called")
        print("URL:", tostring(options.Url or options.url))
        print("Method:", tostring(options.Method or "GET"))
        print("Call Stack:")
        print(debug.traceback())
        
        _hidden.setclipboard(output)
    end
    return oldrequest(options)
end

local oldnamecall3
oldnamecall3 = _hidden.hookmetamethod(game, "__namecall", function(self, ...)
    if _hidden.checkcaller() then
        local method = _hidden.getnamecallmethod()
        if method == "HttpGet" or method == "HttpGetAsync" then
            local url = ...
            local output = "HttpGet called\n"
            output = output .. "URL: " .. tostring(url) .. "\n"
            output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
            
            print("HttpGet called")
            print("URL:", tostring(url))
            print("Call Stack:")
            print(debug.traceback())
            
            _hidden.setclipboard(output)
        end
    end
    return oldnamecall3(self, ...)
end)
