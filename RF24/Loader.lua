--// @LOL5678906

local players: Players = game:GetService("Players")
local debris: Debris = game:GetService("Debris")
local tweens: TweenService = game:GetService("TweenService")
local runservice: RunService = game:GetService("RunService")

local localplayer: Player = players.LocalPlayer

local config: {[string]: any} = {
    power = 10, 
    arc = 15, -- 5 rec
    velocitypower = 1.5,
    autogoal = false
}

local function haskicktool(): boolean
    local character: Model? = localplayer.Character
    if character and character:FindFirstChild("Kick") then
        return true
    end
    return false
end

local function gettargetgoal(ballposition: Vector3): BasePart?
    local gamefolder: Instance? = workspace:FindFirstChild("game")
    local system: Instance? = gamefolder and gamefolder:FindFirstChild("system")
    local goals: Instance? = system and system:FindFirstChild("goal")
    
    if not goals then return nil end
    
    local home: BasePart? = goals:FindFirstChild("Home") :: BasePart?
    local away: BasePart? = goals:FindFirstChild("Away") :: BasePart?
    
    if not home or not away then return nil end

    local pitch: Instance? = workspace:FindFirstChild("pitch")
    local main: Instance? = pitch and pitch:FindFirstChild("main")
    local istraining: boolean = if main and main:FindFirstChild("Training") then true else false

    if istraining then
        local homedist: number = (home.Position - ballposition).Magnitude
        local awaydist: number = (away.Position - ballposition).Magnitude
        return if homedist < awaydist then home else away
    else
        local team: Team? = localplayer.Team
        if team then
            if team.Name == "Home" then
                return away
            elseif team.Name == "Away" then
                return home
            end
        end
        
        local homedist: number = (home.Position - ballposition).Magnitude
        local awaydist: number = (away.Position - ballposition).Magnitude
        return if homedist < awaydist then home else away
    end
end

local oldadditem: any
oldadditem = hookfunction(debris.AddItem, newcclosure(function(self: Debris, item: Instance, time: number): ()
    if not checkcaller() and typeof(item) == "Instance" then
        if item:IsA("BodyAngularVelocity") or item:IsA("BodyForce") or item:IsA("BodyVelocity") then
            return
        end
    end
    return oldadditem(self, item, time)
end))

local oldtweencreate: any
oldtweencreate = hookfunction(tweens.Create, newcclosure(function(self: TweenService, instance: Instance, info: TweenInfo, properties: {[string]: any}): Tween
    if not checkcaller() and typeof(instance) == "Instance" and instance:IsA("BodyForce") then
        return oldtweencreate(self, instance, info, {})
    end
    return oldtweencreate(self, instance, info, properties)
end))

local meta: any = getrawmetatable(game)
local oldnewindex: any = meta.__newindex
local oldnamecall: any = meta.__namecall

setreadonly(meta, false)

