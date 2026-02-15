local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

local parentGui = game:GetService("CoreGui")
if not parentGui then
    parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Table to store all connections for easy cleanup
local Connections = {}

------------------ WATERMARK (auto‑sizing) ------------------
local WatermarkGui = Instance.new("ScreenGui")
local WatermarkFrame = Instance.new("Frame")
local WatermarkText = Instance.new("TextLabel")

WatermarkGui.Name = "PlutoWatermark"
WatermarkGui.Parent = parentGui
WatermarkGui.ResetOnSpawn = false
WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WatermarkGui.Enabled = true

WatermarkFrame.Name = "WatermarkFrame"
WatermarkFrame.Parent = WatermarkGui
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.AnchorPoint = Vector2.new(1, 0)
WatermarkFrame.Position = UDim2.new(1, -180, 0, -40)  -- 10px from right, 5px from top
WatermarkFrame.Size = UDim2.new(0, 200, 0, 25)    -- initial, will be resized
WatermarkFrame.BackgroundTransparency = 0.2

WatermarkText.Name = "WatermarkText"
WatermarkText.Parent = WatermarkFrame
WatermarkText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WatermarkText.BackgroundTransparency = 1
WatermarkText.Size = UDim2.new(1, 0, 1, 0)
WatermarkText.Font = Enum.Font.Gotham
WatermarkText.Text = "PlutoRIVALS Dev:Plutana-eng | FPS: 60"
WatermarkText.TextColor3 = Color3.fromRGB(255, 255, 255)
WatermarkText.TextSize = 13
WatermarkText.TextXAlignment = Enum.TextXAlignment.Right

-- Function to resize frame to fit text
local function resizeWatermark()
    local text = WatermarkText.Text
    local fontSize = WatermarkText.TextSize
    local font = WatermarkText.Font
    local textSize = TextService:GetTextSize(text, fontSize, font, Vector2.new(1000, 1000))
    WatermarkFrame.Size = UDim2.new(0, textSize.X + 10, 0, 25)  -- +10 for padding
end

local frameCount = 0
local lastTime = tick()
local fps = 60
local fpsUpdateConn = RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 0.5 then
        fps = math.floor(frameCount / (now - lastTime) + 0.5)
        frameCount = 0
        lastTime = now
        WatermarkText.Text = "PlutoRIVALS Dev:Plutana-eng | FPS: " .. fps
        resizeWatermark()
    end
end)
table.insert(Connections, fpsUpdateConn)
resizeWatermark()  -- initial resize

------------------ SETTINGS ------------------
local Settings = {
    Toggles = {
        BoxESP = false,
        Tracers = false,
        TeamCheck = true,
        TargetHighlight = true,
        SilentAim = false,
        FOVCircle = true,
        SkyMod = false,
    },
    Colors = {
        Box = Color3.fromRGB(255, 0, 0),
        Tracer = Color3.fromRGB(255, 0, 0),
        Target = Color3.fromRGB(255, 255, 0),
        FOV = Color3.fromRGB(255, 0, 0),
        FOVLocked = Color3.fromRGB(0, 255, 0),
        TeamEnemy = Color3.fromRGB(227, 52, 52),    -- red
        TeamFriend = Color3.fromRGB(88, 217, 24),   -- green
    },
    Sky = {
        Ambient = Color3.fromRGB(0, 0, 0),
        OutdoorAmbient = Color3.fromRGB(0, 0, 0),
        ColorShiftTop = Color3.fromRGB(0, 0, 0),
        ColorShiftBottom = Color3.fromRGB(0, 0, 0),
        FogColor = Color3.fromRGB(0, 0, 0),
        Brightness = 1,
    },
    Aim = {
        FOV = 200,
    }
}

-- Helper: apply current sky settings
local function applySky()
    if Settings.Toggles.SkyMod then
        Lighting.Ambient = Settings.Sky.Ambient
        Lighting.OutdoorAmbient = Settings.Sky.OutdoorAmbient
        Lighting.ColorShift_Top = Settings.Sky.ColorShiftTop
        Lighting.ColorShift_Bottom = Settings.Sky.ColorShiftBottom
        Lighting.FogColor = Settings.Sky.FogColor
        Lighting.Brightness = Settings.Sky.Brightness
    else
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
    end
end

