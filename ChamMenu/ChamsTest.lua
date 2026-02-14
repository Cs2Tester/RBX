local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function processPlayer(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    task.spawn(function()
        task.wait(0.5)
        
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Clothing") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                item:Destroy()
            end
        end
        
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Plastic
                part.Color = Color3.fromRGB(180, 0, 255)
                part.Transparency = 0.2
                part.Reflectance = 0.3
            end
        end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(180, 0, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        highlight.Enabled = true
        highlight.Parent = character
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 5
        pointLight.Range = 15
        pointLight.Color = Color3.fromRGB(180, 0, 255)
        pointLight.Shadows = false
        pointLight.Parent = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        
        local surfaceLight = Instance.new("SurfaceLight")
        surfaceLight.Brightness = 3
        surfaceLight.Range = 12
        surfaceLight.Color = Color3.fromRGB(180, 0, 255)
        surfaceLight.Face = Enum.NormalId.Top
        surfaceLight.Angle = 180
        surfaceLight.Parent = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            processPlayer(player)
        end
        
        player.CharacterAdded:Connect(function()
            processPlayer(player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            processPlayer(player)
        end)
    end
end)
