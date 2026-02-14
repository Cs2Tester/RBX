local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Aimbot = {
    Enabled = false,
    AimPart = "Head",
    Smoothness = 0.1,
    AimKey = Enum.UserInputType.MouseButton2,
    AimMethod = "Camera",
    TeamCheck = true,
    VisibleCheck = true,
    
    -- FOV Settings
    FOV = {
        Enabled = true,
        Radius = 100,
        Color = Color3.fromRGB(255, 255, 255),
        Visible = true
    }
}

local AimConnection
local LastTarget = nil
local fovCircle

local function createFOVCircle()
    if fovCircle then fovCircle:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVCircle"
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game.CoreGui
    else
        screenGui.Parent = game.CoreGui
    end
    
    fovCircle = Instance.new("Frame")
    fovCircle.Name = "Circle"
    fovCircle.Size = UDim2.new(0, Aimbot.FOV.Radius * 2, 0, Aimbot.FOV.Radius * 2)
    fovCircle.Position = UDim2.new(0.5, -Aimbot.FOV.Radius, 0.5, -Aimbot.FOV.Radius)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Parent = screenGui
    
    local circle = Instance.new("UICorner")
    circle.CornerRadius = UDim.new(1, 0)
    circle.Parent = fovCircle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Aimbot.FOV.Color
    stroke.Thickness = 2
    stroke.Parent = fovCircle
    
    fovCircle.Visible = Aimbot.FOV.Visible and Aimbot.FOV.Enabled
    
    return screenGui
end

local function updateFOVCircle()
    if Aimbot.FOV.Enabled then
        if not fovCircle then
            createFOVCircle()
        else
            fovCircle.Size = UDim2.new(0, Aimbot.FOV.Radius * 2, 0, Aimbot.FOV.Radius * 2)
            fovCircle.Position = UDim2.new(0.5, -Aimbot.FOV.Radius, 0.5, -Aimbot.FOV.Radius)
            if fovCircle:FindFirstChildOfClass("UIStroke") then
                fovCircle:FindFirstChildOfClass("UIStroke").Color = Aimbot.FOV.Color
            end
            fovCircle.Visible = Aimbot.FOV.Visible
        end
    elseif fovCircle then
        fovCircle.Visible = false
    end
end

local function IsPlayerValid(player)
    if not player then return false end
    if not player.Character then return false end
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and Aimbot.TeamCheck and player.Team == LocalPlayer.Team then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    
    return true
end

local function GetClosestPlayerToMouse()
    local maxDistance = Aimbot.FOV.Radius
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsPlayerValid(player) then
            local character = player.Character
            local aimPart = character:FindFirstChild(Aimbot.AimPart)
            
            if aimPart then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    
                    if Aimbot.FOV.Enabled then
                        if distance <= maxDistance and distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    else
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function IsVisible(part)
    if not Aimbot.VisibleCheck then return true end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local origin = humanoidRootPart.Position
    local direction = (part.Position - origin).Unit * 1000
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        return hitPart:IsDescendantOf(part.Parent)
    end
    
    return false
end

local function AimAt(targetPosition, smoothness)
    if Aimbot.AimMethod == "Camera" then
        local camera = Workspace.CurrentCamera
        local current = camera.CFrame
        local target = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        
        camera.CFrame = current:Lerp(target, smoothness)
    elseif Aimbot.AimMethod == "Mouse" then
        local screenPoint = Camera:WorldToScreenPoint(targetPosition)
        
        local currentPos = UserInputService:GetMouseLocation()
        local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
        
        local delta = targetPos - currentPos
        local smoothedDelta = delta * smoothness
        
        mousemoverel(smoothedDelta.X, smoothedDelta.Y)
    end
end

local function AimbotLoop()
    if not Aimbot.Enabled then return end
    
    local isAimKeyPressed = false
    
    if Aimbot.AimKey.EnumType == Enum.UserInputType then
        isAimKeyPressed = UserInputService:IsMouseButtonPressed(Aimbot.AimKey)
    elseif Aimbot.AimKey.EnumType == Enum.KeyCode then
        isAimKeyPressed = UserInputService:IsKeyDown(Aimbot.AimKey)
    end
    
    if isAimKeyPressed then
        local targetPlayer = GetClosestPlayerToMouse()
        
        if targetPlayer and targetPlayer.Character then
            local aimPart = targetPlayer.Character:FindFirstChild(Aimbot.AimPart)
            
            if aimPart then
                if IsVisible(aimPart) then
                    AimAt(aimPart.Position, Aimbot.Smoothness)
                    LastTarget = targetPlayer
                end
            end
        else
            LastTarget = nil
        end
    else
        LastTarget = nil
    end
end

