-- Enhanced Aimbot with full configuration support
local Aimbot = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Default settings (will be overridden by menu)
Aimbot.Settings = {
    Enabled = false,
    FOV = 200,
    AimPart = "Head",           -- "Head", "HumanoidRootPart", "Torso", etc.
    VisibleCheck = false,       -- Only aim if part is visible
    WallCheck = false,          -- Check if wall between target and local player
    TeamCheck = true,           -- Don't aim at teammates
    Smoothing = 0,              -- 0 = instant, higher = smoother (in degrees/frame)
    Prediction = 0,             -- Predict movement (0-1, 1 = full velocity)
    Triggerbot = false,         -- Auto-shoot when target in FOV
    TriggerKey = Enum.KeyCode.E, -- Key to hold for triggerbot
    AimKey = Enum.UserInputType.MouseButton2, -- Key to hold for aimbot
    FOVCircle = {
        Visible = true,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5,
        Thickness = 2,
        Filled = false
    },
    TargetLine = {
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1
    }
}

Aimbot.currentTarget = nil
Aimbot.targetPart = nil
Aimbot.FOVCircle = Drawing.new("Circle")
Aimbot.TargetLine = Drawing.new("Line")

function Aimbot:init()
    -- Initialize drawing objects
    self.FOVCircle.Visible = self.Settings.FOVCircle.Visible
    self.FOVCircle.Radius = self.Settings.FOV
    self.FOVCircle.Color = self.Settings.FOVCircle.Color
    self.FOVCircle.Transparency = self.Settings.FOVCircle.Transparency
    self.FOVCircle.Thickness = self.Settings.FOVCircle.Thickness
    self.FOVCircle.NumSides = 60
    self.FOVCircle.Filled = self.Settings.FOVCircle.Filled

    self.TargetLine.Visible = self.Settings.TargetLine.Visible
    self.TargetLine.Color = self.Settings.TargetLine.Color
    self.TargetLine.Thickness = self.Settings.TargetLine.Thickness
end

function Aimbot:isEnemy(player)
    if not player or player == LocalPlayer then return false end
    if not self.Settings.TeamCheck then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

function Aimbot:getTargetPart(character)
    if not character then return nil end
    local part = character:FindFirstChild(self.Settings.AimPart)
    if not part and self.Settings.AimPart == "Head" then
        part = character:FindFirstChild("Head")
    end
    if not part and self.Settings.AimPart == "HumanoidRootPart" then
        part = character:FindFirstChild("HumanoidRootPart")
    end
    if not part then
        -- Fallback to any body part
        part = character:FindFirstChildWhichIsA("BasePart")
    end
    return part
end

function Aimbot:isVisible(part)
    if not part or not self.Settings.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local ray = Ray.new(origin, direction * (part.Position - origin).Magnitude)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == part
end

function Aimbot:canWallbang(part)
    if not part or not self.Settings.WallCheck then return true end
    -- Simple wall check: check if line of sight is blocked by something not the target
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local ray = Ray.new(origin, direction * (part.Position - origin).Magnitude)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return hit == part or hit == nil
end

function Aimbot:getPredictedPosition(part)
    if not part or self.Settings.Prediction <= 0 then return part.Position end
    local humanoid = part.Parent:FindFirstChild("Humanoid")
    if not humanoid then return part.Position end
    local velocity = humanoid.MoveDirection * humanoid.WalkSpeed
    return part.Position + velocity * self.Settings.Prediction
end

function Aimbot:getTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local center = Vector2.new(mousePos.X, mousePos.Y)
    local bestTarget = nil
    local bestPart = nil
    local bestDist = self.Settings.FOV
    local bestScreenPos = nil

    for _, player in pairs(Players:GetPlayers()) do
        if self:isEnemy(player) and player.Character then
            local targetPart = self:getTargetPart(player.Character)
            local humanoid = player.Character:FindFirstChild("Humanoid")

            if targetPart and humanoid and humanoid.Health > 0 then
                -- Check visibility/wall if enabled
                if not self:isVisible(targetPart) then continue end
                if not self:canWallbang(targetPart) then continue end

                local predictedPos = self:getPredictedPosition(targetPart)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)

                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= bestDist then
                        bestDist = dist
                        bestTarget = player
                        bestPart = targetPart
                        bestScreenPos = screenPos
                    end
                end
            end
        end
    end

    return bestTarget, bestPart, bestScreenPos
