local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/User-Name123115/Roblox-Things/refs/heads/main/ChamMenu/Functions.lua"))()
local AimFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/User-Name123115/Roblox-Things/refs/heads/main/ChamMenu/AimFunctions.lua"))()

local ESP = ESPModule.getESP()
local Materials = ESPModule.Materials
local FOV = ESPModule.getFOV()

local Aimbot = {
    Enabled = false,
    AimPart = "Head",
    Smoothness = 0.1,
    AimKey = Enum.UserInputType.MouseButton2,
    AimMethod = "Camera"
}

local AimParts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}

local gui = Instance.new("ScreenGui")
gui.Name = "PlutoChams"
if gethui then
    gui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(gui)
    gui.Parent = game.CoreGui
else
    gui.Parent = game.CoreGui
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 350)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
title.Text = "PlutoChams v2"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

local tabs = {"ESP", "Aimbot", "FOV"}
local currentTab = "ESP"

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -10, 0, 30)
tabFrame.Position = UDim2.new(0, 5, 0, 45)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabFrame

local tabButtons = {}
for _, tabName in pairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 70, 1, 0)
    tabButton.BackgroundColor3 = tabName == currentTab and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(45, 45, 50)
    tabButton.Text = tabName
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.TextSize = 13
    tabButton.Parent = tabFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        for _, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = (btn.Text == tabName) and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(45, 45, 50)
        end
        showTab(tabName)
    end)
    
    tabButtons[tabName] = tabButton
end

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -85)
contentFrame.Position = UDim2.new(0, 5, 0, 80)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local espScroll = Instance.new("ScrollingFrame")
espScroll.Size = UDim2.new(1, 0, 1, 0)
espScroll.BackgroundTransparency = 1
espScroll.ScrollBarThickness = 4
espScroll.Parent = contentFrame

local espLayout = Instance.new("UIListLayout")
espLayout.Padding = UDim.new(0, 5)
espLayout.Parent = espScroll

local aimbotScroll = Instance.new("ScrollingFrame")
aimbotScroll.Size = UDim2.new(1, 0, 1, 0)
aimbotScroll.BackgroundTransparency = 1
aimbotScroll.ScrollBarThickness = 4
aimbotScroll.Visible = false
aimbotScroll.Parent = contentFrame

local aimbotLayout = Instance.new("UIListLayout")
aimbotLayout.Padding = UDim.new(0, 5)
aimbotLayout.Parent = aimbotScroll

local fovScroll = Instance.new("ScrollingFrame")
fovScroll.Size = UDim2.new(1, 0, 1, 0)
fovScroll.BackgroundTransparency = 1
fovScroll.ScrollBarThickness = 4
fovScroll.Visible = false
fovScroll.Parent = contentFrame

local fovLayout = Instance.new("UIListLayout")
fovLayout.Padding = UDim.new(0, 5)
fovLayout.Parent = fovScroll

local function createToggle(parent, text, value, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 25)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 25)
    button.Position = UDim2.new(1, -50, 0, 0)
    button.BackgroundColor3 = value and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    button.Text = value and "ON" or "OFF"
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        value = not value
        button.BackgroundColor3 = value and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        button.Text = value and "ON" or "OFF"
        callback(value)
    end)
    
    return toggleFrame, button
end

local function createSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, 0, 0, 10)
    sliderBG.Position = UDim2.new(0, 0, 0, 25)
    sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBG.Parent = sliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    sliderFill.Parent = sliderBG
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.Parent = sliderFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    
    local function updateSlider(pos)
        local relativePos = math.clamp((pos.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relativePos)
        
        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        sliderButton.Position = UDim2.new(relativePos, -10, 0.5, -10)
        valueLabel.Text = tostring(value)
        
        callback(value)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return sliderFrame
end

local function createDropdown(parent, text, options, default, callback)
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, 50)
    dropFrame.BackgroundTransparency = 1
    dropFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 25)
    button.Position = UDim2.new(0, 0, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    button.Text = default
    button.Font = Enum.Font.Gotham
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 13
    button.Parent = dropFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, default) or 1
        local nextIndex = (currentIndex % #options) + 1
        default = options[nextIndex]
        button.Text = default
        callback(default)
    end)
    
    return dropFrame
