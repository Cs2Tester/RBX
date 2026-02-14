-- PlutoChams Menu Library
-- A sleek black and white UI library for Roblox hacking scripts

local MenuLib = {}

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

MenuLib.Gui = nil
MenuLib.MainFrame = nil
MenuLib.CurrentTab = "ESP"

MenuLib.Config = {
    ToggleKey = Enum.KeyCode.Insert,
    Theme = {
        Primary = Color3.fromRGB(18, 18, 18),
        Secondary = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(230, 230, 230),
        Muted = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 60),
        Success = Color3.fromRGB(255, 255, 255),
        Danger = Color3.fromRGB(60, 60, 60)
    }
}

MenuLib.Callbacks = {}
MenuLib.Elements = {}
MenuLib.Tabs = {}

-- Initialize the GUI
function MenuLib:Init()
    if self.Gui then return self.Gui end
    
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "PlutoChamsUI"
    
    -- Apply protection if available
    if gethui then
        self.Gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(self.Gui)
        self.Gui.Parent = game.CoreGui
    else
        self.Gui.Parent = game.CoreGui
    end
    
    self:CreateMainFrame()
    self:SetupKeybinds()
    
    return self.Gui
end

-- Create the main window frame
function MenuLib:CreateMainFrame()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    mainFrame.BackgroundColor3 = self.Config.Theme.Primary
    mainFrame.BorderColor3 = self.Config.Theme.Border
    mainFrame.BorderSizePixel = 1
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = true
    mainFrame.Parent = self.Gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 8)
    titleBarCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "PLUTO CHAMS"
    title.Font = Enum.Font.GothamMedium
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Parent = titleBar
    
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0, 60, 0, 20)
    version.Position = UDim2.new(1, -65, 0, 0)
    version.BackgroundTransparency = 1
    version.Text = "v1.0.1"
    version.Font = Enum.Font.Gotham
    version.TextColor3 = Color3.fromRGB(180, 180, 180)
    version.TextSize = 12
    version.Parent = titleBar
    
    self.MainFrame = mainFrame
    
    -- Create content containers
    self:CreateTabSystem()
    
    return mainFrame
end

-- Create the tab navigation system
function MenuLib:CreateTabSystem()
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -20, 0, 32)
    tabContainer.Position = UDim2.new(0, 10, 0, 40)
    tabContainer.BackgroundColor3 = self.Config.Theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = self.MainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 2)
    tabPadding.PaddingRight = UDim.new(0, 2)
    tabPadding.PaddingTop = UDim.new(0, 2)
    tabPadding.PaddingBottom = UDim.new(0, 2)
    tabPadding.Parent = tabContainer
    
    -- Content frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -20, 1, -90)
    self.ContentFrame.Position = UDim2.new(0, 10, 0, 80)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.Parent = self.MainFrame
    
    self.TabButtons = {}
    self.TabScrollFrames = {}
end

-- Add a new tab
function MenuLib:NewTab(name)
    if self.TabButtons[name] then return end
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.333, -4, 1, 0)
    tabButton.BackgroundColor3 = name == self.CurrentTab and self.Config.Theme.Accent or self.Config.Theme.Secondary
    tabButton.BorderSizePixel = 0
    tabButton.Text = string.upper(name)
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextColor3 = name == self.CurrentTab and Color3.fromRGB(10, 10, 10) or self.Config.Theme.Muted
    tabButton.TextSize = 13
    tabButton.Parent = self.MainFrame:FindFirstChild("Frame") -- Tab container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = tabButton
    
    -- Create scroll frame for tab content
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollFrame.Visible = (name == self.CurrentTab)
    scrollFrame.Parent = self.ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scrollFrame
    
    -- Connect layout changes
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    -- Store references
    self.TabButtons[name] = tabButton
    self.TabScrollFrames[name] = scrollFrame
    self.Tabs[name] = {ScrollFrame = scrollFrame, Layout = layout}
    
    -- Click handler
    tabButton.MouseButton1Click:Connect(function()
        self.CurrentTab = name
        self:ShowTab(name)
    end)
    
    return scrollFrame
end

-- Show a specific tab
function MenuLib:ShowTab(tabName)
    self.CurrentTab = tabName
    
    for name, button in pairs(self.TabButtons) do
        local isActive = (name == tabName)
        button.BackgroundColor3 = isActive and self.Config.Theme.Accent or self.Config.Theme.Secondary
        button.TextColor3 = isActive and Color3.fromRGB(10, 10, 10) or self.Config.Theme.Muted
    end
    
    for name, scrollFrame in pairs(self.TabScrollFrames) do
        scrollFrame.Visible = (name == tabName)
    end