meta.__newindex = newcclosure(function(self: any, key: string, value: any): ()
    if not checkcaller() and config.autogoal and haskicktool() then
        if typeof(self) == "Instance" then
            if self:IsA("BodyAngularVelocity") and key == "AngularVelocity" then
                return oldnewindex(self, key, value * config.power)
            elseif self:IsA("BodyForce") and key == "Force" then
                local ball: BasePart? = self.Parent :: BasePart?
                if ball and ball:IsA("BasePart") then
                    local goal: BasePart? = gettargetgoal(ball.Position)
                    if goal then
                        local dist: number = (goal.Position - ball.Position).Magnitude
                        local dynamicpower: number = math.clamp(dist / 45, 0.7, 2.5) * config.power
                        local dynamicarc: number = math.clamp(dist / 90, 0.1, 1.2) * config.arc
                        
                        local randomoffset: Vector3 = Vector3.new(math.random(-7, 7), math.random(-2, 2), math.random(-7, 7))
                        local targetpos: Vector3 = goal.Position + Vector3.new(0, dynamicarc, 0) + randomoffset
                        local direction: Vector3 = (targetpos - ball.Position).Unit
                        
                        local goalname: string = goal.Name
                        local pitch: Instance? = workspace:FindFirstChild("pitch")
                        local nets: Instance? = pitch and pitch:FindFirstChild("nets")
                        local specificnet: Instance? = nets and nets:FindFirstChild(goalname)
                        local netholder: BasePart? = specificnet and specificnet:FindFirstChild("BoxNetHolder") :: BasePart?
                        
                        if netholder then
                            local balltogol: number = (targetpos - ball.Position).Magnitude
                            local balltonet: number = (netholder.Position - ball.Position).Magnitude
                            
                            if balltonet < balltogol then
                                local curveoffset: Vector3 = Vector3.new(direction.Z, 0, -direction.X) * 18
                                direction = (targetpos + curveoffset - ball.Position).Unit
                            end
                        end
                        
                        return oldnewindex(self, key, direction * value.Magnitude * dynamicpower)
                    end
                end
                return oldnewindex(self, key, value * config.power)
            elseif self:IsA("BodyVelocity") and key == "Velocity" then
                local ball: BasePart? = self.Parent :: BasePart?
                if ball and ball:IsA("BasePart") then
                    local goal: BasePart? = gettargetgoal(ball.Position)
                    if goal then
                        local dist: number = (goal.Position - ball.Position).Magnitude
                        local dynamicarc: number = math.clamp(dist / 90, 0.1, 1.2) * config.arc
                        
                        local randomoffset: Vector3 = Vector3.new(math.random(-7, 7), math.random(-2, 2), math.random(-7, 7))
                        local targetpos: Vector3 = goal.Position + Vector3.new(0, dynamicarc, 0) + randomoffset
                        local direction: Vector3 = (targetpos - ball.Position).Unit
                        return oldnewindex(self, key, direction * value.Magnitude * config.velocitypower)
                    end
                end
                return oldnewindex(self, key, value * config.velocitypower)
            end
        end
    end
    return oldnewindex(self, key, value)
end)

meta.__namecall = newcclosure(function(self: any, ...: any): any
    local method: string = getnamecallmethod()
    if not checkcaller() and method == "Connect" and typeof(self) == "RBXScriptSignal" then
        local args: {any} = {...}
        local callback: any = args[1]
        if typeof(callback) == "function" and islclosure(callback) then
            local constants: {any} = debug.getconstants(callback)
            if table.find(constants, "DoCleaning") then
                return nil
            end
        end
    end
    return oldnamecall(self, ...)
end)

setreadonly(meta, true)

local gui = loadstring(game:HttpGet('https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua'))()
local w = gui:CreateWindow({Title = "RF24 | Credit : LOL5678906 | Last updated : 2/16/25",Size = UDim2.new(0, 400, 0, 450),Position = UDim2.new(0.5, 0, 0.5, 0)})
w:Center()
local t = w:CreateTab({Name = "Main"})

local pp = 5
local ph = 5
local os1, os2, os3, os4, os5, os6, os7, airborneOriginal

t:Checkbox({Label = "Infinite Stamina",Value = false,Callback = function(s, v)
    if v then
        local sc = localplayer.PlayerScripts.controllers.movementController
        local m = require(sc)
        m.start = function() end
        m.heal = function() end
        local oi = m.init
        m.init = function(self)
            oi(self)
            self.stamina.Value = self.maxStamina
            self.stamina.Changed:Connect(function()
                self.stamina.Value = self.maxStamina
            end)
            self.humanoid.WalkSpeed = self.sprintSpeed
            self.active = true
            sc:SetAttribute("sprinting", true)
            sc:SetAttribute("canSprint", true)
            self.humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if self.humanoid.WalkSpeed < self.sprintSpeed then
                    self.humanoid.WalkSpeed = self.sprintSpeed
                end
            end)
        end
    end
end})

t:Separator()

