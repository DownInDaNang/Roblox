local Jump =
    filtergc("function", {Name = "onJumpRequest"}, true) or
    filtergc("function", {Constants = {"Landed", "Running", "Dead"}}, true)
if Jump then
    debug.setupvalue(Jump, 4, 0)
    debug.setupvalue(Jump, 5, 9e9)
end
