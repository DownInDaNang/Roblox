local rs = game:GetService("ReplicatedStorage")
local kick = rs:WaitForChild("KickExploitEvent", 5)

if kick then
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        if not checkcaller() and self == kick and getnamecallmethod() == "FireServer" then
            return
        end
        return old(self, ...)
    end)
end
