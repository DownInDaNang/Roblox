-- @DownInDaNang

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local GetCupLocationFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("GetCupLocationFunction")

local currentCupPosition = nil

local function updateCupPosition()
    local holeNumber = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Hole").Value

    local holeId = string.format("%03d", holeNumber)
    local course = workspace:FindFirstChild("9HoleCourse")

    local cupPosition = GetCupLocationFunction:InvokeServer(holeId, course and course.Name or nil)

    if typeof(cupPosition) == "Vector3" then
        currentCupPosition = cupPosition
    end
end

LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Hole").Changed:Connect(updateCupPosition)

task.spawn(updateCupPosition)

local oldNewIndex
oldNewIndex =
    hookmetamethod(
    game,
    "__newindex",
    function(obj, prop, value)
        if
            not checkcaller() and (prop == "AssemblyLinearVelocity" or prop == "Velocity") and obj:IsA("BasePart") and
                obj.Name:find("Ball")
         then
            if currentCupPosition then
                local delta = currentCupPosition - obj.Position
                local horizontalDistance = Vector3.new(delta.X, 0, delta.Z).Magnitude

                if horizontalDistance > 0.5 then
                    local scale = math.clamp(horizontalDistance / 30, 0.4, 1.2)

                    local gravity = 35.037

                    local newVelocity =
                        Vector3.new(delta.X / scale, (delta.Y + 0.5 * gravity * scale ^ 2) / scale, delta.Z / scale)

                    return oldNewIndex(obj, prop, newVelocity)
                end
            end
        end

        return oldNewIndex(obj, prop, value)
    end
)
