-- SkillHub Unified Module
-- Combines enhanced Aimbot and ESP

local SkillHub = {}

-- =============================================
-- ENHANCED AIMBOT MODULE
-- =============================================
do
    local Aimbot = {}
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    Aimbot.Settings = {
        Enabled = false,
        FOV = 200,
        AimPart = "Head",
        VisibleCheck = false,
        WallCheck = false,
        TeamCheck = true,
        Smoothing = 0,
        Prediction = 0,
        Triggerbot = false,
        TriggerKey = Enum.KeyCode.E,
        AimKey = Enum.UserInputType.MouseButton2,
        FOVCircle = {
            Visible = true,
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.5,
            Thickness = 2,
            Filled = false
        },
        TargetLine = {
            Visible = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1
        }
    }

    Aimbot.currentTarget = nil
    Aimbot.targetPart = nil
    Aimbot.FOVCircle = Drawing.new("Circle")
    Aimbot.TargetLine = Drawing.new("Line")

    function Aimbot:init()
        self.FOVCircle.Visible = self.Settings.FOVCircle.Visible
        self.FOVCircle.Radius = self.Settings.FOV
        self.FOVCircle.Color = self.Settings.FOVCircle.Color
        self.FOVCircle.Transparency = self.Settings.FOVCircle.Transparency
        self.FOVCircle.Thickness = self.Settings.FOVCircle.Thickness
        self.FOVCircle.NumSides = 60
        self.FOVCircle.Filled = self.Settings.FOVCircle.Filled

        self.TargetLine.Visible = self.Settings.TargetLine.Visible
        self.TargetLine.Color = self.Settings.TargetLine.Color
        self.TargetLine.Thickness = self.Settings.TargetLine.Thickness
    end

    function Aimbot:isEnemy(player)
        if not player or player == LocalPlayer then return false end
        if not self.Settings.TeamCheck then return true end
        if not player.Team or not LocalPlayer.Team then return true end
        return player.Team ~= LocalPlayer.Team
    end

    function Aimbot:getTargetPart(character)
        if not character then return nil end
        local part = character:FindFirstChild(self.Settings.AimPart)
        if not part and self.Settings.AimPart == "Head" then
            part = character:FindFirstChild("Head")
        end
        if not part and self.Settings.AimPart == "HumanoidRootPart" then
            part = character:FindFirstChild("HumanoidRootPart")
        end
        if not part then
            part = character:FindFirstChildWhichIsA("BasePart")
        end
        return part
    end

    function Aimbot:isVisible(part)
        if not part or not self.Settings.VisibleCheck then return true end
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin).Unit
        local ray = Ray.new(origin, direction * (part.Position - origin).Magnitude)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        return hit == part
    end

    function Aimbot:canWallbang(part)
        if not part or not self.Settings.WallCheck then return true end
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin).Unit
        local ray = Ray.new(origin, direction * (part.Position - origin).Magnitude)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        return hit == part or hit == nil
    end

    function Aimbot:getPredictedPosition(part)
        if not part or self.Settings.Prediction <= 0 then return part.Position end
        local humanoid = part.Parent:FindFirstChild("Humanoid")
        if not humanoid then return part.Position end
        local velocity = humanoid.MoveDirection * humanoid.WalkSpeed
        return part.Position + velocity * self.Settings.Prediction
    end

    function Aimbot:getTarget()
        local mousePos = UserInputService:GetMouseLocation()
        local center = Vector2.new(mousePos.X, mousePos.Y)
        local bestTarget = nil
        local bestPart = nil
        local bestDist = self.Settings.FOV
        local bestScreenPos = nil

        for _, player in pairs(Players:GetPlayers()) do
            if self:isEnemy(player) and player.Character then
                local targetPart = self:getTargetPart(player.Character)
                local humanoid = player.Character:FindFirstChild("Humanoid")

                if targetPart and humanoid and humanoid.Health > 0 then
                    if not self:isVisible(targetPart) then continue end
                    if not self:canWallbang(targetPart) then continue end

                    local predictedPos = self:getPredictedPosition(targetPart)
                    local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)

                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist <= bestDist then
                            bestDist = dist
                            bestTarget = player
                            bestPart = targetPart
                            bestScreenPos = screenPos
                        end
                    end
                end
            end
        end

        return bestTarget, bestPart, bestScreenPos
    end

    function Aimbot:smoothAim(current, target)
        if self.Settings.Smoothing <= 0 then return target end
        local angle = math.acos(math.clamp(current:Dot(target), -1, 1))
        local maxAngle = math.rad(self.Settings.Smoothing)
        if angle <= maxAngle then return target end
        return current:Lerp(target, maxAngle / angle)
    end

    function Aimbot:update()
        local mousePos = UserInputService:GetMouseLocation()
        self.FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        self.FOVCircle.Radius = self.Settings.FOV
        self.FOVCircle.Visible = self.Settings.Enabled and self.Settings.FOVCircle.Visible
        self.TargetLine.Visible = self.Settings.Enabled and self.Settings.TargetLine.Visible and self.currentTarget

        if self.Settings.Enabled then
            local aiming = UserInputService:IsMouseButtonPressed(self.Settings.AimKey)
            local trigger = self.Settings.Triggerbot and UserInputService:IsKeyDown(self.Settings.TriggerKey)

            if aiming or trigger then
                local target, part, screenPos = self:getTarget()
                self.currentTarget = target
                self.targetPart = part

                if target and part then
                    if self.TargetLine.Visible then
                        self.TargetLine.From = Vector2.new(mousePos.X, mousePos.Y)
                        self.TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    end

                    if aiming then
                        local predictedPos = self:getPredictedPosition(part)
                        local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                        local smoothedCF = self:smoothAim(Camera.CFrame, targetCF)
                        Camera.CFrame = smoothedCF
                    end

                    if trigger then
                        mouse1click()
                    end

                    self.FOVCircle.Color = Color3.fromRGB(0, 255, 0)
                else
                    self.FOVCircle.Color = self.Settings.FOVCircle.Color
                end
            else
                self.currentTarget = nil
                self.targetPart = nil
                self.FOVCircle.Color = self.Settings.FOVCircle.Color
            end
        else
            self.currentTarget = nil
            self.targetPart = nil
        end
    end

    function Aimbot:setFOV(value)
        self.Settings.FOV = math.max(50, math.min(500, value))
    end

    function Aimbot:applySettings(newSettings)
        for k, v in pairs(newSettings) do
            if type(v) == "table" and self.Settings[k] and type(self.Settings[k]) == "table" then
                for subk, subv in pairs(v) do
                    pcall(function() self.Settings[k][subk] = subv end)
                end
            else
                pcall(function() self.Settings[k] = v end)
            end
        end
        pcall(function() self.FOVCircle.Color = self.Settings.FOVCircle.Color end)
        pcall(function() self.FOVCircle.Transparency = self.Settings.FOVCircle.Transparency end)
        pcall(function() self.FOVCircle.Thickness = self.Settings.FOVCircle.Thickness end)
        pcall(function() self.FOVCircle.Filled = self.Settings.FOVCircle.Filled end)
        pcall(function() self.TargetLine.Color = self.Settings.TargetLine.Color end)
        pcall(function() self.TargetLine.Thickness = self.Settings.TargetLine.Thickness end)
    end

    function Aimbot:cleanup()
        if self.FOVCircle then pcall(function() self.FOVCircle:Remove() end) end
        if self.TargetLine then pcall(function() self.TargetLine:Remove() end) end
    end

    SkillHub.Aimbot = Aimbot
