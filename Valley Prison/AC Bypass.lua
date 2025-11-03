local RS = game:GetService("ReplicatedStorage")

local Service = filtergc("table", {
    Keys = {"GETACINFO"}
}, true)

if Service and Service.GETACINFO then
    Service.GETACINFO.OnClientInvoke = function()
        return true
    end
end

for _, v in getgc() do
    if type(v) == "function" and islclosure(v) then
        local consts = debug.getconstants(v)
        if table.find(consts, "PSTAND") or table.find(consts, "NOCLIP") or table.find(consts, "Luraph Script:") then
            for i, c in consts do
                if c == "PSTAND" or c == "BGYR" or c == "BVEL" or c == "NOCLIP" or c == "HBIN" or c == "ANIM" or c == "Luraph Script:" then
                    debug.setconstant(v, i, "")
                end
            end
        end
    end
end
