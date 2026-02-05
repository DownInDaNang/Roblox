-- @DownInDaNang - Adonis Bypass | blocks detections, kicks, and crashes

local AdonisClient = nil

for _, Value in pairs(getgc(true)) do
    if type(Value) == "table" then
        if rawget(Value, "Anti") and rawget(Value, "Remote") then
            AdonisClient = Value
            break
        end
    end
end

if AdonisClient then
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local LogService = game:GetService("LogService")

    local function MakeCClosure(Func)
        return newcclosure(function(...)
            return Func(...)
        end)
    end

    local function HookFunc(Original, Hook)
        if not Original then return end
        local Old
        Old = hookfunction(Original, MakeCClosure(function(...)
            return Hook(Old, ...)
        end))
        return Old
    end

    local function HookMeta(Object, Metamethod, Hook)
        return hookmetamethod(Object, Metamethod, MakeCClosure(function(...)
            return Hook(...)
        end))
    end

    HookFunc(AdonisClient.Disconnect, function(Original, Info)
        warn("Blocked Disconnect: " .. tostring(Info))
    end)

    HookFunc(AdonisClient.Kill, function(Original, Info)
        warn("Blocked Kill: " .. tostring(Info))
    end)

    HookFunc(LocalPlayer.Kick, function(Original, Self, ...)
        if Self == LocalPlayer then
            warn("Blocked self-kick")
            return
        end
        return Original(Self, ...)
    end)

    HookFunc(AdonisClient.Remote.Send, function(Original, Command, ...)
        if Command == "Detected" then
            warn("Blocked Remote.Send 'Detected' command")
            return
        end
        return Original(Command, ...)
    end)

    HookFunc(AdonisClient.Remote.Fire, function(Original, Data, ...)
        local Decrypt = AdonisClient.Remote.NewDecrypt
        local Key = AdonisClient.Core.Key
        if Decrypt and Key and type(Data) == "string" then
            local Success, Name = pcall(Decrypt, Data, Key)
            if Success and (Name == "Detected" or Name == "BadMemes") then
                warn("Blocked Remote.Fire '" .. Name .. "' command")
                return
            end
        end
        return Original(Data, ...)
    end)

    local OriginalIndex = HookMeta(game, "__index", function(Self, Key)
        if tostring(Key) == "____________" then
            error("attempt to index nil with '____________'")
        end
        return OriginalIndex(Self, Key)
    end)

    local OriginalNewindex = HookMeta(game, "__newindex", function(Self, Key, Value)
        if tostring(Key) == "____________" then
            error("attempt to index nil with '____________'")
        end
        return OriginalNewindex(Self, Key, Value)
    end)

    local OriginalNamecall = HookMeta(game, "__namecall", function(...)
        local Method = getnamecallmethod()
        if Method == "____________" then
            error("____________ is not a valid member of Instance \"game\"")
        end
        return OriginalNamecall(...)
    end)

    HookFunc(LogService.GetLogHistory, function(Original, Self)
        return Original(Self)
    end)

    HookFunc(AdonisClient.Core.RemoteEvent.Object.FireServer, function(Original, Self, ...)
        return Original(Self, ...)
    end)

    HookFunc(AdonisClient.Core.RemoteEvent.Function.InvokeServer, function(Original, Self, ...)
        return Original(Self, ...)
    end)

    HookFunc(AdonisClient.Functions.Crash, function()
        warn("Blocked Adonis.Functions.Crash")
    end)

    HookFunc(AdonisClient.Functions.HardCrash, function()
        warn("Blocked Adonis.Functions.HardCrash")
    end)

    HookFunc(AdonisClient.Functions.GPUCrash, function()
        warn("Blocked Adonis.Functions.GPUCrash")
    end)

    HookFunc(AdonisClient.Functions.RAMCrash, function()
        warn("Blocked Adonis.Functions.RAMCrash")
    end)

    warn("Adonis Bypass Active")
end
