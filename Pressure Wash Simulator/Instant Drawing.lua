local Gun = require(game:GetService("ReplicatedFirst"):WaitForChild("Classes"):WaitForChild("GunBehaviour"))

Gun.DrawCircle = function(self, _, _, _, _, _, part, surface, pixelSize)
    local surfaceSize = part.AbsoluteSizeCache[surface]
    local maxX = math.round(surfaceSize.X / pixelSize.X) - 1
    local maxY = math.round(surfaceSize.Y / pixelSize.Y) - 1
    
    for y = 0, maxY do
        for x = 0, maxX do
            self:CreateStroke(x, y, part, surface)
        end
    end
end

Gun.DrawRotatedRectangle = function(self, _, _, _, _, _, part, surface, pixelSize)
    local surfaceSize = part.AbsoluteSizeCache[surface]
    local maxX = math.round(surfaceSize.X / pixelSize.X) - 1
    local maxY = math.round(surfaceSize.Y / pixelSize.Y) - 1
    
    for y = 0, maxY do
        for x = 0, maxX do
            self:CreateStroke(x, y, part, surface)
        end
    end
end
