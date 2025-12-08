local Gun = require(game:GetService("ReplicatedFirst"):WaitForChild("Classes"):WaitForChild("GunBehaviour"))

local old
old = hookmetamethod(workspace, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "Raycast" and self == workspace then
        if typeof(args[2]) == "Vector3" then
            local mag = args[2].Magnitude
            if mag == 60 or mag == 200 or (mag > 50 and mag < 250) then
                args[2] = args[2].Unit * 9999
            end
        end
    end
    
    return old(self, unpack(args))
end)