local function EnableAimbot(aimPart, smoothness, aimKey, aimMethod, useFOV, fovRadius)
    Aimbot.Enabled = true
    Aimbot.AimPart = aimPart or "Head"
    Aimbot.Smoothness = smoothness or 0.1
    Aimbot.AimMethod = aimMethod or "Camera"
    
    if aimKey then
        if typeof(aimKey) == "EnumItem" then
            Aimbot.AimKey = aimKey
        elseif typeof(aimKey) == "string" then
            local keyCode = Enum.KeyCode[aimKey]
            if keyCode then
                Aimbot.AimKey = keyCode
            else
                local userInputType = Enum.UserInputType[aimKey]
                if userInputType then
                    Aimbot.AimKey = userInputType
                else
                    Aimbot.AimKey = Enum.UserInputType.MouseButton2
                    warn("Could not parse key:", aimKey, "- Defaulting to MouseButton2")
                end
            end
        else
            Aimbot.AimKey = Enum.UserInputType.MouseButton2
            warn("Invalid aim key type:", typeof(aimKey), "- Defaulting to MouseButton2")
        end
    else
        Aimbot.AimKey = Enum.UserInputType.MouseButton2
    end
    
    if AimConnection then
        AimConnection:Disconnect()
    end
    
    AimConnection = RunService.RenderStepped:Connect(AimbotLoop)
end

local function DisableAimbot()
    Aimbot.Enabled = false
    if AimConnection then
        AimConnection:Disconnect()
        AimConnection = nil
    end
    LastTarget = nil
end

local function UpdateAimPart(aimPart)
    Aimbot.AimPart = aimPart
end

local function UpdateSmoothness(smoothness)
    Aimbot.Smoothness = smoothness
end

local function UpdateAimKey(aimKey)
    if typeof(aimKey) == "EnumItem" then
        Aimbot.AimKey = aimKey
    elseif typeof(aimKey) == "string" then
        local keyCode = Enum.KeyCode[aimKey]
        if keyCode then
            Aimbot.AimKey = keyCode
        else
            local userInputType = Enum.UserInputType[aimKey]
            if userInputType then
                Aimbot.AimKey = userInputType
            else
                warn("Invalid aim key string:", aimKey)
            end
        end
    else
        warn("Invalid aim key type:", typeof(aimKey))
    end
end

local function UpdateAimMethod(aimMethod)
    Aimbot.AimMethod = aimMethod
end

-- FOV Functions
local function UpdateFOVSettings(fovSettings)
    if fovSettings.Enabled ~= nil then Aimbot.FOV.Enabled = fovSettings.Enabled end
    if fovSettings.Radius ~= nil then Aimbot.FOV.Radius = fovSettings.Radius end
    if fovSettings.Color ~= nil then Aimbot.FOV.Color = fovSettings.Color end
    if fovSettings.Visible ~= nil then Aimbot.FOV.Visible = fovSettings.Visible end
    updateFOVCircle()
end

local function GetFOVSettings()
    return Aimbot.FOV
end

local function ToggleFOV()
    Aimbot.FOV.Enabled = not Aimbot.FOV.Enabled
    updateFOVCircle()
    return Aimbot.FOV.Enabled
end

local function SetFOVRadius(radius)
    Aimbot.FOV.Radius = radius
    updateFOVCircle()
end

local function SetFOVColor(color)
    Aimbot.FOV.Color = color
    updateFOVCircle()
end

local function ToggleTeamCheck()
    Aimbot.TeamCheck = not Aimbot.TeamCheck
    return Aimbot.TeamCheck
end

local function ToggleVisibleCheck()
    Aimbot.VisibleCheck = not Aimbot.VisibleCheck
    return Aimbot.VisibleCheck
end

local function GetCurrentTarget()
    return LastTarget
end

local function IsAimbotEnabled()
    return Aimbot.Enabled
end

local function GetAimbotSettings()
    return {
        AimPart = Aimbot.AimPart,
        Smoothness = Aimbot.Smoothness,
        AimKey = Aimbot.AimKey,
        AimMethod = Aimbot.AimMethod,
        TeamCheck = Aimbot.TeamCheck,
        VisibleCheck = Aimbot.VisibleCheck,
        FOV = Aimbot.FOV
    }
end

return {
    EnableAimbot = EnableAimbot,
    DisableAimbot = DisableAimbot,
    UpdateAimPart = UpdateAimPart,
    UpdateSmoothness = UpdateSmoothness,
    UpdateAimKey = UpdateAimKey,
    UpdateAimMethod = UpdateAimMethod,
    UpdateFOVSettings = UpdateFOVSettings,
    GetFOVSettings = GetFOVSettings,
    ToggleFOV = ToggleFOV,
    SetFOVRadius = SetFOVRadius,
    SetFOVColor = SetFOVColor,
    ToggleTeamCheck = ToggleTeamCheck,
    ToggleVisibleCheck = ToggleVisibleCheck,
    GetCurrentTarget = GetCurrentTarget,
    IsAimbotEnabled = IsAimbotEnabled,
    GetAimbotSettings = GetAimbotSettings,
    updateFOVCircle = updateFOVCircle
}
