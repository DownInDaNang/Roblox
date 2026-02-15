--// Credit : Tarheel943
--// put in autoexec (seliware not recommended, use potassium)

local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")
local LogService: LogService = game:GetService("LogService")
local ScriptContext: ScriptContext = game:GetService("ScriptContext")
local ContentProvider: ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService: HttpService = game:GetService("HttpService")
local LocalPlayer: Player = Players.LocalPlayer

--// SHA256 + HMAC reimplementation (matches the AC's own impl)
local function toHex(str: string): string
	return (str:gsub(".", function(c: string): string
		return string.format("%02x", string.byte(c))
	end))
end

local function toBytes(num: number, len: number?): string
	local result: string = ""
	local n: number = num
	for i = 1, len or 4 do
		local rem: number = n % 256
		result = string.char(rem) .. result
		n = math.floor(n / 256)
	end
	return result
end

local function fromBytes(str: string, pos: number?): number
	local start: number = pos or 1
	local val: number = 0
	for i = start, start + 3 do
		val = val * 256 + str:byte(i)
	end
	return val
end

local function padMessage(msg: string, len: number): string
	local bits: number = len * 8
	local padding: number = 64 - (len + 9) % 64
	return msg .. string.char(128) .. string.rep("\0", padding) .. toBytes(bits, 8)
end

local K: {number} = {
	1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,
	3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,
	3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,
	2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,
	666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,
	2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,
	430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,
	1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298
}

local function sha256(message: string): string
	local padded: string = padMessage(message, #message)
	local H: {number} = {
		1779033703,3144134277,1013904242,2773480762,
		1359893119,2600822924,528734635,1541459225
	}

	for chunkStart = 1, #padded, 64 do
		local chunk: string = padded:sub(chunkStart, chunkStart + 63)
		local W: {number} = {}

		for i = 1, 16 do
			W[i] = fromBytes(chunk, (i - 1) * 4 + 1)
		end
		for i = 17, 64 do
			local s0: number = bit32.bxor(bit32.rrotate(W[i-15],7), bit32.rrotate(W[i-15],18), bit32.rshift(W[i-15],3))
			local s1: number = bit32.bxor(bit32.rrotate(W[i-2],17), bit32.rrotate(W[i-2],19), bit32.rshift(W[i-2],10))
			W[i] = (W[i-16] + s0 + W[i-7] + s1) % 4294967296
		end

		local a,b,c,d,e,f,g,h = H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]

		for i = 1, 64 do
			local S1: number = bit32.bxor(bit32.rrotate(e,6), bit32.rrotate(e,11), bit32.rrotate(e,25))
			local ch: number = bit32.bxor(bit32.band(e,f), bit32.band(bit32.bnot(e),g))
			local temp1: number = (h + S1 + ch + K[i] + W[i]) % 4294967296
			local S0: number = bit32.bxor(bit32.rrotate(a,2), bit32.rrotate(a,13), bit32.rrotate(a,22))
			local maj: number = bit32.bxor(bit32.band(a,b), bit32.band(a,c), bit32.band(b,c))
			local temp2: number = (S0 + maj) % 4294967296

			h = g
			g = f
			f = e
			e = (d + temp1) % 4294967296
			d = c
			c = b
			b = a
			a = (temp1 + temp2) % 4294967296
		end

		H[1]=(H[1]+a)%4294967296; H[2]=(H[2]+b)%4294967296
		H[3]=(H[3]+c)%4294967296; H[4]=(H[4]+d)%4294967296
		H[5]=(H[5]+e)%4294967296; H[6]=(H[6]+f)%4294967296
		H[7]=(H[7]+g)%4294967296; H[8]=(H[8]+h)%4294967296
	end

	local result: string = ""
	for i = 1, 8 do
		result = result .. toBytes(H[i], 4)
	end
	return toHex(result)
end