------------------ MAIN MENU ------------------
local Menu = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local EspTab = Instance.new("TextButton")
local AimTab = Instance.new("TextButton")
local SkyTab = Instance.new("TextButton")
local EspContent = Instance.new("ScrollingFrame")
local AimContent = Instance.new("ScrollingFrame")
local SkyContent = Instance.new("ScrollingFrame")
local StatusText = Instance.new("TextLabel")

Menu.Name = "PlutoRIVALS"
Menu.Parent = parentGui
Menu.Enabled = true   -- start visible
Menu.ResetOnSpawn = false
Menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = Menu
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)  -- centered
MainFrame.Size = UDim2.new(0, 300, 0, 260)
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

-- Tab buttons
local tabY = 30
EspTab.Name = "EspTab"
EspTab.Parent = MainFrame
EspTab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
EspTab.BorderSizePixel = 0
EspTab.Position = UDim2.new(0, 10, 0, tabY)
EspTab.Size = UDim2.new(0, 90, 0, 25)
EspTab.Font = Enum.Font.Gotham
EspTab.Text = "ESP"
EspTab.TextColor3 = Color3.fromRGB(255, 255, 255)
EspTab.TextSize = 12

AimTab.Name = "AimTab"
AimTab.Parent = MainFrame
AimTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimTab.BorderSizePixel = 0
AimTab.Position = UDim2.new(0, 105, 0, tabY)
AimTab.Size = UDim2.new(0, 90, 0, 25)
AimTab.Font = Enum.Font.Gotham
AimTab.Text = "AIM"
AimTab.TextColor3 = Color3.fromRGB(255, 255, 255)
AimTab.TextSize = 12

SkyTab.Name = "SkyTab"
SkyTab.Parent = MainFrame
SkyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SkyTab.BorderSizePixel = 0
SkyTab.Position = UDim2.new(0, 200, 0, tabY)
SkyTab.Size = UDim2.new(0, 90, 0, 25)
SkyTab.Font = Enum.Font.Gotham
SkyTab.Text = "SKY"
SkyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
SkyTab.TextSize = 12

-- Content frames (ScrollingFrame)
local contentY = 60
local contentHeight = 165
EspContent.Name = "EspContent"
EspContent.Parent = MainFrame
EspContent.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspContent.BorderSizePixel = 0
EspContent.Position = UDim2.new(0, 10, 0, contentY)
EspContent.Size = UDim2.new(1, -20, 0, contentHeight)
EspContent.CanvasSize = UDim2.new(0, 0, 0, 0)
EspContent.ScrollBarThickness = 4
EspContent.Visible = true

AimContent.Name = "AimContent"
AimContent.Parent = MainFrame
AimContent.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AimContent.BorderSizePixel = 0
AimContent.Position = UDim2.new(0, 10, 0, contentY)
AimContent.Size = UDim2.new(1, -20, 0, contentHeight)
AimContent.CanvasSize = UDim2.new(0, 0, 0, 0)
AimContent.ScrollBarThickness = 4
AimContent.Visible = false

SkyContent.Name = "SkyContent"
SkyContent.Parent = MainFrame
SkyContent.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SkyContent.BorderSizePixel = 0
SkyContent.Position = UDim2.new(0, 10, 0, contentY)
SkyContent.Size = UDim2.new(1, -20, 0, contentHeight)
SkyContent.CanvasSize = UDim2.new(0, 0, 0, 0)
SkyContent.ScrollBarThickness = 4
SkyContent.Visible = false

-- Status text (always visible)
StatusText.Name = "StatusText"
StatusText.Parent = MainFrame
StatusText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusText.BorderSizePixel = 0
StatusText.Position = UDim2.new(0, 10, 0, 230)
StatusText.Size = UDim2.new(1, -20, 0, 25)
StatusText.Font = Enum.Font.Gotham
StatusText.Text = "Hold RMB for silent aim"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextSize = 11

-- Tab switching
table.insert(Connections, EspTab.MouseButton1Click:Connect(function()
    EspTab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    AimTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SkyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    EspContent.Visible = true
    AimContent.Visible = false
    SkyContent.Visible = false
end))

table.insert(Connections, AimTab.MouseButton1Click:Connect(function()
    EspTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AimTab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SkyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    EspContent.Visible = false
    AimContent.Visible = true
    SkyContent.Visible = false
end))

table.insert(Connections, SkyTab.MouseButton1Click:Connect(function()
    EspTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AimTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SkyTab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    EspContent.Visible = false
    AimContent.Visible = false
    SkyContent.Visible = true
end))

