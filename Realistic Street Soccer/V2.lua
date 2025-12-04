for _, v in getgc() do
    if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
        local c = getconstants(v)
        if table.find(c, "WalkSpeed") and table.find(c, "JumpPower") and table.find(c, "MaxHealth") and table.find(c, "Sit") and table.find(c, "PlatformStand") then
            for i = 1, #getconstants(v) do
                if getconstant(v, i) == "h" then
                    setconstant(v, i, "")
                end
            end
            setupvalue(v, 1, nil)
        end
    end
end