end

function Aimbot:smoothAim(current, target)
    if self.Settings.Smoothing <= 0 then return target end
    -- Simple smoothing by interpolating angles
    local diff = target - current
    local angle = math.acos(math.clamp(current:Dot(target), -1, 1))
    local maxAngle = math.rad(self.Settings.Smoothing)
    if angle <= maxAngle then return target end
    return current:Lerp(target, maxAngle / angle)
end

function Aimbot:update()
    -- Update FOV circle position
    local mousePos = UserInputService:GetMouseLocation()
    self.FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    self.FOVCircle.Radius = self.Settings.FOV
    self.FOVCircle.Visible = self.Settings.Enabled and self.Settings.FOVCircle.Visible

    -- Update target line
    self.TargetLine.Visible = self.Settings.Enabled and self.Settings.TargetLine.Visible and self.currentTarget

    if self.Settings.Enabled then
        local aiming = UserInputService:IsMouseButtonPressed(self.Settings.AimKey)
        local trigger = self.Settings.Triggerbot and UserInputService:IsKeyDown(self.Settings.TriggerKey)

        if aiming or trigger then
            local target, part, screenPos = self:getTarget()
            self.currentTarget = target
            self.targetPart = part

            if target and part then
                -- Update target line
                if self.TargetLine.Visible then
                    self.TargetLine.From = Vector2.new(mousePos.X, mousePos.Y)
                    self.TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                end

                -- Aim assist
                if aiming then
                    local predictedPos = self:getPredictedPosition(part)
                    local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                    local smoothedCF = self:smoothAim(Camera.CFrame, targetCF)
                    Camera.CFrame = smoothedCF
                end

                -- Triggerbot
                if trigger then
                    -- Simulate mouse click (may not work in all games)
                    mouse1click()
                end

                self.FOVCircle.Color = Color3.fromRGB(0, 255, 0)
            else
                self.FOVCircle.Color = self.Settings.FOVCircle.Color
            end
        else
            self.currentTarget = nil
            self.targetPart = nil
            self.FOVCircle.Color = self.Settings.FOVCircle.Color
        end
    else
        self.currentTarget = nil
        self.targetPart = nil
    end
end

function Aimbot:setFOV(value)
    self.Settings.FOV = math.max(50, math.min(500, value))
end

function Aimbot:applySettings(newSettings)
    for k, v in pairs(newSettings) do
        if type(v) == "table" and self.Settings[k] and type(self.Settings[k]) == "table" then
            for subk, subv in pairs(v) do
                pcall(function() self.Settings[k][subk] = subv end)
            end
        else
            pcall(function() self.Settings[k] = v end)
        end
    end
    -- Update drawing objects
    pcall(function() self.FOVCircle.Color = self.Settings.FOVCircle.Color end)
    pcall(function() self.FOVCircle.Transparency = self.Settings.FOVCircle.Transparency end)
    pcall(function() self.FOVCircle.Thickness = self.Settings.FOVCircle.Thickness end)
    pcall(function() self.FOVCircle.Filled = self.Settings.FOVCircle.Filled end)
    pcall(function() self.TargetLine.Color = self.Settings.TargetLine.Color end)
    pcall(function() self.TargetLine.Thickness = self.Settings.TargetLine.Thickness end)
end

function Aimbot:cleanup()
    if self.FOVCircle then
        pcall(function() self.FOVCircle:Remove() end)
    end
    if self.TargetLine then
        pcall(function() self.TargetLine:Remove() end)
    end
end

return Aimbot
