-- @DownInDaNang

local rs = game:GetService("ReplicatedStorage")
local input = require(rs:WaitForChild("RobotInput"))

local function JewsDidItAgain(cfg)
    local dmg = 9e9
    
    for key in pairs(cfg.attackDMG) do
        cfg.attackDMG[key] = dmg
    end
    
    for key in pairs(cfg.attackForwardDMG) do
        cfg.attackForwardDMG[key] = dmg
    end
    
    for key in pairs(cfg.attackRECDMG) do
        cfg.attackRECDMG[key] = dmg
    end
    
    for key in pairs(cfg.attackForwardRECDMG) do
        cfg.attackForwardRECDMG[key] = dmg
    end
end

local orig = input.GetConfigForBot

input.GetConfigForBot = function(bot)
    local cfg = orig(bot)
    JewsDidItAgain(cfg)
    return cfg
end
