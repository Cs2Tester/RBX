-- aimbot.lua
local Aimbot = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

Aimbot.Settings = {
    Enabled = false,
    FOV = 200
}

Aimbot.currentTarget = nil
Aimbot.FOVCircle = Drawing.new("Circle")

function Aimbot:init()
    Aimbot.FOVCircle.Visible = true
    Aimbot.FOVCircle.Radius = Aimbot.Settings.FOV
    Aimbot.FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    Aimbot.FOVCircle.Transparency = 0.5
    Aimbot.FOVCircle.Thickness = 2
    Aimbot.FOVCircle.NumSides = 60
    Aimbot.FOVCircle.Filled = false
end

function Aimbot:isEnemy(player)
    if not player or player == LocalPlayer then return false end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

function Aimbot:getTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local center = Vector2.new(mousePos.X, mousePos.Y)
    local bestTarget = nil
    local bestDist = Aimbot.Settings.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Aimbot:isEnemy(player) and player.Character then
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

function Aimbot:update()
    if not Aimbot.Settings.Enabled then 
        Aimbot.currentTarget = nil
        return 
    end
    
    local mousePos = UserInputService:GetMouseLocation()
    Aimbot.FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    Aimbot.FOVCircle.Radius = Aimbot.Settings.FOV
    Aimbot.FOVCircle.Visible = Aimbot.Settings.Enabled
    
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = Aimbot:getTarget()
        Aimbot.currentTarget = target
        
        if target and target.Character and target.Character.Head then
            local head = target.Character.Head
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    else
        Aimbot.currentTarget = nil
    end
    
    if Aimbot.currentTarget then
        Aimbot.FOVCircle.Color = Color3.fromRGB(0, 255, 0)
    else
        Aimbot.FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    end
end

function Aimbot:setFOV(value)
    Aimbot.Settings.FOV = math.max(50, math.min(500, value))
end

function Aimbot:cleanup()
    if Aimbot.FOVCircle then
        pcall(function() Aimbot.FOVCircle:Remove() end)
    end
end

return Aimbot
