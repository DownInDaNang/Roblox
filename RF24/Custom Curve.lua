--// @LOL5678906

local debris: Debris = game:GetService("Debris")
local tweens: TweenService = game:GetService("TweenService")

local oldAddItem: any
oldAddItem = hookfunction(debris.AddItem, newcclosure(function(self: any, item: any, time: number): ()
    if not checkcaller() and typeof(item) == "Instance" then
        if item:IsA("BodyAngularVelocity") or item:IsA("BodyForce") or item:IsA("BodyVelocity") then
            return
        end
    end
    return oldAddItem(self, item, time)
end))

local oldTweenCreate: any
oldTweenCreate = hookfunction(tweens.Create, newcclosure(function(self: any, instance: any, info: any, properties: any): any
    if not checkcaller() and typeof(instance) == "Instance" and instance:IsA("BodyForce") then
        return oldTweenCreate(self, instance, info, {})
    end
    return oldTweenCreate(self, instance, info, properties)
end))

local meta: any = getrawmetatable(game)
local oldNewindex: any = meta.__newindex
local oldNamecall: any = meta.__namecall

setreadonly(meta, false)

meta.__newindex = newcclosure(function(self: any, key: string, value: any): ()
    if not checkcaller() then
        if typeof(self) == "Instance" then
            if self:IsA("BodyAngularVelocity") and key == "AngularVelocity" then
                return oldNewindex(self, key, value * 15)
            elseif self:IsA("BodyForce") and key == "Force" then
                return oldNewindex(self, key, value * 15)
            elseif self:IsA("BodyVelocity") and key == "Velocity" then
                return oldNewindex(self, key, value * 1.5)
            end
        end
    end
    return oldNewindex(self, key, value)
end)

meta.__namecall = newcclosure(function(self: any, ...: any): any
    local method: string = getnamecallmethod()
    if not checkcaller() and method == "Connect" and typeof(self) == "RBXScriptSignal" then
        local callback: any = ({...})[1]
        if typeof(callback) == "function" and islclosure(callback) then
            local constants: {any} = debug.getconstants(callback)
            if table.find(constants, "DoCleaning") then
                return nil
            end
        end
    end
    return oldNamecall(self, ...)
end)

setreadonly(meta, true)
