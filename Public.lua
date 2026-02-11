local StarterGui = game:GetService("StarterGui")

local old = {}
old.namecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not checkcaller() then
        local method = getnamecallmethod()
        if method == "FireServer" and (self:GetAttribute("Tagged") or self.Name:find("Remote")) then
            return
        end
        if method == "Connect" and (self.Name == "ChildAdded" or self.Name == "MessageOut") then
            return Instance.new("BindableEvent").Event
        end
        if self == StarterGui and method == "SetCore" then
            local args = {...}
            if args[1] == "DevConsoleVisible" then
                return
            end
        end
    end
    return old.namecall(self, ...)
end)

old.index = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and typeof(self) == "Instance" then
        if self:IsA("Humanoid") then
            if key == "WalkSpeed" then return 16 end
            if key == "JumpPower" then return 50 end
            if key == "MaxHealth" then return 100 end
            if key == "Sit" then return false end
            if key == "PlatformStand" then return false end
        end
        if key == "Size" and self.Name == "ball" then
            return Vector3.new(2.336, 2.336, 2.336)
        end
    end
    return old.index(self, key)
end)
