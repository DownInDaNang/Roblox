local Func = filtergc("function", {Name = "CheckSword"}, true)
if Func then
    local Net = debug.getupvalue(Func, 5)
    Net.FireServer("REWARD_IRON")
end