end

-- Create a toggle switch
function MenuLib:Toggle(name, defaultValue, callback)
    local scrollFrame = self.TabScrollFrames[self.CurrentTab]
    if not scrollFrame then return nil end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 28)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.Font = Enum.Font.Gotham
    label.TextColor3 = self.Config.Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 48, 0, 24)
    toggleButton.Position = UDim2.new(1, -48, 0, 2)
    toggleButton.BackgroundColor3 = defaultValue and self.Config.Theme.Success or self.Config.Theme.Danger
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0, 20, 0, 20)
    toggleDot.Position = UDim2.new(defaultValue and 1 or 0, defaultValue and -22 or 2, 0, 2)
    toggleDot.BackgroundColor3 = defaultValue and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(150, 150, 150)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = toggleDot
    
    local toggleClick = Instance.new("TextButton")
    toggleClick.Size = UDim2.new(1, 0, 1, 0)
    toggleClick.BackgroundTransparency = 1
    toggleClick.Text = ""
    toggleClick.Parent = toggleButton
    
    local state = defaultValue
    
    toggleClick.MouseButton1Click:Connect(function()
        state = not state
        
        -- Animate toggle
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        local tween1 = TweenService:Create(toggleDot, tweenInfo, {
            Position = UDim2.new(state and 1 or 0, state and -22 or 2, 0, 2),
            BackgroundColor3 = state and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(150, 150, 150)
        })
        
        local tween2 = TweenService:Create(toggleButton, tweenInfo, {
            BackgroundColor3 = state and self.Config.Theme.Success or self.Config.Theme.Danger
        })
        
        tween1:Play()
        tween2:Play()
        
        if callback then
            callback(state)
        end
    end)
    
    return {
        Set = function(value)
            state = value
            toggleDot.Position = UDim2.new(value and 1 or 0, value and -22 or 2, 0, 2)
            toggleDot.BackgroundColor3 = value and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(150, 150, 150)
            toggleButton.BackgroundColor3 = value and self.Config.Theme.Success or self.Config.Theme.Danger
        end,
        Get = function() return state end
    }
end

-- Create a slider
function MenuLib:Slider(name, min, max, defaultValue, callback)
    local scrollFrame = self.TabScrollFrames[self.CurrentTab]
    if not scrollFrame then return nil end
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 56)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = scrollFrame
    
    local labelContainer = Instance.new("Frame")
    labelContainer.Size = UDim2.new(1, 0, 0, 20)
    labelContainer.BackgroundTransparency = 1
    labelContainer.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.Font = Enum.Font.Gotham
    label.TextColor3 = self.Config.Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = labelContainer
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = labelContainer
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, -4, 0, 4)
    sliderBG.Position = UDim2.new(0, 2, 0, 36)
    sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = sliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Config.Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, -8)
    sliderButton.BackgroundColor3 = self.Config.Theme.Accent
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = sliderFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    local currentValue = defaultValue
    
    local function updateSlider(pos)
        local relativePos = math.clamp((pos.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relativePos)
        
        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        sliderButton.Position = UDim2.new(relativePos, -8, 0.5, -8)
        valueLabel.Text = tostring(value)
        currentValue = value
        
        if callback then
            callback(value)
        end
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
    
    return {
        Set = function(value)
            value = math.clamp(value, min, max)
            local relativePos = (value - min) / (max - min)
            
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativePos, -8, 0.5, -8)
            valueLabel.Text = tostring(value)
            currentValue = value
            
            if callback then
                callback(value)
            end
        end,
        Get = function() return currentValue end
    }
end

