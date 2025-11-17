for i, v in getgc() do
    if typeof(v) == 'function' and islclosure(v) then
        local consts = debug.getconstants(v)
        if table.find(consts, 'FrogWasHere') then
            local upvals = debug.getupvalues(v)
            if #upvals == 7 then
                for idx = 1, 7 do
                    if typeof(upvals[idx]) == 'function' then
                        debug.setupvalue(v, idx, function() end)
                    end
                end
            elseif #upvals == 3 then
                debug.setupvalue(v, 1, function() end)
            end
        end
        if
            table.find(consts, 'BAC - Alpha-3B')
            or table.find(consts, 'Possible Script Injection!')
            or table.find(consts, 'RBXConnection Stopped')
            or table.find(consts, 'RBXConnection Suspended')
            or table.find(consts, 'CoreGui Overflow Detection!')
            or table.find(consts, 'Solora Detected!')
            or table.find(consts, 'Emulator Detected!')
            or table.find(consts, 'Remote Spy!')
            or table.find(consts, 'Instance added to nil')
            or table.find(consts, 'Critical Function Hooked!')
            or table.find(consts, 'Invalid DLL Detected')
            or table.find(consts, 'Hooked Env')
            or table.find(consts, 'Namecall Detected!')
            or table.find(consts, 'Speed Detected')
            or table.find(consts, 'WalkSpeed Hidden Property Set!')
            or table.find(consts, 'WalkSpeed Hook Detected!')
            or table.find(consts, 'Humanoid Hooked?')
            or table.find(consts, 'JumpPower Detected')
            or table.find(consts, 'Critical Walkspeed Hook')
            or table.find(consts, 'MCR')
            or table.find(consts, 'Modified Roblox Files!')
        then
            for idx = 1, #debug.getupvalues(v) do
                debug.setupvalue(v, idx, function() end)
            end
        end
        if
            table.find(consts, 'BodyGyro')
            or table.find(consts, 'BodyVelocity')
            or table.find(consts, 'BodyThrust')
            or table.find(consts, 'BodyPosition')
            or table.find(consts, 'BodyAngularVelocity')
        then
            for idx = 1, #debug.getupvalues(v) do
                debug.setupvalue(v, idx, function() end)
            end
        end
    end
end

local RS = game:GetService('ReplicatedStorage')
local LS = game:GetService('LogService')
local Players = game:GetService('Players')

for _, conn in getconnections(LS.MessageOut) do
    conn:Disable()
end

local BAC =
    RS:WaitForChild('RemoteEvents'):WaitForChild('Sanity'):WaitForChild('BAC')
local Old
Old = setmetatable({}, {
    __namecall = function(self, ...)
        if self == BAC and getnamecallmethod() == 'FireServer' then
            return
        end
        return Old.__namecall(self, ...)
    end,
})

Players.LocalPlayer.CharacterAdded:Connect(function(char)
    char.DescendantAdded:Connect(function() end)
end)

if Players.LocalPlayer.Character then
    Players.LocalPlayer.Character.DescendantAdded:Connect(function() end)
end

print("skibidi they say")