end

createToggle(espScroll, "ESP Enabled", ESP.Enabled, function(value)
    ESP.Enabled = value
    ESPModule.updateESP(ESP)
end)

createToggle(espScroll, "Chams", ESP.Chams, function(value)
    ESP.Chams = value
    ESPModule.updateESP(ESP)
end)

createToggle(espScroll, "Glow", ESP.Glow, function(value)
    ESP.Glow = value
    ESPModule.updateESP(ESP)
end)

createToggle(espScroll, "Walls", ESP.Walls, function(value)
    ESP.Walls = value
    ESPModule.updateESP(ESP)
end)

createDropdown(espScroll, "Material", Materials, ESP.Material, function(value)
    ESP.Material = value
    ESPModule.updateESP(ESP)
end)

local function createColorPicker(parent, text, default, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, 0, 0, 40)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorFrame
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 60, 0, 25)
    preview.Position = UDim2.new(1, -60, 0.5, -12.5)
    preview.BackgroundColor3 = default
    preview.Parent = colorFrame
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = preview
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(1, 0, 1, 0)
    colorButton.BackgroundTransparency = 1
    colorButton.Text = ""
    colorButton.Parent = preview
    
    colorButton.MouseButton1Click:Connect(function()
        local colorModal = Instance.new("TextButton")
        colorModal.Size = UDim2.new(0, 150, 0, 150)
        colorModal.Position = UDim2.new(0.5, -75, 0.5, -75)
        colorModal.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        colorModal.Text = ""
        colorModal.ZIndex = 10
        colorModal.Parent = gui
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 6)
        colorCorner.Parent = colorModal
        
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }
        hueGradient.Parent = colorModal
        
        local isPicking = false
        local connection1
        local connection2
        
        colorModal.MouseButton1Down:Connect(function()
            isPicking = true
            
            connection1 = game:GetService("RunService").RenderStepped:Connect(function()
                if isPicking then
                    local mousePos = UIS:GetMouseLocation()
                    local modalPos = colorModal.AbsolutePosition
                    local modalSize = colorModal.AbsoluteSize
                    
                    local x = math.clamp((mousePos.X - modalPos.X) / modalSize.X, 0, 1)
                    local y = math.clamp((mousePos.Y - modalPos.Y) / modalSize.Y, 0, 1)
                    
                    local hue = x
                    local saturation = 1
                    local value = 1 - y
                    
                    local color = Color3.fromHSV(hue, saturation, value)
                    preview.BackgroundColor3 = color
                    callback(color)
                end
            end)
        end)
        
        connection2 = UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isPicking = false
                if connection1 then
                    connection1:Disconnect()
                end
            end
        end)
        
        local closeConnection
        closeConnection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UIS:GetMouseLocation()
                local modalPos = colorModal.AbsolutePosition
                local modalSize = colorModal.AbsoluteSize
                
                if mousePos.X < modalPos.X or mousePos.X > modalPos.X + modalSize.X or
                   mousePos.Y < modalPos.Y or mousePos.Y > modalPos.Y + modalSize.Y then
                    
                    if connection1 then connection1:Disconnect() end
                    if connection2 then connection2:Disconnect() end
                    if closeConnection then closeConnection:Disconnect() end
                    colorModal:Destroy()
                end
            end
        end)
    end)
end

createColorPicker(espScroll, "ESP Color", ESP.Color, function(value)
    ESP.Color = value
    ESPModule.updateESP(ESP)
end)