-- Create a dropdown
function MenuLib:Dropdown(name, options, defaultValue, callback)
    local scrollFrame = self.TabScrollFrames[self.CurrentTab]
    if not scrollFrame then return nil end
    
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, 52)
    dropFrame.BackgroundTransparency = 1
    dropFrame.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 20)
    label.Position = UDim2.new(0, 2, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.Font = Enum.Font.Gotham
    label.TextColor3 = self.Config.Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropFrame
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -4, 0, 28)
    dropdown.Position = UDim2.new(0, 2, 0, 22)
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropdown.BorderColor3 = self.Config.Theme.Border
    dropdown.BorderSizePixel = 1
    dropdown.Parent = dropFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdown
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.8, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "  " .. defaultValue
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = dropdown
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = Enum.Font.GothamMedium
    arrow.TextColor3 = self.Config.Theme.Muted
    arrow.TextSize = 12
    arrow.Parent = dropdown
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Text = ""
    dropdownButton.Parent = dropdown
    
    local currentValue = defaultValue
    local currentIndex = table.find(options, defaultValue) or 1
    
    dropdownButton.MouseButton1Click:Connect(function()
        local nextIndex = (currentIndex % #options) + 1
        currentValue = options[nextIndex]
        currentIndex = nextIndex
        valueLabel.Text = "  " .. currentValue
        
        if callback then
            callback(currentValue)
        end
    end)
    
    return {
        Set = function(value)
            if table.find(options, value) then
                currentValue = value
                currentIndex = table.find(options, value)
                valueLabel.Text = "  " .. currentValue
            end
        end,
        Get = function() return currentValue end
    }
end

-- Create a color picker
function MenuLib:ColorPicker(name, defaultColor, callback)
    local scrollFrame = self.TabScrollFrames[self.CurrentTab]
    if not scrollFrame then return nil end
    
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, 0, 0, 44)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.Font = Enum.Font.Gotham
    label.TextColor3 = self.Config.Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorFrame
    
    local colorBox = Instance.new("Frame")
    colorBox.Size = UDim2.new(0, 60, 0, 28)
    colorBox.Position = UDim2.new(1, -60, 0, 8)
    colorBox.BackgroundColor3 = defaultColor
    colorBox.BorderColor3 = self.Config.Theme.Border
    colorBox.BorderSizePixel = 1
    colorBox.Parent = colorFrame
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorBox
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(1, 0, 1, 0)
    colorButton.BackgroundTransparency = 1
    colorButton.Text = "PICK"
    colorButton.Font = Enum.Font.GothamMedium
    colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorButton.TextSize = 12
    colorButton.Parent = colorBox
    
    local currentColor = defaultColor
    
    colorButton.MouseButton1Click:Connect(function()
        self:ShowColorPicker(currentColor, function(newColor)
            currentColor = newColor
            colorBox.BackgroundColor3 = newColor
            
            if callback then
                callback(newColor)
            end
        end)
    end)
    
    return {
        Set = function(color)
            currentColor = color
            colorBox.BackgroundColor3 = color
        end,
        Get = function() return currentColor end
    }
end

-- Show color picker modal
function MenuLib:ShowColorPicker(currentColor, callback)
    if self.ColorPickerModal then
        self.ColorPickerModal:Destroy()
    end
    
    local colorModal = Instance.new("Frame")
    colorModal.Size = UDim2.new(0, 180, 0, 160)
    colorModal.Position = UDim2.new(0.5, -90, 0.5, -80)
    colorModal.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    colorModal.BorderColor3 = self.Config.Theme.Border
    colorModal.BorderSizePixel = 1
    colorModal.ZIndex = 10
    colorModal.Parent = self.Gui
    
    self.ColorPickerModal = colorModal
    
    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = UDim.new(0, 8)
    modalCorner.Parent = colorModal
    
    local modalTitle = Instance.new("TextLabel")
    modalTitle.Size = UDim2.new(1, 0, 0, 28)
    modalTitle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    modalTitle.Text = "Pick Color"
    modalTitle.Font = Enum.Font.GothamMedium
    modalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    modalTitle.TextSize = 14
    modalTitle.Parent = colorModal
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = modalTitle
    
    local colorArea = Instance.new("Frame")
    colorArea.Size = UDim2.new(1, -20, 0, 100)
    colorArea.Position = UDim2.new(0, 10, 0, 40)
    colorArea.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    colorArea.BorderSizePixel = 0
    colorArea.Parent = colorModal
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorArea
    
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
    hueGradient.Parent = colorArea
    
    local brightnessOverlay = Instance.new("Frame")
    brightnessOverlay.Size = UDim2.new(1, 0, 1, 0)
    brightnessOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    brightnessOverlay.BackgroundTransparency = 0.5
    brightnessOverlay.BorderSizePixel = 0
    brightnessOverlay.Parent = colorArea
    
    local isPicking = false
    local connection
    
    local function updateColorFromMouse()
        local mousePos = UIS:GetMouseLocation()
        local areaPos = colorArea.AbsolutePosition
        local areaSize = colorArea.AbsoluteSize
        
        local x = math.clamp((mousePos.X - areaPos.X) / areaSize.X, 0, 1)
        local y = math.clamp((mousePos.Y - areaPos.Y) / areaSize.Y, 0, 1)
        
        local hue = x
        local saturation = 1
        local value = 1 - y
        
        local color = Color3.fromHSV(hue, saturation, value)
        
        if callback then
            callback(color)
        end
    end
    
    colorArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isPicking = true
            
            connection = RunService.RenderStepped:Connect(function()
                if isPicking then
                    updateColorFromMouse()
                end
            end)
        end
    end)
    
    colorArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isPicking = false
            if connection then
                connection:Disconnect()
            end
        end
    end)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -20, 0, 28)
    closeButton.Position = UDim2.new(0, 10, 1, -38)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeButton.Text = "CLOSE"
    closeButton.Font = Enum.Font.GothamMedium
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 13
    closeButton.Parent = colorModal
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        if connection then 
            connection:Disconnect() 
        end
        self.ColorPickerModal:Destroy()
        self.ColorPickerModal = nil
    end)
    
    -- Close when clicking outside
    local closeConnection
    closeConnection = UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UIS:GetMouseLocation()
            local modalPos = colorModal.AbsolutePosition
            local modalSize = colorModal.AbsoluteSize
            
            if mousePos.X < modalPos.X or mousePos.X > modalPos.X + modalSize.X or
               mousePos.Y < modalPos.Y or mousePos.Y > modalPos.Y + modalSize.Y then
                
                if connection then connection:Disconnect() end
                if closeConnection then closeConnection:Disconnect() end
                colorModal:Destroy()
                self.ColorPickerModal = nil
            end
        end
    end)
