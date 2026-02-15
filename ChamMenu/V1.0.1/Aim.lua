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
local fovCircle = nil
local fovCircleGui = nil

local function createFOVCircle()
    -- Clean up existing circle
    if fovCircle then
        pcall(function()
            fovCircle:Destroy()
        end)
        fovCircle = nil
    end
    
    if fovCircleGui then
        pcall(function()
            fovCircleGui:Destroy()
        end)
        fovCircleGui = nil
    end
    
    if not Aimbot.FOV.Enabled then return end
    
    -- Create ScreenGui
    fovCircleGui = Instance.new("ScreenGui")
    fovCircleGui.Name = "FOVCircle"
    fovCircleGui.ResetOnSpawn = false
    fovCircleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Handle protected GUI environments
    local success, result = pcall(function()
        if gethui then
            fovCircleGui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(fovCircleGui)
            fovCircleGui.Parent = game.CoreGui
        else
            fovCircleGui.Parent = game:GetService("CoreGui")
        end
    end)
    
    if not success or not fovCircleGui.Parent then
        fovCircleGui.Parent = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui") or Instance.new("ScreenGui")
    end
    
    -- Create the circle frame
    fovCircle = Instance.new("Frame")
    fovCircle.Name = "Circle"
    fovCircle.Size = UDim2.new(0, Aimbot.FOV.Radius * 2, 0, Aimbot.FOV.Radius * 2)
    fovCircle.Position = UDim2.new(0.5, -Aimbot.FOV.Radius, 0.5, -Aimbot.FOV.Radius)
    fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 0
    fovCircle.Parent = fovCircleGui
    
    -- Add corner for circular shape
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fovCircle
    
    -- Add stroke for outline
    local stroke = Instance.new("UIStroke")
    stroke.Color = Aimbot.FOV.Color
    stroke.Thickness = 2
    stroke.Transparency = Aimbot.FOV.Visible and 0 or 1
    stroke.Parent = fovCircle
    
    -- Add a transparent inner frame for better visibility
    local innerFrame = Instance.new("Frame")
    innerFrame.Size = UDim2.new(1, -4, 1, -4)
    innerFrame.Position = UDim2.new(0, 2, 0, 2)
    innerFrame.BackgroundColor3 = Aimbot.FOV.Color
    innerFrame.BackgroundTransparency = 0.9
    innerFrame.BorderSizePixel = 0
    innerFrame.Parent = fovCircle
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(1, 0)
    innerCorner.Parent = innerFrame
    
    fovCircle.Visible = Aimbot.FOV.Enabled and Aimbot.FOV.Visible
end

local function updateFOVCircle()
    if not fovCircle then
        if Aimbot.FOV.Enabled then
            createFOVCircle()
        else
            return
        end
    end
    
    if not fovCircle or not fovCircleGui then return end
    
    if Aimbot.FOV.Enabled then
        -- Update size
        fovCircle.Size = UDim2.new(0, Aimbot.FOV.Radius * 2, 0, Aimbot.FOV.Radius * 2)
        fovCircle.Position = UDim2.new(0.5, -Aimbot.FOV.Radius, 0.5, -Aimbot.FOV.Radius)
        
        -- Update stroke
        local stroke = fovCircle:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = Aimbot.FOV.Color
            stroke.Transparency = Aimbot.FOV.Visible and 0 or 1
        end
        
        -- Update inner frame
        local innerFrame = fovCircle:FindFirstChild("Frame")
        if innerFrame then
            innerFrame.BackgroundColor3 = Aimbot.FOV.Color
            innerFrame.BackgroundTransparency = Aimbot.FOV.Visible and 0.9 or 1
        end
        
        fovCircle.Visible = true
        fovCircleGui.Enabled = true
    else
        if fovCircle then
            fovCircle.Visible = false
        end
        if fovCircleGui then
            fovCircleGui.Enabled = false
        end
    end
end

