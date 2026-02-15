local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local parentGui = game:GetService("CoreGui")
if not parentGui then
    parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local Menu = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ESPBtn = Instance.new("TextButton")
local TracerBtn = Instance.new("TextButton")
local AimBtn = Instance.new("TextButton")
local FOVLabel = Instance.new("TextLabel")
local FOVValue = Instance.new("TextLabel")
local FOVDown = Instance.new("TextButton")
local FOVUp = Instance.new("TextButton")
local StatusText = Instance.new("TextLabel")

Menu.Name = "PlutoRIVALS"
Menu.Parent = parentGui
Menu.Enabled = true
Menu.ResetOnSpawn = false
Menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = Menu
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
MainFrame.Size = UDim2.new(0, 300, 0, 240)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.Gotham
Title.Text = "PlutoRIVALS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local function createButton(name, posY, default)
    local btn = Instance.new("TextButton")
    btn.Name = name.."Btn"
    btn.Parent = MainFrame
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Font = Enum.Font.Gotham
    btn.Text = name..": "..(default and "ON" or "OFF")
    btn.TextColor3 = default and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    return btn
end

ESPBtn = createButton("ESP", 35, false)
TracerBtn = createButton("Tracers", 65, false)
AimBtn = createButton("Silent Aim", 95, false)

FOVLabel.Name = "FOVLabel"
FOVLabel.Parent = MainFrame
FOVLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FOVLabel.BorderSizePixel = 0
FOVLabel.Position = UDim2.new(0, 10, 0, 130)
FOVLabel.Size = UDim2.new(1, -20, 0, 20)
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.Text = "FOV: 200"
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.TextSize = 12

FOVDown.Name = "FOVDown"
FOVDown.Parent = MainFrame
FOVDown.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FOVDown.BorderSizePixel = 0
FOVDown.Position = UDim2.new(0, 10, 0, 155)
FOVDown.Size = UDim2.new(0, 40, 0, 25)
FOVDown.Font = Enum.Font.Gotham
FOVDown.Text = "-"
FOVDown.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVDown.TextSize = 16

FOVValue.Name = "FOVValue"
FOVValue.Parent = MainFrame
FOVValue.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVValue.BorderSizePixel = 0
FOVValue.Position = UDim2.new(0, 55, 0, 155)
FOVValue.Size = UDim2.new(0, 190, 0, 25)
FOVValue.Font = Enum.Font.Gotham
FOVValue.Text = "200"
FOVValue.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVValue.TextSize = 12

FOVUp.Name = "FOVUp"
FOVUp.Parent = MainFrame
FOVUp.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FOVUp.BorderSizePixel = 0
FOVUp.Position = UDim2.new(1, -50, 0, 155)
FOVUp.Size = UDim2.new(0, 40, 0, 25)
FOVUp.Font = Enum.Font.Gotham
FOVUp.Text = "+"
FOVUp.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVUp.TextSize = 16

StatusText.Name = "StatusText"
StatusText.Parent = MainFrame
StatusText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusText.BorderSizePixel = 0
StatusText.Position = UDim2.new(0, 10, 0, 190)
StatusText.Size = UDim2.new(1, -20, 0, 35)
StatusText.Font = Enum.Font.Gotham
StatusText.Text = "Hold RMB for silent aim"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextSize = 11
StatusText.TextWrapped = true

local Settings = {
    ESP = { Enabled = false },
    Tracers = { Enabled = false },
    SilentAim = { 
        Enabled = false,
        FOV = 200
    }
}

local scriptLoaded = true
local currentTarget = nil
local originalMaterials = {}
local originalColors = {}
local originalTransparencies = {}

