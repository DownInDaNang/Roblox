local o; o = hookmetamethod(game, "__namecall", function(s, ...)
    if not checkcaller() and getnamecallmethod() == "FireServer" and s.Name == "BallEvent" then
        local a = {...}
        if a[1] == "getAccuracy" then
            return o(s, a[1], 1)
        end
    end
    return o(s, ...)
end)
