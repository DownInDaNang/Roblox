local Functions = filtergc("function", {
    Constants = {"Shovel Reach", "GetUpgradeValue"}
}, false)

for _, func in pairs(Functions) do
    local Upvalues = debug.getupvalues(func)
    for i, upval in pairs(Upvalues) do
        if typeof(upval) == "number" and upval > 20 and upval < 50 then
            debug.setupvalue(func, i, math.huge)
        end
    end
end
