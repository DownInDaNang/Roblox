-- By DownInDaNang

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

local acRemote
for _, v in ipairs(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):GetChildren()) do
    if v:IsA("RemoteEvent") and v:GetAttribute("Tags") then
        acRemote = v
        break
    end
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldnamecall = mt.__namecall
local oldnewindex = mt.__newindex


mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and self == acRemote then
        local msg = args[1]
        if type(msg) == "string" then
            return
        end
    end
    
    return oldnamecall(self, ...)
end)


mt.__newindex = newcclosure(function(self, key, value)
    if self:IsA("Humanoid") and key == "Health" and value == 0 then
        return
    end
    return oldnewindex(self, key, value)
end)

setreadonly(mt, true)

local hrp = char:WaitForChild("HumanoidRootPart")
local oldIndex

oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if self == hrp and key == "Position" then
        local pos = oldIndex(self, "CFrame").Position
        return Vector3.new(
            math.clamp(pos.X, -2048, 2048),
            math.clamp(pos.Y, -2048, 2048),
            math.clamp(pos.Z, -2048, 2048)
        )
    end
    return oldIndex(self, key)
end))
