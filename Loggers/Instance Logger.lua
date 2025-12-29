local oldnew = Instance.new
Instance.new = function(class, parent)
    local instance = oldnew(class, parent)
    
    if checkcaller() then
        local output = "Instance created\n"
        output = output .. "Class: " .. tostring(class) .. "\n"
        output = output .. "Name: " .. instance.Name .. "\n"
        output = output .. "Parent: " .. (parent and parent:GetFullName() or "nil") .. "\n"
        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
        
        print("Instance created")
        print("Class:", tostring(class))
        print("Name:", instance.Name)
        print("Parent:", parent and parent:GetFullName() or "nil")
        print("Call Stack:")
        print(debug.traceback())
        
        setclipboard(output)
    end
    
    return instance
end
