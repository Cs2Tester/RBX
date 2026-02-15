-- esp.lua
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

ESP.ESPObjects = {}
ESP.Settings = {
    Enabled = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 0, 0),
    TeamCheck = true
}

local red = Color3.fromRGB(227, 52, 52)
local green = Color3.fromRGB(88, 217, 24)

local function NewLine(color, thickness)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(1, 1)
    line.Color = color or ESP.Settings.BoxColor
    line.Thickness = thickness or 1.4
    line.Transparency = 1
    return line
end

function ESP:isEnemy(player)
    if not player or player == LocalPlayer then return false end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

function ESP:createForPlayer(player)
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
        Tracer = NewLine(ESP.Settings.TracerColor, 1.4)
    }
    ESP.ESPObjects[player] = lines
end

function ESP:update()
    for player, lines in pairs(ESP.ESPObjects) do
        if ESP.Settings.Enabled and player and player.Character and player.Character:FindFirstChild("Humanoid") and 
           player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") and 
           player.Character.Humanoid.Health > 0 then
            
            local pos, vis = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if vis then
                local Scale = player.Character.Head.Size.Y/2
                local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

                local Top1 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                local Top2 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                local Top3 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                local Top4 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)

                local Bottom1 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                local Bottom2 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                local Bottom3 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                local Bottom4 = Camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

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

                if ESP.Settings.TeamCheck then
                    local targetColor = ESP:isEnemy(player) and red or green
                    for u, x in pairs(lines) do
                        if x ~= lines.Tracer then
                            x.Color = targetColor
                        end
                    end
                end

                for u, x in pairs(lines) do
                    if x ~= lines.Tracer then
                        x.Visible = true
                    end
                end
            else
                for u, x in pairs(lines) do
                    x.Visible = false
                end
            end
        else
            for u, x in pairs(lines) do
                x.Visible = false
            end
        end
    end
end

function ESP:removeForPlayer(player)
    if ESP.ESPObjects[player] then
        for _, line in pairs(ESP.ESPObjects[player]) do
            pcall(function() line:Remove() end)
        end
        ESP.ESPObjects[player] = nil
    end
end

function ESP:init()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP:createForPlayer(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            ESP:createForPlayer(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ESP:removeForPlayer(player)
    end)
    
    RunService.RenderStepped:Connect(function()
        ESP:update()
    end)
end

return ESP
