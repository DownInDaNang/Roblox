local player = game.Players.LocalPlayer
local range = 100

game:GetService("RunService").Heartbeat:Connect(function()
    if player.Character:FindFirstChild("Blade") then
        local zone = player.Zone.Value
        
        if zone == 2 or zone == 1 then
            for i = 1, 5 do
                for _, mob in pairs(workspace.MobSpawns[i].Mobs:GetChildren()) do
                    if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and (player.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).magnitude < range then
                        game.ReplicatedStorage.Attack:FireServer(mob)
                    end
                end
            end
        end
        
        if zone == 3 then
            for i = 1, 2 do
                for _, mob in pairs(workspace.BossRoom1[i].Mobs:GetChildren()) do
                    if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and (player.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).magnitude < range then
                        game.ReplicatedStorage.Attack:FireServer(mob)
                    end
                end
            end
        end
    end
end)
