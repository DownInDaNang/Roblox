-- @DownInDaNang (some things still detected)

local RS = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer

local ACRemote
for _, Remote in RS.Remotes:GetChildren() do
    if Remote:IsA("RemoteEvent") and Remote:GetAttribute("Tags") == "" then
        ACRemote = Remote
        break
    end
end

local Old
Old = hookmetamethod(game, "__namecall", function(Self, ...)
    if getnamecallmethod() == "FireServer" and Self == ACRemote and not checkcaller() then
        return
    end
    return Old(Self, ...)
end)

local function Init()
    local Hum = Player.Character:WaitForChild("Humanoid")
    
    local Found = false
    for _, Conn in getconnections(Hum.Changed) do
        Found = true
        Conn:Disconnect()
    end
    
    if Found then
        warn("AC connection found :(")
    end
    
    for _, Part in Player.Character:GetDescendants() do
        if Part:IsA("BasePart") then
            for _, Conn in getconnections(Part:GetPropertyChangedSignal("Size")) do
                Conn:Disconnect()
            end
        end
    end
    
    warn("skibidi :)")
end

Init()

Player.CharacterAdded:Connect(function()
    warn("You resetted your character, wait 5 secs before exploiting again")
    task.wait(5)
    Init()
end)

local Ball = workspace:WaitForChild("ball")
for _, Conn in getconnections(Ball:GetPropertyChangedSignal("Size")) do
    Conn:Disconnect()
end
for _, Conn in getconnections(Ball.ChildAdded) do
    Conn:Disconnect()
end

for _, Conn in getconnections(Player.PlayerGui.ChildAdded) do
    Conn:Disconnect()
end

for _, Conn in getconnections(RS.Remotes.ChildRemoved) do
    Conn:Disconnect()
end
