local p = game:GetService("Players").LocalPlayer
local gui = loadstring(game:HttpGet('https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua'))()
local w = gui:CreateWindow({
    Title = "RF24 | Credit : DownInDaNang | Last updated : 12/5/25",
    Size = UDim2.new(0, 400, 0, 450),
    Position = UDim2.new(0.5, 0, 0.5, 0)
})
w:Center()
local t = w:CreateTab({Name = "Main"})

local pp = 5
local ph = 5
local os1, os2, os3, os4

t:Checkbox({
    Label = "Infinite Stamina",
    Value = false,
    Callback = function(s, v)
        if v then
            local sc = p.PlayerScripts.controllers.movementController
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
    end
})

t:Checkbox({
    Label = "Always Full Power (throw)",
    Value = false,
    Callback = function(s, v)
        local m = require(p.PlayerScripts.mechanics.gk.binds.throw)
        if v then
            m.minPower = 100
            m.minHeight = 50
        else
            m.minPower = 30
            m.minHeight = -10
        end
    end
})

t:Checkbox({
    Label = "Always Full Power (kicks only)",
    Value = false,
    Callback = function(s, v)
        local m = require(p.PlayerScripts.mechanics.kick.binds.kick)
        if v then
            m.minPower = 115
            m.minHeight = 28
        else
            m.minPower = 0
            m.minHeight = 0
        end
    end
})

t:Separator()

t:Slider({
    Label = "Punch Power",
    Format = "%.1f",
    Value = 5,
    MinValue = 1,
    MaxValue = 20,
    Callback = function(s, v)
        pp = v
    end
})

t:Slider({
    Label = "Punch Height",
    Format = "%.1f",
    Value = 5,
    MinValue = 1,
    MaxValue = 20,
    Callback = function(s, v)
        ph = v
    end
})

t:Checkbox({
    Label = "Custom Punch Power",
    Value = false,
    Callback = function(s, v)
        local m = require(p.PlayerScripts.mechanics.gk.binds.punch)
        if v then
            if not os2 then
                os2 = m.onTouched
            end
            m.onTouched = function(l, b)
                if m.canReact then
                    local vc = p.Character.HumanoidRootPart.CFrame.LookVector * (35 * pp) + Vector3.new(0, 20 * ph, 0)
                    m.root:gkReact({
                        ball = b,
                        limb = l,
                        vector = vc,
                        maxForce = Vector3.new(1, 1, 1) * math.huge
                    })
                end
            end
        else
            if os2 then
                m.onTouched = os2
            end
        end
    end
})

t:Separator()

t:Checkbox({
    Label = "Infinite Slide Range (slide anywhere without distance restriction)",
    Value = false,
    Callback = function(s, v)
        local m = require(p.PlayerScripts.mechanics.tackle.binds["slide tackle"])
        if v then
            if not os1 then
                os1 = m.inputBegan
            end
            m.inputBegan = function(self, c)
                local o = c.getNearestBall
                c.getNearestBall = function()
                    return true
                end
                local r = os1(self, c)
                c.getNearestBall = o
                return r
            end
        else
            if os1 then
                m.inputBegan = os1
            end
        end
    end
})

t:Checkbox({
    Label = "Knuckle Ball (broke?)",
    Value = false,
    Callback = function(s, v)
        local k = p.PlayerScripts.mechanics.kick.binds.kick
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
    end
})

t:Checkbox({
    Label = "No Slide Cooldown",
    Value = false,
    Callback = function(s, v)
        local m = require(p.PlayerScripts.mechanics.tackle.binds["slide tackle"])
        if v then
            if not os4 then
                os4 = m.inputBegan
            end
            m.inputBegan = function(self, c)
                self.using = false
                return os4(self, c)
            end
        else
            if os4 then
                m.inputBegan = os4
            end
        end
    end
})

t:Checkbox({
    Label = "Remove Punch Cooldown",
    Value = false,
    Callback = function(s, v)
        local m = require(p.PlayerScripts.mechanics.gk.binds.punch)
        if v then
            if not os3 then
                os3 = m.inputBegan
            end
            m.inputBegan = function(self, r)
                if not r:gkCheck() then
                    return
                end
                self.using = false
                self.canReact = true
                r.collisions:toggle("all", "2_limbs")
                self.react.new({"Head", "UpperTorso", "LowerTorso", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand", "Collide", "Torso"})
                os3(self, r)
                task.delay(0.05, function()
                    r.collisions:toggle("reset")
                    self.react.clear()
                    self.canReact = false
                    self.using = false
                end)
            end
        else
            if os3 then
                m.inputBegan = os3
            end
        end
    end
})

t:Separator()

local ec
local e = {}

t:Checkbox({
    Label = "Ball ESP",
    Value = false,
    Callback = function(s, v)
        if v then
            local c = p.Character or p.CharacterAdded:Wait()
            local r = c:WaitForChild("HumanoidRootPart")
            local cm = workspace.CurrentCamera
            local m = require(game:GetService("ReplicatedStorage").engine.modules.Balls)
            ec = game:GetService("RunService").RenderStepped:Connect(function()
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
            if ec then
                ec:Disconnect()
            end
            for b, bx in e do
                bx:Remove()
                e[b] = nil
            end
        end
    end
})

local ct = w:CreateTab({Name = "Credits"})
ct:Label({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
ct:Label({Text = ""})
ct:Label({Text = "RF24"})
ct:Label({Text = ""})
ct:Label({Text = "Developer: DownInDaNang"})
ct:Label({Text = "Platform: GitHub"})
ct:Label({Text = ""})
ct:Label({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
