local AimFunctions = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local aimbotEnabled = false
local aimPart = "Head"
local smoothness = 0.1
local aimKey = Enum.UserInputType.MouseButton2
local aimMethod = "Camera"

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local targetPart = character:FindFirstChild(aimPart)
                if targetPart then
                    local screenPoint, visible = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if visible then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                        
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

local function aimAt(target)
    if not target or not target.Character then return end
    
    local targetPart = target.Character:FindFirstChild(aimPart)
    if not targetPart then return end
    
    if aimMethod == "Camera" then

        local cameraCFrame = Camera.CFrame
        local targetPosition = targetPart.Position
        
        local newCFrame = CFrame.lookAt(cameraCFrame.Position, targetPosition)
        local smoothedCFrame = cameraCFrame:Lerp(newCFrame, smoothness)
        
        Camera.CFrame = smoothedCFrame
    else
        
        local screenPoint = Camera:WorldToViewportPoint(targetPart.Position)
        local mousePos = UserInputService:GetMouseLocation()
        
        local newMousePos = Vector2.new(
            mousePos.X + (screenPoint.X - mousePos.X) * smoothness,
            mousePos.Y + (screenPoint.Y - mousePos.Y) * smoothness
        )
        
        mousemoverel(newMousePos.X - mousePos.X, newMousePos.Y - mousePos.Y)
    end
end

local function onInputBegan(input)
    if not aimbotEnabled then return end
    
    if input.UserInputType == aimKey or (aimKey and input.KeyCode == aimKey) then
        local target = getClosestPlayer()
        if target then
            RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
                if aimbotEnabled then
                    aimAt(target)
                else
                    RunService:UnbindFromRenderStep("Aimbot")
                end
            end)
        end
    end
end

local function onInputEnded(input)
    if not aimbotEnabled then return end
    
    if input.UserInputType == aimKey or (aimKey and input.KeyCode == aimKey) then
        RunService:UnbindFromRenderStep("Aimbot")
    end
end

function AimFunctions.EnableAimbot(part, smooth, key, method)
    aimbotEnabled = true
    aimPart = part or "Head"
    smoothness = smooth or 0.1
    aimKey = key or Enum.UserInputType.MouseButton2
    aimMethod = method or "Camera"
    
    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputEnded:Connect(onInputEnded)
end

function AimFunctions.DisableAimbot()
    aimbotEnabled = false
    RunService:UnbindFromRenderStep("Aimbot")
end

function AimFunctions.UpdateAimPart(newPart)
    aimPart = newPart
end

function AimFunctions.UpdateSmoothness(newSmoothness)
    smoothness = newSmoothness
end

function AimFunctions.UpdateAimKey(newKey)
    aimKey = newKey
end

function AimFunctions.UpdateAimMethod(newMethod)
    aimMethod = newMethod
end

return AimFunctions
