local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if method == "FireServer" and tostring(self) == "BallEvent" and (args[2] == "shoot" or args[2] == "dunk") then
        args[3] = 1
        return old(self, unpack(args))
    end

    return old(self, ...)
end)

setreadonly(mt, true)