------------------ HELPER FUNCTIONS FOR UI ------------------
local function makeToggle(parent, text, y, settingPath)
    local btn = Instance.new("TextButton")
    btn.Name = text.."Toggle"
    btn.Parent = parent
    btn.BackgroundColor3 = Settings.Toggles[settingPath] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.Size = UDim2.new(1, -10, 0, 20)
    btn.Font = Enum.Font.Gotham
    btn.Text = text..": "..(Settings.Toggles[settingPath] and "ON" or "OFF")
    btn.TextColor3 = Settings.Toggles[settingPath] and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    table.insert(Connections, btn.MouseButton1Click:Connect(function()
        Settings.Toggles[settingPath] = not Settings.Toggles[settingPath]
        btn.BackgroundColor3 = Settings.Toggles[settingPath] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Settings.Toggles[settingPath] and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        btn.Text = text..": "..(Settings.Toggles[settingPath] and "ON" or "OFF")
        if settingPath == "SkyMod" then applySky() end
    end))
    return btn
end

local function makeColorPicker(parent, label, y, colorRef, applyFunc)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.Size = UDim2.new(1, -10, 0, 40)

    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 15)
    title.Font = Enum.Font.Gotham
    title.Text = label
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextSize = 10

    local swatch = Instance.new("Frame")
    swatch.Parent = frame
    swatch.BackgroundColor3 = colorRef
    swatch.BorderSizePixel = 1
    swatch.BorderColor3 = Color3.fromRGB(255, 255, 255)
    swatch.Position = UDim2.new(0, 5, 0, 18)
    swatch.Size = UDim2.new(0, 20, 0, 18)

    local box = Instance.new("TextBox")
    box.Parent = frame
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    box.BorderSizePixel = 0
    box.Position = UDim2.new(0, 30, 0, 18)
    box.Size = UDim2.new(1, -70, 0, 18)
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = "R,G,B (0-255)"
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 10

    local setBtn = Instance.new("TextButton")
    setBtn.Parent = frame
    setBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    setBtn.BorderSizePixel = 0
    setBtn.Position = UDim2.new(1, -35, 0, 18)
    setBtn.Size = UDim2.new(0, 30, 0, 18)
    setBtn.Font = Enum.Font.Gotham
    setBtn.Text = "Set"
    setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setBtn.TextSize = 10
    table.insert(Connections, setBtn.MouseButton1Click:Connect(function()
        local r,g,b = box.Text:match("(%d+),%s*(%d+),%s*(%d+)")
        if r and g and b then
            local cr = Color3.fromRGB(math.clamp(tonumber(r),0,255), math.clamp(tonumber(g),0,255), math.clamp(tonumber(b),0,255))
            colorRef.R = cr.R
            colorRef.G = cr.G
            colorRef.B = cr.B
            swatch.BackgroundColor3 = colorRef
            if applyFunc then applyFunc() end
        end
    end))

    return frame
end

------------------ POPULATE ESP TAB ------------------
local espY = 5
makeToggle(EspContent, "Box ESP", espY, "BoxESP")
espY = espY + 25
makeToggle(EspContent, "Tracers", espY, "Tracers")
espY = espY + 25
makeToggle(EspContent, "Team Check", espY, "TeamCheck")
espY = espY + 25
makeToggle(EspContent, "Target Highlight", espY, "TargetHighlight")
espY = espY + 30

makeColorPicker(EspContent, "Box Color", espY, Settings.Colors.Box, function() end)
espY = espY + 45
makeColorPicker(EspContent, "Tracer Color", espY, Settings.Colors.Tracer, function() end)
espY = espY + 45
makeColorPicker(EspContent, "Target Color", espY, Settings.Colors.Target, function() end)
espY = espY + 45
makeColorPicker(EspContent, "Enemy Team", espY, Settings.Colors.TeamEnemy, function() end)
espY = espY + 45
makeColorPicker(EspContent, "Friend Team", espY, Settings.Colors.TeamFriend, function() end)
espY = espY + 45

EspContent.CanvasSize = UDim2.new(0, 0, 0, espY + 10)

------------------ POPULATE AIM TAB ------------------
local aimY = 5
makeToggle(AimContent, "Silent Aim", aimY, "SilentAim")
aimY = aimY + 25
makeToggle(AimContent, "FOV Circle", aimY, "FOVCircle")
aimY = aimY + 25

