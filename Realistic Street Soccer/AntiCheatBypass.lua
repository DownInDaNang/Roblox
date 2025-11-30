--[[

	@DownInDaNang

]]
local newcclosure = newcclosure or function(f) return f end
local rs = game:GetService("ReplicatedStorage")
local remote

for _, v in rs:WaitForChild("Remotes"):GetChildren() do
    if v:IsA("RemoteEvent") and v:GetAttribute("Tags") then
        remote = v
        break
    end
end

if remote then
	local old do old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not checkcaller() and self == remote and getnamecallmethod() == "FireServer" then
            return
        end
        return old(self, ...)
	end) end
end
