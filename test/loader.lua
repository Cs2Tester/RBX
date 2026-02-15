local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/Cs2Tester/RBX/refs/heads/main/test/main.lua"

local player = game:GetService("Players").LocalPlayer
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlutoRIVALS_Loader"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = (game:GetService("CoreGui") or player:WaitForChild("PlayerGui"))

local background = Instance.new("Frame")
background.Name = "Background"
background.Parent = screenGui
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0.5
background.Size = UDim2.new(1, 0, 1, 0)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = background
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 300, 0, 150)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.BorderSizePixel = 0
title.Size = UDim2.new(1, 0, 0, 40)
title.Font = Enum.Font.Gotham
title.Text = "PlutoRIVALS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Parent = mainFrame
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 0, 0, 45)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Loading..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 14

local loadingBarContainer = Instance.new("Frame")
loadingBarContainer.Name = "LoadingBarContainer"
loadingBarContainer.Parent = mainFrame
loadingBarContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
loadingBarContainer.BorderSizePixel = 0
loadingBarContainer.Position = UDim2.new(0.1, 0, 0, 90)
loadingBarContainer.Size = UDim2.new(0.8, 0, 0, 10)

local loadingBar = Instance.new("Frame")
loadingBar.Name = "LoadingBar"
loadingBar.Parent = loadingBarContainer
loadingBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
loadingBar.BorderSizePixel = 0
loadingBar.Size = UDim2.new(0, 0, 1, 0)

local spinner = Instance.new("ImageLabel")
spinner.Name = "Spinner"
spinner.Parent = mainFrame
spinner.BackgroundTransparency = 1
spinner.Position = UDim2.new(0.5, -15, 0, 110)
spinner.Size = UDim2.new(0, 30, 0, 30)
spinner.Image = "rbxasset://textures/ui/Loading/loadingCircle.png"
spinner.ImageColor3 = Color3.fromRGB(255, 255, 255)
spinner.ImageTransparency = 0.3

local spinConnection
spinConnection = runService.RenderStepped:Connect(function(dt)
    spinner.Rotation = spinner.Rotation + (dt * 180)
end)

local tween = tweenService:Create(loadingBar, TweenInfo.new(2, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
tween:Play()
tween.Completed:Wait()

spinConnection:Disconnect()
screenGui:Destroy()

loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
