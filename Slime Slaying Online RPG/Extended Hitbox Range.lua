local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "GetPartBoundsInBox" and args[2] then
        args[2] = args[2] + Vector3.new(55, 55, 55)
        return old(self, args[1], args[2], args[3])
    end
    
    return old(self, ...)
end)
