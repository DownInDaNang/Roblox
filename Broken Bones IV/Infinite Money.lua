--[[

	@DownInDaNang - should work after first death

]]

local functions = game.ReplicatedStorage:WaitForChild("Functions")

_G.breakslevel = 1000
_G.speedlevel = 1000
_G.jumplevel = 1000
_G.sprainslevel = 1000
_G.dislocationslevel = 1000
_G.flightlevel = 1000
_G.fuellevel = 1000

hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if method == "InvokeServer" and self.Parent == functions then
        local result = {self[method](self, ...)}
        
        if result[1] and type(result[1]) == "table" then
            result[1].breakslevel = _G.breakslevel
            result[1].speedlevel = _G.speedlevel
            result[1].jumplevel = _G.jumplevel
            result[1].sprainslevel = _G.sprainslevel
            result[1].dislocationslevel = _G.dislocationslevel
            result[1].flightlevel = _G.flightlevel
            result[1].fuellevel = _G.fuellevel
        end
        
        return unpack(result)
    end
    
    return self[method](self, ...)
end))

for _, connection in pairs(getconnections(functions.SendData.OnClientEvent)) do
    if connection.Function then
        local oldFunc = connection.Function
        connection:Disable()
        
        functions.SendData.OnClientEvent:Connect(function(data, ...)
            if data then
                data.breakslevel = _G.breakslevel
                data.speedlevel = _G.speedlevel
                data.jumplevel = _G.jumplevel
                data.sprainslevel = _G.sprainslevel
                data.dislocationslevel = _G.dislocationslevel
                data.flightlevel = _G.flightlevel
                data.fuellevel = _G.fuellevel
            end
            return oldFunc(data, ...)
        end)
    end
end