-- FOV size control
local fovFrame = Instance.new("Frame")
fovFrame.Parent = AimContent
fovFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
fovFrame.BorderSizePixel = 0
fovFrame.Position = UDim2.new(0, 5, 0, aimY)
fovFrame.Size = UDim2.new(1, -10, 0, 40)

local fovTitle = Instance.new("TextLabel")
fovTitle.Parent = fovFrame
fovTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fovTitle.BorderSizePixel = 0
fovTitle.Size = UDim2.new(1, 0, 0, 15)
fovTitle.Font = Enum.Font.Gotham
fovTitle.Text = "FOV Size"
fovTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
fovTitle.TextSize = 10

local fovDown = Instance.new("TextButton")
fovDown.Parent = fovFrame
fovDown.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
fovDown.BorderSizePixel = 0
fovDown.Position = UDim2.new(0, 5, 0, 18)
fovDown.Size = UDim2.new(0, 30, 0, 18)
fovDown.Font = Enum.Font.Gotham
fovDown.Text = "-"
fovDown.TextColor3 = Color3.fromRGB(255, 255, 255)
fovDown.TextSize = 12

local fovValue = Instance.new("TextLabel")
fovValue.Parent = fovFrame
fovValue.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fovValue.BorderSizePixel = 0
fovValue.Position = UDim2.new(0, 40, 0, 18)
fovValue.Size = UDim2.new(1, -80, 0, 18)
fovValue.Font = Enum.Font.Gotham
fovValue.Text = tostring(Settings.Aim.FOV)
fovValue.TextColor3 = Color3.fromRGB(255, 255, 255)
fovValue.TextSize = 10

local fovUp = Instance.new("TextButton")
fovUp.Parent = fovFrame
fovUp.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
fovUp.BorderSizePixel = 0
fovUp.Position = UDim2.new(1, -35, 0, 18)
fovUp.Size = UDim2.new(0, 30, 0, 18)
fovUp.Font = Enum.Font.Gotham
fovUp.Text = "+"
fovUp.TextColor3 = Color3.fromRGB(255, 255, 255)
fovUp.TextSize = 12

table.insert(Connections, fovDown.MouseButton1Click:Connect(function()
    Settings.Aim.FOV = math.max(50, Settings.Aim.FOV - 10)
    fovValue.Text = tostring(Settings.Aim.FOV)
end))

table.insert(Connections, fovUp.MouseButton1Click:Connect(function()
    Settings.Aim.FOV = math.min(500, Settings.Aim.FOV + 10)
    fovValue.Text = tostring(Settings.Aim.FOV)
end))

aimY = aimY + 45
makeColorPicker(AimContent, "FOV Color", aimY, Settings.Colors.FOV, function() end)
aimY = aimY + 45
makeColorPicker(AimContent, "FOV Locked Color", aimY, Settings.Colors.FOVLocked, function() end)
aimY = aimY + 45

AimContent.CanvasSize = UDim2.new(0, 0, 0, aimY + 10)

------------------ POPULATE SKY TAB ------------------
local skyY = 5
makeToggle(SkyContent, "Sky Mod", skyY, "SkyMod")
skyY = skyY + 30

-- Dropdown to select sky property
local propFrame = Instance.new("Frame")
propFrame.Parent = SkyContent
propFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
propFrame.BorderSizePixel = 0
propFrame.Position = UDim2.new(0, 5, 0, skyY)
propFrame.Size = UDim2.new(1, -10, 0, 40)

local propTitle = Instance.new("TextLabel")
propTitle.Parent = propFrame
propTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
propTitle.BorderSizePixel = 0
propTitle.Size = UDim2.new(1, 0, 0, 15)
propTitle.Font = Enum.Font.Gotham
propTitle.Text = "Select Property"
propTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
propTitle.TextSize = 10

local propDropdown = Instance.new("TextButton")
propDropdown.Name = "PropDropdown"
propDropdown.Parent = propFrame
propDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
propDropdown.BorderSizePixel = 0
propDropdown.Position = UDim2.new(0, 5, 0, 18)
propDropdown.Size = UDim2.new(1, -10, 0, 18)
propDropdown.Font = Enum.Font.Gotham
propDropdown.Text = "Ambient"
propDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
propDropdown.TextSize = 10

