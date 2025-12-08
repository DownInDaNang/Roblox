-- rejoin after washing for updated money

local Plr = game.Players.LocalPlayer
local RF = game.ReplicatedFirst:WaitForChild("Classes")
local PC = require(RF:WaitForChild("PlayerControl"))

repeat task.wait() until PC.LocalPlayer

local LP = PC.LocalPlayer
local TD = require(game.ReplicatedStorage.Modules.Bins.TankData)

local Max = TD[LP.Inventory.EquippedTank].MaxCapacity

LP.Inventory.CurrentTankLevel = Max

game:GetService("RunService").Heartbeat:Connect(function()
    local CMax = TD[LP.Inventory.EquippedTank].MaxCapacity
    if LP.Inventory.CurrentTankLevel < CMax then
        LP.Inventory.CurrentTankLevel = CMax
    end
end)