local function hmacSha256(key: string, message: string): string
	local k: string = key
	if #k > 64 then
		k = sha256(k)
	end
	if #k < 64 then
		k = k .. string.rep("\0", 64 - #k)
	end

	local opad: {string} = {}
	local ipad: {string} = {}
	for i = 1, 64 do
		local byte: number = k:byte(i)
		opad[i] = string.char(bit32.bxor(byte, 92))
		ipad[i] = string.char(bit32.bxor(byte, 54))
	end

	local okey: string = table.concat(opad)
	local ikey: string = table.concat(ipad)
	return sha256(okey .. sha256(ikey .. message))
end

local function deriveKey(): string
	local jobRaw: string = game.JobId:gsub("%D", "")
	local jobNum: number = tonumber(jobRaw) or 1
	if jobNum == 0 then jobNum = 1 end
	local seed: number = LocalPlayer.UserId * LocalPlayer.AccountAge * 4 * jobNum
	local keyStr: string = tostring(seed)
	if #keyStr < 16 then
		keyStr = keyStr .. string.rep("0", 16 - #keyStr)
	else
		keyStr = keyStr:sub(1, 16)
	end
	return keyStr
end

local hmacKey: string = deriveKey()

local function nukeSignalConnections(signal: RBXScriptSignal): ()
	for _, conn in getconnections(signal) do
		if not conn.ForeignState then
			conn:Disable()
		end
	end
end

task.defer(function()
	nukeSignalConnections(LogService.MessageOut)
	nukeSignalConnections(ScriptContext.Error)
end)

local blockedAssets: {string} = {
	"rbxasset://Velocity", "rbxasset://RonixExploit", "rbxasset://custom_gloop",
	"rbxasset://awp", "rbxasset://SELIWARE", "rbxasset://argon",
	"rbxasset://infiniteyield", "rbxasset://newvape", "rbxasset://WaveAssets",
	"rbxasset://wurst", "rbxasset://risesix", "rbxasset://barlogo.png",
	"rbxasset://newvape/assets/new/blur.png",
	"rbxasset://pin.png", "rbxasset://close.png", "rbxasset://settings.png"
}

local oldPreload: (ContentProvider, any, ((string, Enum.AssetFetchStatus) -> ())?) -> () = nil
oldPreload = hookfunction(ContentProvider.Preload, function(self: any, ...: any): ...any
	local args: {any} = {...}
	local asset: any = args[1]
	if type(asset) == "string" then
		for _, blocked in blockedAssets do
			if asset == blocked then
				return
			end
		end
	end
	return oldPreload(self, ...)
end)


local oldNamecall: (any, ...any) -> ...any
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self: any, ...: any): ...any
	local method: string = getnamecallmethod()
	local args: {any} = {...}

	if method == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
		if #args >= 1 then
			local firstArg: any = args[1]
			if firstArg == "Kill" or firstArg == "Ban" or firstArg == "flightCheck" or firstArg == "Jump" or firstArg == "VRNavigation" then
				return
			end
		end
	end

	if method == "KicK" and typeof(self) == "Instance" and self:IsA("Player") then
		return
	end

	if method == "Kick" and typeof(self) == "Instance" and self:IsA("Player") then
		if checkcaller() then
			return oldNamecall(self, ...)
		end
		return
	end

	return oldNamecall(self, ...)
end))

task.spawn(function()
	local framework: Instance? = ReplicatedStorage:FindFirstChild("Framework")
	if not framework then
		framework = ReplicatedStorage:WaitForChild("Framework", 30)
	end
	if not framework then return end

	local keepAlive: RemoteEvent? = nil
	for _, child in framework:GetChildren() do
		if child:IsA("RemoteEvent") then
			keepAlive = child :: RemoteEvent
			break
		end
	end

	if not keepAlive then return end

	-- Disconnect AC's own OnClientEvent connections so it cant respond
	for _, conn in getconnections(keepAlive.OnClientEvent) do
		conn:Disable()
	end

	-- disconnect destroying listeners to prevent crasher
	for _, conn in getconnections(keepAlive.Destroying) do
		conn:Disable()
	end
	for _, conn in getconnections(framework.Destroying) do
		conn:Disable()
	end

	-- Re-register our own challenge handler
	keepAlive.OnClientEvent:Connect(function(action: string, nonce: string?)
		if action == "challenge" and nonce then
			keepAlive:FireServer("challenge", hmacSha256(hmacKey, nonce))
		end
	end)

	-- Send initial registration
	keepAlive:FireServer("RegisterAnticheat")
end)


local oldFire: (BindableEvent, ...any) -> ()
oldFire = hookfunction(Instance.new("BindableEvent").Fire, function(self: any, ...: any): ...any
	local args: {any} = {...}
	if #args == 1 and type(args[1]) == "table" then
		for k, _ in args[1] do
			if type(k) == "userdata" then
				return
			end
		end
	end
	return oldFire(self, ...)
end)

