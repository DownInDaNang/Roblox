--// updated bypass for this shit dead game

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer: Player = Players.LocalPlayer

local bacRemote: RemoteEvent? = nil
pcall(function()
	local sanity: Folder = ReplicatedStorage:FindFirstChild("RemoteEvents")
		and ReplicatedStorage.RemoteEvents:FindFirstChild("Sanity")
	if sanity then
		bacRemote = sanity:FindFirstChild("BAC")
	end
end)

local oldNamecall: (...any) -> ...any
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self: any, ...: any): ...any
	local method: string = getnamecallmethod()

	if method == "Kick" and self == LocalPlayer then
		return
	end

	if method == "FireServer" and bacRemote and self == bacRemote then
		return
	end

	if method == "FindService" then
		local args = { ... }
		local svc: string? = args[1]
		if svc == "VirtualInputManager" or svc == "VirtualUser" then
			return nil
		end
	end

	return oldNamecall(self, ...)
end))

local realKick: (Player, string?) -> () = LocalPlayer.Kick
hookfunction(realKick, newcclosure(function(...: any): ()
	return
end))

-- prevent string.rep crash (CrashPlayer specifically)
local realStringRep: (string, number) -> string = string.rep
hookfunction(string.rep, newcclosure(function(s: string, n: number): string
	if n > 1000000 then
		return s
	end
	return realStringRep(s, n)
end))

-- their 3 detection functions?
local detectionFuncs: { (...any) -> ...any } = filtergc("function", {
	Constants = { "BAC - Alpha-3B", "FrogWasHere" },
	IgnoreExecutor = true
})

-- store originals for env spoofing
local originalEnvs: { [(...any) -> ...any]: { [string]: any } } = {}
local originalInfos: { [(...any) -> ...any]: { short_src: string, source: string, currentline: number, name: string } } = {}

for _, fn: (...any) -> ...any in detectionFuncs do
	pcall(function()
		originalEnvs[fn] = getfenv(fn)
		originalInfos[fn] = debug.getinfo(fn)
	end)

	local old: (...any) -> ...any = hookfunction(fn, newcclosure(function(...: any): ()
		return
	end))

	pcall(function()
		debug.setinfo(fn, {
			source = "=ReplicatedFirst.Animate",
			short_src = "ReplicatedFirst.Animate",
			name = originalInfos[fn] and originalInfos[fn].name or ""
		})
	end)
end

local loopFuncs: { (...any) -> ...any } = filtergc("function", {
	Constants = { "Critical Function Hooked!", "CoreGui Overflow Detection!" },
	IgnoreExecutor = true
})

for _, loopFn: (...any) -> ...any in loopFuncs do
	local upvalues: { [number]: any } = debug.getupvalues(loopFn)
	for idx: number, val: any in upvalues do
		if type(val) == "function" and originalEnvs[val] then
			local safeNoop: () -> () = function(): () return end
			pcall(function()
				debug.setinfo(safeNoop, {
					source = "=ReplicatedFirst.Animate",
					short_src = "ReplicatedFirst.Animate"
				})
			end)
			-- match original environment
			pcall(function()
				setfenv(safeNoop, originalEnvs[val])
			end)
			debug.setupvalue(loopFn, idx, safeNoop)
		end

		-- replace Kick reference
		if type(val) == "function" then
			pcall(function()
				if val == realKick then
					debug.setupvalue(loopFn, idx, newcclosure(function(...: any): () return end))
				end
			end)
		end

		-- replace BAC remote reference with dummy
		if typeof(val) == "Instance" and val == bacRemote then
			local dummy: BindableEvent = Instance.new("BindableEvent")
			debug.setupvalue(loopFn, idx, dummy)
		end
	end
end

local logHandlers: { (...any) -> ...any } = filtergc("function", {
	Constants = { "Solora Detected!", "Remote Spy!", "Instance added to nil", "Emulator Detected!" },
	IgnoreExecutor = true
})

for _, handler: (...any) -> ...any in logHandlers do
	hookfunction(handler, newcclosure(function(...: any): ()
		return
	end))
end

local bodyCheckers: { (...any) -> ...any } = filtergc("function", {
	Constants = { "Possible Script Injection!", "RBXConnection Stopped" },
	IgnoreExecutor = true
})

for _, checker: (...any) -> ...any in bodyCheckers do
	hookfunction(checker, newcclosure(function(...: any): ()
		return
	end))
end


local realDebugInfo: (...any) -> ...any = clonefunction(debug.info)
local namecallRef: (...any) -> ...any = getrawmetatable(game).__namecall

hookfunction(debug.info, newcclosure(function(fnOrLevel: any, ...: any): ...any
	-- if AC is checking the namecall function it captured, spoof the error behavior
	if type(fnOrLevel) == "function" and fnOrLevel == namecallRef then
		return realDebugInfo(fnOrLevel, ...)
	end
	return realDebugInfo(fnOrLevel, ...)
end))

-- prevent VirtualInputManager / VirtualUser from being findable
local oldFindService: (Instance, string) -> Instance? = game.FindService
hookfunction(game.FindService, newcclosure(function(self: any, serviceName: string): Instance?
	if serviceName == "VirtualInputManager" or serviceName == "VirtualUser" then
		return nil
	end
	return oldFindService(self, serviceName)
end))


local charDataTables: { any } = filtergc("table", {
	Keys = { "LastCFrame", "RealSpeed", "Moving", "Character", "Humanoid" }
})


local oldNewindex: (...any) -> ...any
oldNewindex = hookmetamethod(game, "__newindex", newcclosure(function(self: any, prop: string, val: any): ...any
	if typeof(self) == "Instance" and self:IsA("Humanoid") and prop == "WalkSpeed" then
		if checkcaller() then
			return oldNewindex(self, prop, val)
		end
	end
	return oldNewindex(self, prop, val)
end))
