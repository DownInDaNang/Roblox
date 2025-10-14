-- By DownInDaNang

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local acRemote
for _, v in ipairs(game.ReplicatedStorage:WaitForChild("Remotes"):GetChildren()) do
    if v:IsA("RemoteEvent") and v:GetAttribute("Tags") then
        acRemote = v
        break
    end
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldnamecall = mt.__namecall
local oldnewindex = mt.__newindex
local oldindex = mt.__index

mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "FireServer" and self == acRemote then
        return
    end
    if getnamecallmethod() == "Kick" then
        return
    end
    return oldnamecall(self, ...)
end)

mt.__newindex = newcclosure(function(self, key, val)
    if self:IsA("Humanoid") and key == "Health" and val == 0 then
        return
    end
    if key == "Size" then
        return
    end
    if key == "Enabled" and self.Name == "randomize" then
        return
    end
    return oldnewindex(self, key, val)
end)

mt.__index = newcclosure(function(self, key)
    if self == hrp and key == "Position" then
        local pos = oldindex(self, "CFrame").Position
        return Vector3.new(
            math.clamp(pos.X, -2000, 2000),
            math.clamp(pos.Y, -2000, 2000),
            math.clamp(pos.Z, -2000, 2000)
        )
    end
    return oldindex(self, key)
end)

setreadonly(mt, true)

for _, v in ipairs(char:GetDescendants()) do
    if v:IsA("LocalScript") then
        v.Enabled = false
    end
end

char.DescendantAdded:Connect(function(v)
    if v:IsA("LocalScript") then
        v.Enabled = false
    end
end)

game.ReplicatedStorage.Remotes.ChildRemoved:Connect(function() end)
plr.PlayerGui.ChildAdded:Connect(function() end)
