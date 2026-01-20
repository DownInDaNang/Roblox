local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local PlayerController = Knit.GetController("PlayerController")
local PlayerService = Knit.GetService("PlayerService")
local LocalPlayer = game:GetService("Players").LocalPlayer

if PlayerController and PlayerController.Fix then
    local oldFix
    oldFix = hookfunction(PlayerController.Fix, newcclosure(function(self, reason)

        
        warn(string.format("[Anti-Cheat] Blocked 'Fix' call. Reason: %s", tostring(reason or "Unknown")))
        
        return
    end))
end

local oldKick
oldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(self, ...)
    if not checkcaller() then
        warn("[Anti-Cheat] Blocked an attempted kick from the game.")
        return
    end
    return oldKick(self, ...)
end))

if PlayerService and PlayerService.Claim and PlayerService.Claim.Fire then
    local oldClaimFire
    oldClaimFire = hookfunction(PlayerService.Claim.Fire, newcclosure(function(self, ...)
        if not checkcaller() then
            warn("[Anti-Cheat] Blocked detection report to server (PlayerService:Claim).")
            return
        end
        return oldClaimFire(self, ...)
    end))
end

task.spawn(function()
    while task.wait(1) do
        if PlayerController and PlayerController.Connections then
            if PlayerController.Connections.HeartbeatLoop then
                PlayerController.Connections.HeartbeatLoop:Disconnect()
            end
            if PlayerController.Connections.WalkSpeedFix then
                PlayerController.Connections.WalkSpeedFix:Disconnect()
            end
            if PlayerController.Connections.WalkSpeedFix2 then
                PlayerController.Connections.WalkSpeedFix2:Disconnect()
            end
        end
    end
end)
