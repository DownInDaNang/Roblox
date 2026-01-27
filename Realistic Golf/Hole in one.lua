-- // Credit : DownInDaNang

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local GetCupLocation = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("GetCupLocationFunction")
local TargetCupPos: Vector3? = nil

-- function to grab the hole location so we know where to send it
local function UpdateHoleLocation(): ()
    local CurrentHole: number = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Hole").Value
    local HoleString: string = string.format("%03d", CurrentHole)
    local CourseModel: any = workspace:FindFirstChild("9HoleCourse")
    
    local CupPos: any, CupData: any = GetCupLocation:InvokeServer(HoleString, CourseModel and CourseModel.Name or nil)
    if typeof(CupPos) == "Vector3" then
        TargetCupPos = CupPos
    end
end

-- keep the target updated when we move to the next hole
LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Hole").Changed:Connect(UpdateHoleLocation)
task.spawn(UpdateHoleLocation)

local OldNewIndex: any
OldNewIndex = hookmetamethod(game, "__newindex", function(Self: any, Index: string, Value: any): any
    -- intercepting when the game tries to set the ball velocity
    if not checkcaller() and (Index == "AssemblyLinearVelocity" or Index == "Velocity") and Self:IsA("BasePart") and Self.Name:find("Ball") then
        if TargetCupPos then
            -- calculating the vector to the hole
            local DeltaPos: Vector3 = (TargetCupPos - Self.Position)
            local HorizontalDist: number = Vector3.new(DeltaPos.X, 0, DeltaPos.Z).Magnitude
            
            -- only manipulate if it's a real shot and not just a tiny tap
            if HorizontalDist > 0.5 then
                -- calculating that perfect projectile motion arc
                local TimeToTarget: number = math.clamp(HorizontalDist / 30, 0.4, 1.2)
                local Gravity: number = 35.037 -- grav
                
                local AimVelocity: Vector3 = Vector3.new(
                    DeltaPos.X / TimeToTarget,
                    (DeltaPos.Y + 0.5 * Gravity * TimeToTarget^2) / TimeToTarget,
                    DeltaPos.Z / TimeToTarget
                )
                
                -- overriding the velocity to make it bounce straight to the hole
                return OldNewIndex(Self, Index, AimVelocity)
            end
        end
    end
    -- let everything else pass through normally
    return OldNewIndex(Self, Index, Value)
end)
