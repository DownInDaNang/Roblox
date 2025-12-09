-- @DownInDaNang

for i, v in getgc() do
    if typeof(v) == "function" and islclosure(v) then
        local c = debug.getconstants(v)
        if table.find(c, "Asset Editing") or table.find(c, 23) and table.find(c, 50) and table.find(c, 65) then
            for x = 1, #c do
                if c[x] == 23 then
                    debug.setconstant(v, x, 9e9)
                elseif c[x] == 50 then
                    debug.setconstant(v, x, 9e9)
                elseif c[x] == 65 then
                    debug.setconstant(v, x, 9e9)
                end
            end
        end
    end
end

local r = game:GetService("Workspace").FE.Actions:WaitForChild("KeepYourHeadUp")
local o
o = hookmetamethod(game, "__namecall", function(s, ...)
    if s == r and getnamecallmethod() == "FireServer" and not checkcaller() then
        return
    end
    return o(s, ...)
end)
