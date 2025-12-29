local oldnew = Instance.new
getgenv().Instance = setmetatable({}, {
    __index = function(t, k)
        if k == "new" then
            return function(class, parent)
                local instance = oldnew(class, parent)
                
                if checkcaller() then
                    task.defer(function()
                        local output = "Instance created\n"
                        output = output .. "Class: " .. tostring(class) .. "\n"
                        output = output .. "Name: " .. instance.Name .. "\n"
                        output = output .. "Parent: " .. (instance.Parent and instance.Parent:GetFullName() or "nil") .. "\n"
                        output = output .. "Call Stack:\n" .. debug.traceback() .. "\n"
                        
                        print("Instance created")
                        print("Class:", tostring(class))
                        print("Name:", instance.Name)
                        print("Parent:", instance.Parent and instance.Parent:GetFullName() or "nil")
                        print("Call Stack:")
                        print(debug.traceback())
                        
                        setclipboard(output)
                    end)
                end
                
                return instance
            end
        end
        return Instance[k]
    end
})