t:Checkbox({Label = "Auto Goal (BETA)", Value = false, Callback = function(s, v) config.autogoal = v end})
t:Slider({Label = "Auto Goal Power", Format = "%.1f", Value = 10, MinValue = 0, MaxValue = 50, Callback = function(s, v) config.power = v end})
t:Slider({Label = "Auto Goal Arc", Format = "%.1f", Value = 15, MinValue = 0, MaxValue = 50, Callback = function(s, v) config.arc = v end})
t:Slider({Label = "Auto Goal Velocity Power", Format = "%.1f", Value = 1.5, MinValue = 0, MaxValue = 10, Callback = function(s, v) config.velocitypower = v end})

t:Separator()

t:Checkbox({Label = "Throw Without Ball/GK Check",Value = false,Callback = function(s, v)
    local m = require(localplayer.PlayerScripts.mechanics.gk.binds.throw)
    if v then
        if not os5 then os5 = m.inputBegan end
        m.inputBegan = function(self, root)
            if self.using then return end
            return os5(self, root)
        end
    else
        if os5 then m.inputBegan = os5 end
    end
end})

t:Separator()

t:Slider({Label = "Punch Power (Not tested on the main server — use with caution)",Format = "%.1f",Value = 5,MinValue = 1,MaxValue = 100,Callback = function(s, v) pp = v end})
t:Slider({Label = "Punch Height",Format = "%.1f",Value = 5,MinValue = 1,MaxValue = 100,Callback = function(s, v) ph = v end})

t:Checkbox({Label = "Custom Punch Power",Value = false,Callback = function(s, v)
    local m = require(localplayer.PlayerScripts.mechanics.gk.binds.punch)
    if v then
        if not os2 then os2 = m.onTouched end
        m.onTouched = function(l, b)
            if m.canReact then
                local vc = localplayer.Character.HumanoidRootPart.CFrame.LookVector * (35 * pp) + Vector3.new(0, 20 * ph, 0)
                m.root:gkReact({ball = b,limb = l,vector = vc,maxForce = Vector3.new(1, 1, 1) * math.huge})
            end
        end
    else
        if os2 then m.onTouched = os2 end
    end
end})

t:Separator()

t:Checkbox({Label = "Infinite Slide Range (slide anywhere without distance restriction)",Value = false,Callback = function(s, v)
    local m = require(localplayer.PlayerScripts.mechanics.tackle.binds["slide tackle"])
    if v then
        if not os1 then os1 = m.inputBegan end
        m.inputBegan = function(self, c)
            local o = c.getNearestBall
            c.getNearestBall = function() return true end
            local r = os1(self, c)
            c.getNearestBall = o
            return r
        end
    else
        if os1 then m.inputBegan = os1 end
    end
end})

t:Checkbox({Label = "Airborne Tackle", Value = false, Callback = function(s, v)
    local targetFunction = filtergc("function", {Name = "isAirbourne"}, true)
    if v then
        if targetFunction and not isfunctionhooked(targetFunction) then
            airborneOriginal = hookfunction(targetFunction, function(...)
                if not checkcaller() then
                    return false
                end
                return airborneOriginal(...)
            end)
        end
    else
        if targetFunction and isfunctionhooked(targetFunction) then
            restorefunction(targetFunction)
        end
    end
end})

t:Checkbox({Label = "Knuckle Ball (broke?)",Value = false,Callback = function(s, v)
    local k = localplayer.PlayerScripts.mechanics.kick.binds.kick
    if v then
        k:SetAttribute("spin", "knuckle")
        k:GetAttributeChangedSignal("spin"):Connect(function()
            if k:GetAttribute("spin") ~= "knuckle" then
                k:SetAttribute("spin", "knuckle")
            end
        end)
    else
        k:SetAttribute("spin", nil)
    end
end})

t:Checkbox({Label = "No Slide Cooldown",Value = false,Callback = function(s, v)
    local m = require(localplayer.PlayerScripts.mechanics.tackle.binds["slide tackle"])
    if v then
        if not os4 then os4 = m.inputBegan end
        m.inputBegan = function(self, c)
            self.using = false
            return os4(self, c)
        end
    else
        if os4 then m.inputBegan = os4 end
    end
end})

