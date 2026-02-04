local _hidden = {
    checkcaller = checkcaller,
    setclipboard = setclipboard,
    getgenv = getgenv
}

local oldloadstring = loadstring

_hidden.getgenv().loadstring = function(source, chunkname)
    if _hidden.checkcaller() then
        local output = "loadstring called\n"
        output = output .. "Source length: " .. #source .. "\n"
        output = output .. "Chunkname: " .. tostring(chunkname or "nil") .. "\n"
        output = output .. "Source preview: " .. source:sub(1, 100) .. "...\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("loadstring called")
        print("Source length:", #source)
        print("Chunkname:", tostring(chunkname or "nil"))
        print("Source preview:", source:sub(1, 100) .. "...")
        print("Call Stack:")
        print(debug.traceback())
        
        _hidden.setclipboard(output)
    end
    return oldloadstring(source, chunkname)
end