local function makeBlankGray(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if not originalMaterials[part] then
                originalMaterials[part] = part.Material
                originalColors[part] = part.Color
                originalTransparencies[part] = part.Transparency
            end
            part.Color = Color3.fromRGB(163, 162, 165)
            if part.Name == "Head" then
                local face = part:FindFirstChild("face")
                if face then
                    face:Destroy()
                end
            end
        elseif part:IsA("Accessory") then
            part:Destroy()
        elseif part:IsA("Clothing") or part:IsA("ShirtGraphic") then
            part:Destroy()
        end
    end
end

local function makeRedPlastic(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            part.Color = Color3.fromRGB(255, 0, 0)
        end
    end
end

local function revertPlayer(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if originalMaterials[part] then
                part.Material = originalMaterials[part]
                part.Color = originalColors[part]
                part.Transparency = originalTransparencies[part]
            end
        end
    end
end

local function makeSkyPurple()
    Lighting.Ambient = Color3.fromRGB(150, 0, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 0, 255)
    Lighting.ColorShift_Top = Color3.fromRGB(200, 0, 255)
    Lighting.ColorShift_Bottom = Color3.fromRGB(80, 0, 150)
    Lighting.FogColor = Color3.fromRGB(100, 0, 200)
    Lighting.Brightness = 1
end

local function resetSky()
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    Lighting.FogColor = Color3.fromRGB(0, 0, 0)
    Lighting.Brightness = 1
end

local function updateAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.ESP.Enabled then
                makeBlankGray(player.Character)
                makeRedPlastic(player.Character)
            else
                revertPlayer(player.Character)
            end
        end
    end
end

local function isEnemy(player)
    if not player or player == LocalPlayer then return false end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function getTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local center = Vector2.new(mousePos.X, mousePos.Y)
    local bestTarget = nil
    local bestDist = Settings.SilentAim.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= bestDist then
                        bestDist = dist
                        bestTarget = player
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local Box_Color = Color3.fromRGB(255, 0, 0)
local Box_Thickness = 1.4
local Box_Transparency = 1

local Tracer_Color = Color3.fromRGB(255, 0, 0)
local Tracer_Thickness = 1.4
local Tracer_Transparency = 1

local Team_Check = true
local red = Color3.fromRGB(227, 52, 52)
local green = Color3.fromRGB(88, 217, 24)

local function NewLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(1, 1)
    line.Color = Box_Color
    line.Thickness = Box_Thickness
    line.Transparency = Box_Transparency
    return line
end

local ESPObjects = {}

local function createESPForPlayer(v)
    local lines = {
        line1 = NewLine(),
        line2 = NewLine(),
        line3 = NewLine(),
        line4 = NewLine(),
        line5 = NewLine(),
        line6 = NewLine(),
        line7 = NewLine(),
        line8 = NewLine(),
        line9 = NewLine(),
        line10 = NewLine(),
        line11 = NewLine(),
        line12 = NewLine(),
        Tracer = NewLine()
    }

    lines.Tracer.Color = Tracer_Color
    lines.Tracer.Thickness = Tracer_Thickness
    lines.Tracer.Transparency = Tracer_Transparency
    
    ESPObjects[v] = lines
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        createESPForPlayer(v)
    end
end

local function updateESP()
    for v, lines in pairs(ESPObjects) do
        if Settings.ESP.Enabled and v and v.Character and v.Character:FindFirstChild("Humanoid") and 
           v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and 
           v.Character.Humanoid.Health > 0 then
            
            local pos, vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if vis then
                local Scale = v.Character.Head.Size.Y/2
                local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

                local Top1 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                local Top2 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                local Top3 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                local Top4 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)

                local Bottom1 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                local Bottom2 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                local Bottom3 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                local Bottom4 = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

                lines.line1.From = Vector2.new(Top1.X, Top1.Y)
                lines.line1.To = Vector2.new(Top2.X, Top2.Y)
                lines.line2.From = Vector2.new(Top2.X, Top2.Y)
                lines.line2.To = Vector2.new(Top3.X, Top3.Y)
                lines.line3.From = Vector2.new(Top3.X, Top3.Y)
                lines.line3.To = Vector2.new(Top4.X, Top4.Y)
                lines.line4.From = Vector2.new(Top4.X, Top4.Y)
                lines.line4.To = Vector2.new(Top1.X, Top1.Y)
                lines.line5.From = Vector2.new(Bottom1.X, Bottom1.Y)
                lines.line5.To = Vector2.new(Bottom2.X, Bottom2.Y)
                lines.line6.From = Vector2.new(Bottom2.X, Bottom2.Y)
                lines.line6.To = Vector2.new(Bottom3.X, Bottom3.Y)
                lines.line7.From = Vector2.new(Bottom3.X, Bottom3.Y)
                lines.line7.To = Vector2.new(Bottom4.X, Bottom4.Y)
                lines.line8.From = Vector2.new(Bottom4.X, Bottom4.Y)
                lines.line8.To = Vector2.new(Bottom1.X, Bottom1.Y)
                lines.line9.From = Vector2.new(Bottom1.X, Bottom1.Y)
                lines.line9.To = Vector2.new(Top1.X, Top1.Y)
                lines.line10.From = Vector2.new(Bottom2.X, Bottom2.Y)
                lines.line10.To = Vector2.new(Top2.X, Top2.Y)
                lines.line11.From = Vector2.new(Bottom3.X, Bottom3.Y)
                lines.line11.To = Vector2.new(Top3.X, Top3.Y)
                lines.line12.From = Vector2.new(Bottom4.X, Bottom4.Y)
                lines.line12.To = Vector2.new(Top4.X, Top4.Y)

                if Settings.Tracers.Enabled then
                    local trace = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(0, -Size.Y, 0)).p)
                    lines.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    lines.Tracer.To = Vector2.new(trace.X, trace.Y)
                    lines.Tracer.Visible = true
                else
                    lines.Tracer.Visible = false
                end

                if Team_Check then
                    local targetColor = isEnemy(v) and red or green
                    if v == currentTarget then
                        targetColor = Color3.fromRGB(255, 255, 0)
                    end
                    for _, line in pairs(lines) do
                        if line ~= lines.Tracer then
                            line.Color = targetColor
                        end
                    end
                else
                    local boxColor = v == currentTarget and Color3.fromRGB(255, 255, 0) or Box_Color
                    for _, line in pairs(lines) do
                        if line ~= lines.Tracer then
                            line.Color = boxColor
                        end
                    end
                end

                for _, line in pairs(lines) do
                    if line ~= lines.Tracer then
                        line.Visible = true
                    end
                end
            else
                for _, line in pairs(lines) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
    end
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = Settings.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 0.5
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Filled = false