local protectedNames: {[string]: string} = {
	["Debris"] = "Debris",
	["HttpService"] = "HttpService",
	["TweenService"] = "TweenService",
	["Players"] = "Players",
	["TextChatService"] = "TextChatService"
}

local oldNewindex: (any, any, any) -> ()
oldNewindex = hookmetamethod(game, "__newindex", newcclosure(function(self: any, key: any, value: any): ...any
	if typeof(self) == "Instance" and key == "Name" then
		for original, correct in protectedNames do
			local ok: boolean, className: string? = pcall(function(): string
				return self.ClassName
			end)
			if ok and className then
				local ok2: boolean, svc: Instance? = pcall(function(): Instance
					return game:GetService(original)
				end)
				if ok2 and svc == self and value ~= correct then
					return
				end
			end
		end
	end
	return oldNewindex(self, key, value)
end))

local oldTableCreate: (number, any?) -> {any} = table.create
local oldBufferCreate: (number) -> buffer = buffer.create

hookfunction(table.create, function(size: number, ...: any): {any}
	-- AC tries to allocate 67108864 element tables to crash
	if size >= 67108864 then
		return {}
	end
	return oldTableCreate(size, ...)
end)

hookfunction(buffer.create, function(size: number): buffer
	-- AC tries to allocate 1GB buffers to crash
	if size >= 1073741824 then
		return oldBufferCreate(16)
	end
	return oldBufferCreate(size)
end)

task.spawn(function()
	local acEvent: Instance? = ReplicatedStorage:FindFirstChild("Is that the anticheat event??")
	if not acEvent then
		acEvent = ReplicatedStorage:WaitForChild("Is that the anticheat event??", 30)
	end
	if acEvent then
		for _, conn in getconnections(acEvent.Destroying) do
			conn:Disable()
		end
		for _, conn in getconnections((acEvent :: BindableEvent).Event) do
			conn:Disable()
		end
	end
end)

task.defer(function()
	if LocalPlayer:FindFirstChild("PlayerGui") then
		for _, conn in getconnections(LocalPlayer.PlayerGui.ChildAdded) do
			if not conn.ForeignState then
				conn:Disable()
			end
		end
	end
end)

task.defer(function()
	for _, conn in getconnections(game.ChildAdded) do
		if not conn.ForeignState then
			conn:Disable()
		end
	end
end)

task.defer(function()
	for _, conn in getconnections(ReplicatedStorage.ChildAdded) do
		if not conn.ForeignState then
			conn:Disable()
		end
	end
end)

task.defer(function()
	local CS: CollectionService = game:GetService("CollectionService")
	pcall(function()
		for _, conn in getconnections(CS:GetInstanceAddedSignal("AllowedBM")) do
			conn:Disable()
		end
	end)
end)


task.defer(function()
	for _, conn in getconnections(RunService.Heartbeat) do
		if not conn.ForeignState and conn.Function then
			local consts: {any} = debug.getconstants(conn.Function)
			for _, v in consts do
				if v == "flightCheck" then
					conn:Disable()
					break
				end
			end
		end
	end
end)


task.defer(function()
	local nc: Instance? = game:FindFirstChild("NetworkClient")
	if nc then
		for _, conn in getconnections(nc.ChildRemoved) do
			conn:Disable()
		end
	end
end)


task.defer(function()
	local funcs: {any} = filtergc("function", {
		Constants = {"ultra detected", "CoreGui", "RobloxGui"},
		IgnoreExecutor = true
	})
	for _, fn in funcs do
		hookfunction(fn, function(): nil
			return nil
		end)
	end
end)

task.defer(function()
	pcall(function()
		ReplicatedStorage:SetAttribute("InfiniteYield", false)
	end)
end)

--// 17) Neutralize the PLAYERS descendant added flight check

task.spawn(function()
	local playersFolder: Instance? = workspace:FindFirstChild("PLAYERS")
	if not playersFolder then
		playersFolder = workspace:WaitForChild("PLAYERS", 15)
	end
	if playersFolder then
		for _, conn in getconnections(playersFolder.DescendantAdded) do
			if not conn.ForeignState then
				conn:Disable()
			end
		end
	end
end)