local skyProperties = {
    "Ambient", "OutdoorAmbient", "ColorShiftTop", "ColorShiftBottom", "FogColor"
}
local propIndex = 1
table.insert(Connections, propDropdown.MouseButton1Click:Connect(function()
    propIndex = propIndex % #skyProperties + 1
    propDropdown.Text = skyProperties[propIndex]
end))

skyY = skyY + 45

-- Color picker for selected property
local skyColorFrame = Instance.new("Frame")
skyColorFrame.Parent = SkyContent
skyColorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
skyColorFrame.BorderSizePixel = 0
skyColorFrame.Position = UDim2.new(0, 5, 0, skyY)
skyColorFrame.Size = UDim2.new(1, -10, 0, 40)

local swatchSky = Instance.new("Frame")
swatchSky.Parent = skyColorFrame
swatchSky.BackgroundColor3 = Settings.Sky.Ambient
swatchSky.BorderSizePixel = 1
swatchSky.BorderColor3 = Color3.fromRGB(255, 255, 255)
swatchSky.Position = UDim2.new(0, 5, 0, 18)
swatchSky.Size = UDim2.new(0, 20, 0, 18)

local boxSky = Instance.new("TextBox")
boxSky.Parent = skyColorFrame
boxSky.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
boxSky.BorderSizePixel = 0
boxSky.Position = UDim2.new(0, 30, 0, 18)
boxSky.Size = UDim2.new(1, -70, 0, 18)
boxSky.Font = Enum.Font.Gotham
boxSky.PlaceholderText = "R,G,B (0-255)"
boxSky.Text = ""
boxSky.TextColor3 = Color3.fromRGB(255, 255, 255)
boxSky.TextSize = 10

local setSkyBtn = Instance.new("TextButton")
setSkyBtn.Parent = skyColorFrame
setSkyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
setSkyBtn.BorderSizePixel = 0
setSkyBtn.Position = UDim2.new(1, -35, 0, 18)
setSkyBtn.Size = UDim2.new(0, 30, 0, 18)
setSkyBtn.Font = Enum.Font.Gotham
setSkyBtn.Text = "Set"
setSkyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setSkyBtn.TextSize = 10
table.insert(Connections, setSkyBtn.MouseButton1Click:Connect(function()
    local r,g,b = boxSky.Text:match("(%d+),%s*(%d+),%s*(%d+)")
    if r and g and b then
        local cr = Color3.fromRGB(math.clamp(tonumber(r),0,255), math.clamp(tonumber(g),0,255), math.clamp(tonumber(b),0,255))
        local prop = skyProperties[propIndex]
        if prop == "Ambient" then
            Settings.Sky.Ambient = cr
        elseif prop == "OutdoorAmbient" then
            Settings.Sky.OutdoorAmbient = cr
        elseif prop == "ColorShiftTop" then
            Settings.Sky.ColorShiftTop = cr
        elseif prop == "ColorShiftBottom" then
            Settings.Sky.ColorShiftBottom = cr
        elseif prop == "FogColor" then
            Settings.Sky.FogColor = cr
        end
        swatchSky.BackgroundColor3 = cr
        applySky()
    end
end))

skyY = skyY + 45

-- Brightness slider
local brightFrame = Instance.new("Frame")
brightFrame.Parent = SkyContent
brightFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
brightFrame.BorderSizePixel = 0
brightFrame.Position = UDim2.new(0, 5, 0, skyY)
brightFrame.Size = UDim2.new(1, -10, 0, 40)

local brightTitle = Instance.new("TextLabel")
brightTitle.Parent = brightFrame
brightTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
brightTitle.BorderSizePixel = 0
brightTitle.Size = UDim2.new(1, 0, 0, 15)
brightTitle.Font = Enum.Font.Gotham
brightTitle.Text = "Brightness"
brightTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
brightTitle.TextSize = 10

local brightSlider = Instance.new("TextBox")
brightSlider.Parent = brightFrame
brightSlider.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
brightSlider.BorderSizePixel = 0
brightSlider.Position = UDim2.new(0, 5, 0, 18)
brightSlider.Size = UDim2.new(1, -10, 0, 18)
brightSlider.Font = Enum.Font.Gotham
brightSlider.PlaceholderText = "0 - 2"
brightSlider.Text = tostring(Settings.Sky.Brightness)
brightSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
brightSlider.TextSize = 10
table.insert(Connections, brightSlider.FocusLost:Connect(function()
    local val = tonumber(brightSlider.Text)
    if val then
        Settings.Sky.Brightness = math.clamp(val, 0, 2)
        brightSlider.Text = tostring(Settings.Sky.Brightness)
        applySky()
    end
end))