local aimConnection
local espConnection
local fovCircleConnection

aimConnection = RunService.Heartbeat:Connect(function()
    if not scriptLoaded or not Settings.SilentAim.Enabled then return end
    
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getTarget()
        currentTarget = target
        
        if target and target.Character and target.Character.Head then
            local head = target.Character.Head
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    else
        currentTarget = nil
    end
end)

espConnection = RunService.RenderStepped:Connect(function()
    if not scriptLoaded then return end
    updateESP()
end)

fovCircleConnection = RunService.RenderStepped:Connect(function()
    if not scriptLoaded then return end
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Radius = Settings.SilentAim.FOV
    FOVCircle.Visible = Settings.SilentAim.Enabled
    
    if currentTarget then
        FOVCircle.Color = Color3.fromRGB(0, 255, 0)
    else
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESPForPlayer(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Settings.ESP.Enabled then
                makeBlankGray(player.Character)
                makeRedPlastic(player.Character)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, line in pairs(ESPObjects[player]) do
            pcall(function() line:Remove() end)
        end
        ESPObjects[player] = nil
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Settings.ESP.Enabled then
                makeBlankGray(player.Character)
                makeRedPlastic(player.Character)
            end
        end)
    end
end

ESPBtn.MouseButton1Click:Connect(function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    ESPBtn.BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
    ESPBtn.TextColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    ESPBtn.Text = "ESP: "..(Settings.ESP.Enabled and "ON" or "OFF")
    
    if Settings.ESP.Enabled then
        makeSkyPurple()
        updateAllESP()
    else
        resetSky()
        updateAllESP()
    end
end)

TracerBtn.MouseButton1Click:Connect(function()
    Settings.Tracers.Enabled = not Settings.Tracers.Enabled
    TracerBtn.BackgroundColor3 = Settings.Tracers.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
    TracerBtn.TextColor3 = Settings.Tracers.Enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    TracerBtn.Text = "Tracers: "..(Settings.Tracers.Enabled and "ON" or "OFF")
end)

AimBtn.MouseButton1Click:Connect(function()
    Settings.SilentAim.Enabled = not Settings.SilentAim.Enabled
    AimBtn.BackgroundColor3 = Settings.SilentAim.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
    AimBtn.TextColor3 = Settings.SilentAim.Enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    AimBtn.Text = "Silent Aim: "..(Settings.SilentAim.Enabled and "ON" or "OFF")
end)

FOVDown.MouseButton1Click:Connect(function()
    Settings.SilentAim.FOV = math.max(50, Settings.SilentAim.FOV - 10)
    FOVValue.Text = tostring(Settings.SilentAim.FOV)
    FOVLabel.Text = "FOV: "..Settings.SilentAim.FOV
end)

FOVUp.MouseButton1Click:Connect(function()
    Settings.SilentAim.FOV = math.min(500, Settings.SilentAim.FOV + 10)
    FOVValue.Text = tostring(Settings.SilentAim.FOV)
    FOVLabel.Text = "FOV: "..Settings.SilentAim.FOV
end)

FOVValue.MouseButton1Click:Connect(function()
    Settings.SilentAim.FOV = 200
    FOVValue.Text = "200"
    FOVLabel.Text = "FOV: 200"
end)

Settings.ESP.Enabled = false
Settings.Tracers.Enabled = false
Settings.SilentAim.Enabled = false
