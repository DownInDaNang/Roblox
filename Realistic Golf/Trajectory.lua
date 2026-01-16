local p: any = cloneref(game:GetService("Players"))
local r: any = cloneref(game:GetService("RunService"))
local l: any = p.LocalPlayer
local c: any = workspace.CurrentCamera

local function f(): any
	for i: number, v: any in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "calculateSingleCarryDistance") then
			return v
		end
	end
end

local m: any = f()
local t: {any} = {}

for i: number = 1, 200 do
	local n: any = Drawing.new("Line")
	n.Thickness = 1.5
	n.Color = Color3.new(0, 1, 0)
	n.Transparency = 0.5
	t[i] = n
end

local function s(v: number, s: number): number
	local b: number = v < 80000 and 0.24 or (v >= 150000 and 0.33 or 0.24 + 0.09 * ((v - 80000) / 70000))
	local m: number
	if s < 0.05 then
		m = s * 5
	elseif s < 0.25 then
		m = 0.25 + 3 * s - 2 * s * s
	else
		m = math.min(0.25 + 3 * s - 2 * s * s, 1.3)
	end
	return b * m
end

r.RenderStepped:Connect(function()
	if not m then m = f() end
	if not m then return end
	
	local g: any = m.getCurrentClubSettings()
	local h: any = l.Character
	if not g or not h then
		for i: number, v: any in ipairs(t) do v.Visible = false end
		return
	end

	local rtp: any = h:FindFirstChild("HumanoidRootPart")
	if not rtp then return end

	local bpos: Vector3 = l:GetAttribute("BallPosition") or rtp.Position
	local lvec: Vector3 = (rtp.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)).LookVector
	local loft: number = math.rad(g.loft)
	local pwr: number = g.maxPower * g.powerPct
	local hdir: Vector3 = Vector3.new(lvec.X, 0, lvec.Z).Unit
	local vel: Vector3 = (hdir * math.cos(loft) + Vector3.new(0, math.sin(loft), 0)).Unit * pwr
	local spn: number = (g.isPutter and 0 or 200) * g.spinFrac
	local sdir: Vector3 = -Vector3.new(0, 1, 0):Cross(hdir).Unit
	local svec: Vector3 = sdir * spn

	local cur: Vector3 = bpos
	local cvl: Vector3 = vel
	local pts: {Vector3} = {}
	local dt: number = 0.016666666666666666
	local grav: Vector3 = Vector3.new(0, -35.037, 0)

	for i: number = 1, 201 do
		pts[i] = cur
		local spd: number = cvl.Magnitude
		if spd < 0.1 then break end

		local re: number = 867.095 * spd
		local cd: number
		if re < 50000 then
			cd = 0.5
		elseif re < 100000 then
			local r2: number = (re - 50000) / 50000
			cd = 0.5 - 0.3 * (r2 * r2 * (3 - 2 * r2))
		elseif re < 200000 then
			cd = 0.2
		else
			cd = math.min((re - 200000) / 100000, 1) * 0.02 + 0.2
		end

		local srat: number = 0.07 * spn / spd
		local cl: number = s(re, srat)
		local area: number = 0.0153938
		local rho: number = 0.002377
		local mass: number = 0.00314496
		
		local df: Vector3 = -cvl.Unit * (0.5 * rho * area * cd * spd * spd)
		local lf: Vector3 = (svec:Cross(cvl).Magnitude > 1e-6 and svec:Cross(cvl).Unit or Vector3.new(0,0,0)) * (0.5 * rho * area * cl * spd * spd)
		local acc: Vector3 = grav + (df + lf) / mass
		
		cvl = cvl + acc * dt
		cur = cur + cvl * dt
		if cur.Y < bpos.Y - 50 then break end
	end

	for i: number = 1, #t do
		local p1: Vector3 = pts[i]
		local p2: Vector3 = pts[i+1]
		if p1 and p2 then
			local v1: Vector3, o1: boolean = c:WorldToViewportPoint(p1)
			local v2: Vector3, o2: boolean = c:WorldToViewportPoint(p2)
			if o1 and o2 then
				t[i].From = Vector2.new(v1.X, v1.Y)
				t[i].To = Vector2.new(v2.X, v2.Y)
				t[i].Visible = true
			else
				t[i].Visible = false
			end
		else
			t[i].Visible = false
		end
	end
end)

print("LOADED")