t:Checkbox({Label = "Remove Punch Cooldown",Value = false,Callback = function(s, v)
    local m = require(localplayer.PlayerScripts.mechanics.gk.binds.punch)
    if v then
        if not os3 then os3 = m.inputBegan end
        m.inputBegan = function(self, r)
            if not r:gkCheck() then return end
            self.using = false
            self.canReact = true
            r.collisions:toggle("all", "2_limbs")
            self.react.new({"Head","UpperTorso","LowerTorso","RightUpperArm","RightLowerArm","RightHand","LeftUpperArm","LeftLowerArm","LeftHand","Collide","Torso"})
            os3(self, r)
            task.delay(0.05, function()
                r.collisions:toggle("reset")
                self.react.clear()
                self.canReact = false
                self.using = false
            end)
        end
    else
        if os3 then m.inputBegan = os3 end
    end
end})

t:Checkbox({Label = "Remove Power Shot Cooldown",Value = false,Callback = function(s, v)
    local m = require(localplayer.PlayerScripts.mechanics.kick.binds["power shot"])
    if v then
        if not os6 then os6 = m.inputBegan end
        m.inputBegan = function(self, root, dir)
            self.using = false
            return os6(self, root, dir)
        end
    else
        if os6 then m.inputBegan = os6 end
    end
end})

t:Separator()

local ec
local e = {}

t:Checkbox({Label = "Ball ESP",Value = false,Callback = function(s, v)
    if v then
        local c = localplayer.Character or localplayer.CharacterAdded:Wait()
        local r = c:WaitForChild("HumanoidRootPart")
        local cm = workspace.CurrentCamera
        local m = require(game:GetService("ReplicatedStorage").engine.modules.Balls)
        ec = runservice.RenderStepped:Connect(function()
            for _, b in m.GetBalls(true) do
                if b and not e[b] then
                    local bx = Drawing.new("Square")
                    bx.Thickness = 2
                    bx.Color = Color3.fromRGB(255, 0, 0)
                    bx.Filled = false
                    bx.Visible = true
                    bx.ZIndex = 2
                    e[b] = bx
                end
            end
            for b, bx in e do
                if b and b.Parent then
                    local d = (b.Position - r.Position).Magnitude
                    if d < 100 then
                        local ps, vs = cm:WorldToViewportPoint(b.Position)
                        if vs then
                            bx.Size = Vector2.new(2000 / ps.Z, 2000 / ps.Z)
                            bx.Position = Vector2.new(ps.X - bx.Size.X / 2, ps.Y - bx.Size.Y / 2)
                            bx.Visible = true
                        else
                            bx.Visible = false
                        end
                    else
                        bx.Visible = false
                    end
                else
                    bx:Remove()
                    e[b] = nil
                end
            end
        end)
    else
        if ec then ec:Disconnect() end
        for b, bx in e do
            bx:Remove()
            e[b] = nil
        end
    end
end})

t:Checkbox({Label = "Remove Distance Limit on Markers",Value = false,Callback = function(s, v)
    local m = require(localplayer.PlayerScripts.controllers.markerController)
    if v then
        if not os7 then os7 = m.init end
        m.init = function(self)
            local sol = require(localplayer.PlayerScripts.controllers.markerController:WaitForChild("solver", 100))
            sol.ClampMarkerToBorder = function(_, _, x, y, _)
                return x, y
            end
            return os7(self)
        end
    else
        if os7 then m.init = os7 end
    end
end})


local ct = w:CreateTab({Name = "Credits"})

ct:Label({Text = "✦ • ───────── • ✦"})
ct:Label({Text = "RF24"})
ct:Label({Text = "Developer: LOL5678906"})
ct:Label({Text = "GitHub Release"})
ct:Label({Text = "Discord: discord.gg/2VJf9MHY"})
ct:Label({Text = "✦ • ───────── • ✦"})



local ut = w:CreateTab({Name = "Updates"})
local updates = {"12/7/25 - Fixed Infinite Stamina not working."}

ut:Label({Text = "✦ • ───────── • ✦"})
ut:Label({Text = "Recent Updates:"})
ut:Label({Text = ""})

for _, update in ipairs(updates) do
    ut:Label({Text = update})
end

ut:Label({Text = "✦ • ───────── • ✦"})


--[[
random junkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
]]
