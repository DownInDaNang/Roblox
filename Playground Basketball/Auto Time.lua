--[[

	Credit : DownInDaNang / Norgumi - default timing vals should work fine
]]


local rs = game:GetService("ReplicatedStorage")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local action = rs.Remotes.Server.Action
local stats = game:GetService("Stats")

_G.ShotTimings = {
    Shooting = 0.41,
    Dunking = 0.41
}

_G.TimingOffset = function(distance, shottype)
    if shottype == "Dunking" then
        return 0
    end
    return 0.001 * distance
end

local ping = 0
task.spawn(function()
    while task.wait(1) do
        ping = stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end
end)

local dunkactive = false

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and self == action then
        if args[1].Type == "Shoot" and args[1].Shoot == true then
            task.spawn(function()
                local shotaction
                repeat 
                    task.wait()
                    shotaction = char:GetAttribute("Action")
                until shotaction == "Shooting" or shotaction == "Dunking"
                
                local hoop = char.Data.Hoop.Value:FindFirstChild("RimMesh", true)
                local dist = (hoop.Position - char.HumanoidRootPart.Position).Magnitude
                local timing = _G.ShotTimings[shotaction] + _G.TimingOffset(dist, shotaction) - (ping / 1000)
                
                task.wait(timing)
                action:FireServer({Type = "Shoot", Shoot = false})
            end)
        elseif args[1].Action == "Jump" and args[1].Jump == true and not dunkactive then
            if char:FindFirstChild("Ball") then
                dunkactive = true
                task.spawn(function()
                    repeat task.wait() until char:GetAttribute("Action") == "Dunking"
                    local hoop = char.Data.Hoop.Value:FindFirstChild("RimMesh", true)
                    local dist = (hoop.Position - char.HumanoidRootPart.Position).Magnitude
                    local timing = _G.ShotTimings.Dunking + _G.TimingOffset(dist, "Dunking") - (ping / 1000)
                    
                    task.wait(timing)
                    action:FireServer({Action = "Jump", Jump = false})
                    dunkactive = false
                end)
            end
        end
    end
    
    return old(self, ...)
end))