end

-- =============================================
-- ENHANCED ESP MODULE
-- =============================================
do
    local ESP = {}
    ESP.ESPObjects = {}
    ESP.Settings = {
        Enabled = false,
        TeamCheck = true,
        MaxDistance = 1000,
        Box = {
            Enabled = true,
            Color = Color3.fromRGB(255, 0, 0),
            TeammateColor = Color3.fromRGB(0, 255, 0),
            Thickness = 1.4,
            Transparency = 1,
            Filled = false
        },
        Tracer = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            TeammateColor = Color3.fromRGB(255, 255, 255),
            Thickness = 1.4,
            Transparency = 1,
            From = "Bottom"
        },
        Name = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            TeammateColor = Color3.fromRGB(255, 255, 255),
            Size = 13,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0)
        },
        Health = {
            Enabled = false,
            Position = "Left",
            Color = Color3.fromRGB(0, 255, 0),
            LowColor = Color3.fromRGB(255, 0, 0),
            Size = 5,
            Transparency = 0.5
        },
        Distance = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            TeammateColor = Color3.fromRGB(255, 255, 255),
            Size = 11,
            Format = "%.1fm"
        }
    }

    local function createDrawing(type, props)
        local obj = Drawing.new(type)
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
        return obj
    end

    function ESP:isEnemy(player)
        if not player or player == LocalPlayer then return false end
        if not self.Settings.TeamCheck then return true end
        if not player.Team or not LocalPlayer.Team then return true end
        return player.Team ~= LocalPlayer.Team
    end

    function ESP:getPlayerColor(player, setting)
        local isEnemy = self:isEnemy(player)
        if setting == "Box" then
            return isEnemy and self.Settings.Box.Color or self.Settings.Box.TeammateColor
        elseif setting == "Tracer" then
            return isEnemy and self.Settings.Tracer.Color or self.Settings.Tracer.TeammateColor
        elseif setting == "Name" then
            return isEnemy and self.Settings.Name.Color or self.Settings.Name.TeammateColor
        elseif setting == "Distance" then
            return isEnemy and self.Settings.Distance.Color or self.Settings.Distance.TeammateColor
        end
        return Color3.fromRGB(255, 255, 255)
    end

    function ESP:createForPlayer(player)
        local obj = {}
        for i = 1, 12 do
            obj["line"..i] = createDrawing("Line", {
                Visible = false,
                Thickness = self.Settings.Box.Thickness,
                Transparency = self.Settings.Box.Transparency,
                Color = self:getPlayerColor(player, "Box")
            })
        end
        obj.Tracer = createDrawing("Line", {
            Visible = false,
            Thickness = self.Settings.Tracer.Thickness,
            Transparency = self.Settings.Tracer.Transparency,
            Color = self:getPlayerColor(player, "Tracer")
        })
        obj.Name = createDrawing("Text", {
            Visible = false,
            Text = player.Name,
            Size = self.Settings.Name.Size,
            Center = self.Settings.Name.Center,
            Outline = self.Settings.Name.Outline,
            OutlineColor = self.Settings.Name.OutlineColor,
            Color = self:getPlayerColor(player, "Name")
        })
        obj.Health = createDrawing("Line", {
            Visible = false,
            Thickness = self.Settings.Health.Size,
            Transparency = self.Settings.Health.Transparency
        })
        obj.HealthBg = createDrawing("Line", {
            Visible = false,
            Thickness = self.Settings.Health.Size,
            Transparency = 0.5,
            Color = Color3.fromRGB(30, 30, 30)
        })
        obj.Distance = createDrawing("Text", {
            Visible = false,
            Size = self.Settings.Distance.Size,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Color = self:getPlayerColor(player, "Distance")
        })
        ESP.ESPObjects[player] = obj
    end

    function ESP:updateBox(player, obj, humanoidRootPart, head)
        local scale = head.Size.Y / 2
        local size = Vector3.new(2, 3, 1.5) * (scale * 2)
        local cf = humanoidRootPart.CFrame
        local corners = {}
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local offset = Vector3.new(x * size.X, y * size.Y, z * size.Z) / 2
                    table.insert(corners, cf * offset)
                end
            end
        end
        local screenCorners = {}
        for i, corner in ipairs(corners) do
            local pos = Camera:WorldToViewportPoint(corner)
            screenCorners[i] = Vector2.new(pos.X, pos.Y)
        end
        local edges = {
            {1,2}, {2,4}, {4,3}, {3,1},
            {5,6}, {6,8}, {8,7}, {7,5},
            {1,5}, {2,6}, {4,8}, {3,7}
        }
        local color = self:getPlayerColor(player, "Box")
        for i, edge in ipairs(edges) do
            local line = obj["line"..i]
            if line then
                line.From = screenCorners[edge[1]]
                line.To = screenCorners[edge[2]]
                line.Visible = self.Settings.Box.Enabled
                line.Color = color
            end
        end
    end

    function ESP:updateTracer(player, obj, rootPos)
        if not self.Settings.Tracer.Enabled then
            obj.Tracer.Visible = false
            return
        end
        local mousePos = UserInputService:GetMouseLocation()
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
        if not onScreen then
            obj.Tracer.Visible = false
            return
        end
        local fromPos
        if self.Settings.Tracer.From == "Bottom" then
            fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif self.Settings.Tracer.From == "Center" then
            fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else
            fromPos = Vector2.new(mousePos.X, mousePos.Y)
        end
        obj.Tracer.From = fromPos
        obj.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        obj.Tracer.Visible = true
        obj.Tracer.Color = self:getPlayerColor(player, "Tracer")
    end

    function ESP:updateHealthBar(player, obj, head, rootPos)
        if not self.Settings.Health.Enabled then
            obj.Health.Visible = false
            obj.HealthBg.Visible = false
            return
        end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local screenHead = Camera:WorldToViewportPoint(head.Position)
        local screenRoot = Camera:WorldToViewportPoint(rootPos)
        local headPos = Vector2.new(screenHead.X, screenHead.Y)
        local rootPos2 = Vector2.new(screenRoot.X, screenRoot.Y)
        local height = (headPos.Y - rootPos2.Y) * 0.8
        local width = self.Settings.Health.Size
        local barStart
        if self.Settings.Health.Position == "Left" then
            barStart = Vector2.new(rootPos2.X - 30, rootPos2.Y)
        elseif self.Settings.Health.Position == "Right" then
            barStart = Vector2.new(rootPos2.X + 30, rootPos2.Y)
        elseif self.Settings.Health.Position == "Top" then
            barStart = Vector2.new(rootPos2.X, rootPos2.Y - height - 10)
        elseif self.Settings.Health.Position == "Bottom" then
            barStart = Vector2.new(rootPos2.X, rootPos2.Y + 10)
        else
            barStart = Vector2.new(rootPos2.X - 10, rootPos2.Y)
        end
        obj.HealthBg.From = barStart
        obj.HealthBg.To = Vector2.new(barStart.X, barStart.Y - height)
        obj.HealthBg.Visible = true
        obj.Health.From = barStart
        obj.Health.To = Vector2.new(barStart.X, barStart.Y - height * healthPercent)
        obj.Health.Color = self.Settings.Health.Color:Lerp(self.Settings.Health.LowColor, 1 - healthPercent)
        obj.Health.Visible = true
    end

    function ESP:updateName(player, obj, head)
        if not self.Settings.Name.Enabled then
            obj.Name.Visible = false
            return
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
        if onScreen then
            obj.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
            obj.Name.Text = player.Name
            obj.Name.Color = self:getPlayerColor(player, "Name")
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end
    end

    function ESP:updateDistance(player, obj, rootPos)
        if not self.Settings.Distance.Enabled then
            obj.Distance.Visible = false
            return
        end
        local dist = (Camera.CFrame.Position - rootPos).Magnitude
        if dist > self.Settings.MaxDistance then
            obj.Distance.Visible = false
            return
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
        if onScreen then
            obj.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
            obj.Distance.Text = string.format(self.Settings.Distance.Format, dist)
            obj.Distance.Color = self:getPlayerColor(player, "Distance")
            obj.Distance.Visible = true
        else
            obj.Distance.Visible = false
        end
    end

    function ESP:update()
        for player, obj in pairs(ESP.ESPObjects) do
            if ESP.Settings.Enabled and player and player.Character and player.Character:FindFirstChild("Humanoid") and 
               player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
                local humanoid = player.Character.Humanoid
                local rootPart = player.Character.HumanoidRootPart
                local head = player.Character.Head
                if humanoid.Health > 0 then
                    local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
                    if dist <= ESP.Settings.MaxDistance then
                        ESP:updateBox(player, obj, rootPart, head)
                        ESP:updateTracer(player, obj, rootPart.Position)
                        ESP:updateName(player, obj, head)
                        ESP:updateHealthBar(player, obj, head, rootPart.Position)
                        ESP:updateDistance(player, obj, rootPart.Position)
                    else
                        for _, drawing in pairs(obj) do drawing.Visible = false end
                    end
                else
                    for _, drawing in pairs(obj) do drawing.Visible = false end
                end
            else
                for _, drawing in pairs(obj) do drawing.Visible = false end
            end
        end
    end

    function ESP:removeForPlayer(player)
        if ESP.ESPObjects[player] then
            for _, drawing in pairs(ESP.ESPObjects[player]) do
                pcall(function() drawing:Remove() end)
            end
            ESP.ESPObjects[player] = nil
        end
    end

    function ESP:applySettings(newSettings)
        for k, v in pairs(newSettings) do
            if type(v) == "table" and self.Settings[k] and type(self.Settings[k]) == "table" then
                for subk, subv in pairs(v) do
                    pcall(function() self.Settings[k][subk] = subv end)
                end
            else
                pcall(function() self.Settings[k] = v end)
            end
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

    SkillHub.ESP = ESP
end

return SkillHub