skyY = skyY + 45
SkyContent.CanvasSize = UDim2.new(0, 0, 0, skyY + 10)

------------------ ORIGINAL FUNCTIONALITY (ESP, AIM, etc.) ------------------
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

local function updateAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.Toggles.BoxESP then
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
    local bestDist = Settings.Aim.FOV
    
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

-- Drawing objects
local function NewLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(1, 1)
    line.Color = Settings.Colors.Box
    line.Thickness = 1.4
    line.Transparency = 1
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
    ESPObjects[v] = lines
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        createESPForPlayer(v)
    end
end

local function updateESP()
    for v, lines in pairs(ESPObjects) do
        if Settings.Toggles.BoxESP and v and v.Character and v.Character:FindFirstChild("Humanoid") and 
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

                if Settings.Toggles.Tracers then
                    local trace = Camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(0, -Size.Y, 0)).p)
                    lines.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    lines.Tracer.To = Vector2.new(trace.X, trace.Y)
                    lines.Tracer.Visible = true
                else
                    lines.Tracer.Visible = false
                end

                -- Determine box color
                local boxColor
                if Settings.Toggles.TeamCheck then
                    boxColor = isEnemy(v) and Settings.Colors.TeamEnemy or Settings.Colors.TeamFriend
                else
                    boxColor = Settings.Colors.Box
                end
                if v == currentTarget and Settings.Toggles.TargetHighlight then
                    boxColor = Settings.Colors.Target
                end

                for _, line in pairs(lines) do
                    if line ~= lines.Tracer then
                        line.Color = boxColor
                    else
                        line.Color = Settings.Colors.Tracer
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

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.Toggles.FOVCircle
FOVCircle.Radius = Settings.Aim.FOV
FOVCircle.Color = Settings.Colors.FOV
FOVCircle.Transparency = 0.5
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Filled = false

-- Aim logic
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.Toggles.SilentAim then
        local target = getTarget()
        if target and target.Character and target.Character.Head then
            currentTarget = target
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end))

local renderConn = RunService.RenderStepped:Connect(function()
    if not scriptLoaded then return end
    if Settings.Toggles.SilentAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getTarget()
        currentTarget = target
        if target and target.Character and target.Character.Head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    elseif not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        currentTarget = nil
    end
    updateESP()

    -- Update FOV circle
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Radius = Settings.Aim.FOV
    FOVCircle.Visible = Settings.Toggles.FOVCircle
    FOVCircle.Color = currentTarget and Settings.Colors.FOVLocked or Settings.Colors.FOV
end)
table.insert(Connections, renderConn)

-- Player connections
table.insert(Connections, Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESPForPlayer(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Settings.Toggles.BoxESP then
                makeBlankGray(player.Character)
                makeRedPlastic(player.Character)
            end
        end)
    end
end))

table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, line in pairs(ESPObjects[player]) do
            pcall(function() line:Remove() end)
        end
        ESPObjects[player] = nil
    end
end))

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Settings.Toggles.BoxESP then
                makeBlankGray(player.Character)
                makeRedPlastic(player.Character)
            end
        end)
    end
end

------------------ KEYBINDS ------------------
-- Toggle menu with Right Ctrl
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Menu.Enabled = not Menu.Enabled
    end
end))

-- Unload everything with End key
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.End then
        -- Disable script loops
        scriptLoaded = false
        
        -- Destroy GUIs
        if Menu then Menu:Destroy() end
        if WatermarkGui then WatermarkGui:Destroy() end
        
        -- Disconnect all connections
        for _, conn in ipairs(Connections) do
            pcall(function() conn:Disconnect() end)
        end
        
        -- Remove all ESP lines
        for _, lines in pairs(ESPObjects) do
            for _, line in pairs(lines) do
                pcall(function() line:Remove() end)
            end
        end
        ESPObjects = nil
        
        -- Remove FOV circle
        if FOVCircle then
            pcall(function() FOVCircle:Remove() end)
        end
        
        -- Clear any remaining references
        Connections = {}
        print("PlutoRIVALS unloaded.")
    end
end))