createToggle(aimbotScroll, "Aimbot Enabled", Aimbot.Enabled, function(value)
    Aimbot.Enabled = value
    if AimFunctions then
        if value then
            AimFunctions.EnableAimbot(Aimbot.AimPart, Aimbot.Smoothness, Aimbot.AimKey, Aimbot.AimMethod)
        else
            AimFunctions.DisableAimbot()
        end
    end
end)

createDropdown(aimbotScroll, "Aim Part", AimParts, Aimbot.AimPart, function(value)
    Aimbot.AimPart = value
    if AimFunctions and Aimbot.Enabled then
        AimFunctions.UpdateAimPart(value)
    end
end)

createSlider(aimbotScroll, "Smoothness", 0.01, 1, Aimbot.Smoothness, function(value)
    Aimbot.Smoothness = value
    if AimFunctions and Aimbot.Enabled then
        AimFunctions.UpdateSmoothness(value)
    end
end)

createDropdown(aimbotScroll, "Aim Method", {"Camera", "Mouse"}, Aimbot.AimMethod, function(value)
    Aimbot.AimMethod = value
    if AimFunctions and Aimbot.Enabled then
        AimFunctions.UpdateAimMethod(value)
    end
end)

local keyPickerFrame = Instance.new("Frame")
keyPickerFrame.Size = UDim2.new(1, 0, 0, 50)
keyPickerFrame.BackgroundTransparency = 1
keyPickerFrame.Parent = aimbotScroll

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, 0, 0, 20)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Aim Key"
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
keyLabel.TextSize = 14
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = keyPickerFrame

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(1, 0, 0, 25)
keyButton.Position = UDim2.new(0, 0, 0, 20)
keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
keyButton.Text = "Right Mouse"
keyButton.Font = Enum.Font.Gotham
keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keyButton.TextSize = 13
keyButton.Parent = keyPickerFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 4)
buttonCorner.Parent = keyButton

local pickingKey = false

keyButton.MouseButton1Click:Connect(function()
    pickingKey = true
    keyButton.Text = "Press any key..."
    keyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
end)

UIS.InputBegan:Connect(function(input)
    if pickingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Aimbot.AimKey = input.KeyCode
            keyButton.Text = input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.MouseButton2 or
               input.UserInputType == Enum.UserInputType.MouseButton3 then
            Aimbot.AimKey = input.UserInputType
            keyButton.Text = input.UserInputType.Name
        end
        
        if AimFunctions and Aimbot.Enabled then
            AimFunctions.UpdateAimKey(Aimbot.AimKey)
        end
        
        keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        pickingKey = false
    end
end)

createToggle(fovScroll, "FOV Circle", FOV.Enabled, function(value)
    FOV.Enabled = value
    FOV.Visible = value
    ESPModule.updateFOV(FOV)
end)

createToggle(fovScroll, "FOV Visible", FOV.Visible, function(value)
    FOV.Visible = value
    ESPModule.updateFOV(FOV)
end)

createSlider(fovScroll, "FOV Radius", 20, 200, FOV.Radius, function(value)
    FOV.Radius = value
    ESPModule.updateFOV(FOV)
end)

createColorPicker(fovScroll, "FOV Color", FOV.Color, function(value)
    FOV.Color = value
    ESPModule.updateFOV(FOV)
end)

function showTab(tabName)
    espScroll.Visible = (tabName == "ESP")
    aimbotScroll.Visible = (tabName == "Aimbot")
    fovScroll.Visible = (tabName == "FOV")
end

espLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    espScroll.CanvasSize = UDim2.new(0, 0, 0, espLayout.AbsoluteContentSize.Y)
end)

aimbotLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    aimbotScroll.CanvasSize = UDim2.new(0, 0, 0, aimbotLayout.AbsoluteContentSize.Y)
end)

fovLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    fovScroll.CanvasSize = UDim2.new(0, 0, 0, fovLayout.AbsoluteContentSize.Y)
end)

showTab("ESP")

UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

task.spawn(function()
    wait(1)
    ESPModule.updateFOVCircle()
end)
