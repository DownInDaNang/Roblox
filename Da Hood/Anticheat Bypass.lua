local Game = cloneref(game)
local Players = cloneref(Game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local NamecallHook
NamecallHook = hookmetamethod(Game, "__namecall", newcclosure(function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    if not checkcaller() then
        if Method == "FireServer" and Self.Name == "MainEvent" then
            local EventName = Args[1]
            if typeof(EventName) == "string" and EventName:find("CHECKER") then
                return
            end
        end

        if Method == "Kick" then
            return
        end
    end

    return NamecallHook(Self, ...)
end))

local IndexHook
IndexHook = hookmetamethod(Game, "__index", newcclosure(function(Self, Key)
    if not checkcaller() then
        if Key == "Anchored" and Self.Name == "Head" then
            return false
        end
    end

    return IndexHook(Self, Key)
end))

local NewindexHook
NewindexHook = hookmetamethod(Game, "__newindex", newcclosure(function(Self, Key, Value)
    if checkcaller() then
        local IsBodyMover = Self:IsA("BodyMover") or Self:IsA("LinearVelocity")
        if IsBodyMover and Key == "Parent" then
            Self:SetAttribute("AllowedBM", true)
        end
    end

    return NewindexHook(Self, Key, Value)
end))
