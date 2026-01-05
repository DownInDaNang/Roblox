local Adonis: any = nil

for _, Value: any in pairs(getgc(true)) do
    if type(Value) == "table" then
        if rawget(Value, "Anti") and rawget(Value, "Remote") then
            Adonis = Value
            break
        end
    end
end

if Adonis then
    print("client found")

    local Player: any = game:GetService("Players").LocalPlayer

    local function Hook(Func: any, Label: string)
        if not Func then return end
        local Old: any
        Old = hookfunction(Func, newcclosure(function(...)
            print("REJECTED " .. Label)
            return
        end))
    end

    Hook(Adonis.Disconnect, "Disconnect")
    Hook(Adonis.Kill, "Kill")

    local Send: any = Adonis.Remote.Send
    if Send then
        local OldSend: any
        OldSend = hookfunction(Send, newcclosure(function(Command: any, ...)
            if Command == "Detected" then
                print("GNG PLAYING HOF DEFENCE FOR WHAT???")
                return
            end
            return OldSend(Command, ...)
        end))
    end

    local Fire: any = Adonis.Remote.Fire
    if Fire then
        local OldFire: any
        OldFire = hookfunction(Fire, newcclosure(function(Data: any, ...)
            local Decrypt: any = Adonis.Remote.NewDecrypt
            local Key: any = Adonis.Core.Key
            if Decrypt and Key and type(Data) == "string" then
                local Ok: any, Name: any = pcall(Decrypt, Data, Key)
                if Ok and (Name == "Detected" or Name == "BadMemes") then
                    print("MUTOMBO WITH THE REJECTION")
                    return
                end
            end
            return OldFire(Data, ...)
        end))
    end

    local Kick: any = Player.Kick
    local OldKick: any
    OldKick = hookfunction(Kick, newcclosure(function(Self: any, ...)
        if Self == Player then
            print("BLOCKED BY JAMES")
            return
        end
        return OldKick(Self, ...)
    end))

    print("Sigma")
end
