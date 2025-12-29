local oldrequest = request
local oldhttpget = game.HttpGet

getgenv().request = function(options)
    if checkcaller() then
        local output = "request called\n"
        output = output .. "URL: " .. tostring(options.Url or options.url) .. "\n"
        output = output .. "Method: " .. tostring(options.Method or "GET") .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("request called")
        print("URL:", tostring(options.Url or options.url))
        print("Method:", tostring(options.Method or "GET"))
        print("Call Stack:")
        print(debug.traceback())
        
        setclipboard(output)
    end
    return oldrequest(options)
end

local oldnamecall3
oldnamecall3 = hookmetamethod(game, "__namecall", function(self, ...)
    if checkcaller() then
        local method = getnamecallmethod()
        if method == "HttpGet" or method == "HttpGetAsync" then
            local url = ...
            local output = "HttpGet called\n"
            output = output .. "URL: " .. tostring(url) .. "\n"
            output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
            
            print("HttpGet called")
            print("URL:", tostring(url))
            print("Call Stack:")
            print(debug.traceback())
            
            setclipboard(output)
        end
    end
    return oldnamecall3(self, ...)
end)