end

-- Create a keybind button
function MenuLib:Keybind(name, defaultKey, callback)
    local scrollFrame = self.TabScrollFrames[self.CurrentTab]
    if not scrollFrame then return nil end
    
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(1, 0, 0, 52)
    keyFrame.BackgroundTransparency = 1
    keyFrame.Parent = scrollFrame
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, -4, 0, 20)
    keyLabel.Position = UDim2.new(0, 2, 0, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = "  " .. name
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.TextColor3 = self.Config.Theme.Text
    keyLabel.TextSize = 14
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.Parent = keyFrame
    
    local keyBox = Instance.new("Frame")
    keyBox.Size = UDim2.new(1, -4, 0, 28)
    keyBox.Position = UDim2.new(0, 2, 0, 22)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    keyBox.BorderColor3 = self.Config.Theme.Border
    keyBox.BorderSizePixel = 1
    keyBox.Parent = keyFrame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keyBox
    
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(1, 0, 1, 0)
    keyButton.BackgroundTransparency = 1
    keyButton.Text = tostring(defaultKey.Name or defaultKey)
    keyButton.Font = Enum.Font.Gotham
    keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyButton.TextSize = 13
    keyButton.Parent = keyBox
    
    local pickingKey = false
    local currentKey = defaultKey
    
    keyButton.MouseButton1Click:Connect(function()
        pickingKey = true
        keyButton.Text = "Press any key..."
        keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    
    local keyConnection = UIS.InputBegan:Connect(function(input)
        if pickingKey then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyButton.Text = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                currentKey = input.UserInputType
                keyButton.Text = input.UserInputType.Name
            end
            
            keyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            pickingKey = false
            
            if callback then
                callback(currentKey)
            end
        end
    end)
    
    return {
        Set = function(key)
            currentKey = key
            keyButton.Text = tostring(key.Name or key)
        end,
        Get = function() return currentKey end,
        Destroy = function()
            if keyConnection then
                keyConnection:Disconnect()
            end
        end
    }
end

-- Setup keybinds
function MenuLib:SetupKeybinds()
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == self.Config.ToggleKey then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
end

-- Set toggle key
function MenuLib:SetToggleKey(key)
    self.Config.ToggleKey = key
end

-- Destroy the GUI
function MenuLib:Destroy()
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
        self.MainFrame = nil
        self.TabButtons = {}
        self.TabScrollFrames = {}
        self.Tabs = {}
    end
end

-- Toggle GUI visibility
function MenuLib:Toggle()
    if self.MainFrame then
        self.MainFrame.Visible = not self.MainFrame.Visible
    end
end

return MenuLib