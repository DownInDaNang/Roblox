--[[

	recently got patched, working on another

]]

local rs = game:GetService("ReplicatedStorage")
local remote

for _, v in rs:WaitForChild("Remotes"):GetChildren() do
    if v:IsA("RemoteEvent") and v:GetAttribute("Tags") then
        remote = v
        break
    end
end

if remote then
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        if not checkcaller() and self == remote and getnamecallmethod() == "FireServer" then
            return
        end
        return old(self, ...)
    end)
    
    setreadonly(mt, true)
end