local function IsPlayerValid(player)
    if not player then return false end
    if not player.Character then return false end
    if player == LocalPlayer then return false end
    
    -- Team check
    if Aimbot.TeamCheck and player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then return false end
    end
    
    -- Check if character exists and is alive
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
    raycastParams.FilterDescendantsInstances = {character, part.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    return raycastResult == nil
end

local function AimAt(targetPosition, smoothness)
    if not targetPosition then return end
    
    if Aimbot.AimMethod == "Camera" then
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
        local current = camera.CFrame
        local target = CFrame.lookAt(camera.CFrame.Position, targetPosition)
        
        camera.CFrame = current:Lerp(target, smoothness)
        
    elseif Aimbot.AimMethod == "Mouse" then
        local screenPoint = Camera:WorldToScreenPoint(targetPosition)
        
        local currentPos = UserInputService:GetMouseLocation()
        local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
        
        local delta = targetPos - currentPos
        local smoothedDelta = delta * smoothness
        
        -- Use mousemoverel if available, otherwise use alternative method
        local success, result = pcall(function()
            mousemoverel(smoothedDelta.X, smoothedDelta.Y)
        end)
        
        if not success then
            -- Alternative method if mousemoverel is not available
            local mouse = LocalPlayer:GetMouse()
            if mouse then
                mouse.X = mouse.X + smoothedDelta.X
                mouse.Y = mouse.Y + smoothedDelta.Y
            end
        end
    end
end

local function AimbotLoop()
    if not Aimbot.Enabled then return end
    
    -- Update FOV circle position
    if Aimbot.FOV.Enabled and fovCircleGui then
        fovCircleGui.Enabled = Aimbot.FOV.Visible
    end
    
    local isAimKeyPressed = false
    
    -- Check if aim key is pressed
    if Aimbot.AimKey then
        if Aimbot.AimKey.EnumType == Enum.UserInputType then
            isAimKeyPressed = UserInputService:IsMouseButtonPressed(Aimbot.AimKey)
        elseif Aimbot.AimKey.EnumType == Enum.KeyCode then
            isAimKeyPressed = UserInputService:IsKeyDown(Aimbot.AimKey)
        end
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

local function EnableAimbot(aimPart, smoothness, aimKey, aimMethod)
    Aimbot.Enabled = true
    Aimbot.AimPart = aimPart or "Head"
    Aimbot.Smoothness = smoothness or 0.1
    Aimbot.AimMethod = aimMethod or "Camera"
    
    -- Handle aim key
    if aimKey then
        if typeof(aimKey) == "EnumItem" then
            Aimbot.AimKey = aimKey
        elseif typeof(aimKey) == "string" then
            -- Try to parse as KeyCode first
            local keyCode = Enum.KeyCode[aimKey]
            if keyCode then
                Aimbot.AimKey = keyCode
            else
                -- Try to parse as UserInputType
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
    
    -- Create FOV circle if enabled
    if Aimbot.FOV.Enabled then
        createFOVCircle()
    end
end

local function DisableAimbot()
    Aimbot.Enabled = false
    if AimConnection then
        AimConnection:Disconnect()
        AimConnection = nil
    end
    LastTarget = nil
    
    -- Hide FOV circle
    if fovCircleGui then
        fovCircleGui.Enabled = false
    end
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
    
    -- Recreate or update FOV circle
    if Aimbot.FOV.Enabled then
        if not fovCircle then
            createFOVCircle()
        else
            updateFOVCircle()
        end
    elseif fovCircleGui then
        fovCircleGui.Enabled = false
    end
end

local function GetFOVSettings()
    return Aimbot.FOV
end

local function ToggleFOV()
    Aimbot.FOV.Enabled = not Aimbot.FOV.Enabled
    if Aimbot.FOV.Enabled then
        if not fovCircle then
            createFOVCircle()
        else
            updateFOVCircle()
        end
    elseif fovCircleGui then
        fovCircleGui.Enabled = false
    end
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

-- Cleanup function
local function Cleanup()
    if fovCircleGui then
        fovCircleGui:Destroy()
        fovCircleGui = nil
    end
    if AimConnection then
        AimConnection:Disconnect()
        AimConnection = nil
    end
end

-- Handle character respawn
LocalPlayer.CharacterAdded:Connect(function()
    -- Recreate FOV circle if needed
    if Aimbot.FOV.Enabled and Aimbot.FOV.Visible then
        task.wait(1) -- Wait for character to load
        createFOVCircle()
    end
end)

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
    updateFOVCircle = updateFOVCircle,
    Cleanup = Cleanup
}
