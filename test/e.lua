-- Enhanced ESP with full configuration support
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
        From = "Bottom" -- "Bottom", "Mouse", "Center"
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
        Position = "Left", -- "Left", "Right", "Top", "Bottom", "Bar"
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

-- Helper function to create drawing objects
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
    -- Box lines (12 lines for 3D box)
    for i = 1, 12 do
        obj["line"..i] = createDrawing("Line", {
            Visible = false,
            Thickness = self.Settings.Box.Thickness,
            Transparency = self.Settings.Box.Transparency,
            Color = self:getPlayerColor(player, "Box")
        })
    end
    -- Tracer
    obj.Tracer = createDrawing("Line", {
        Visible = false,
        Thickness = self.Settings.Tracer.Thickness,
        Transparency = self.Settings.Tracer.Transparency,
        Color = self:getPlayerColor(player, "Tracer")
    })
    -- Name text
    obj.Name = createDrawing("Text", {
        Visible = false,
        Text = player.Name,
        Size = self.Settings.Name.Size,
        Center = self.Settings.Name.Center,
        Outline = self.Settings.Name.Outline,
        OutlineColor = self.Settings.Name.OutlineColor,
        Color = self:getPlayerColor(player, "Name")
    })
    -- Health bar (using multiple lines)
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
    -- Distance text
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

function ESP:updateBox(player, obj, humanoidRootPart, head, humanoid)
    local scale = head.Size.Y / 2
    local size = Vector3.new(2, 3, 1.5) * (scale * 2)
    local cf = humanoidRootPart.CFrame

    -- Get 8 corners of the bounding box
    local corners = {}
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local offset = Vector3.new(x * size.X, y * size.Y, z * size.Z) / 2
                table.insert(corners, cf * offset)
            end
        end
    end

    -- Project corners to screen
    local screenCorners = {}
    for i, corner in ipairs(corners) do
        local pos, vis = Camera:WorldToViewportPoint(corner)
        screenCorners[i] = Vector2.new(pos.X, pos.Y)
    end

    -- Define edges (12 edges of a cube)
    local edges = {
        {1,2}, {2,4}, {4,3}, {3,1}, -- top face
        {5,6}, {6,8}, {8,7}, {7,5}, -- bottom face
        {1,5}, {2,6}, {4,8}, {3,7}  -- vertical edges
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
    else -- Mouse
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

    local barStart, barEnd
    if self.Settings.Health.Position == "Left" then
        barStart = Vector2.new(rootPos2.X - 30, rootPos2.Y)
        barEnd = Vector2.new(rootPos2.X - 30, rootPos2.Y - height)
    elseif self.Settings.Health.Position == "Right" then
        barStart = Vector2.new(rootPos2.X + 30, rootPos2.Y)
        barEnd = Vector2.new(rootPos2.X + 30, rootPos2.Y - height)
    elseif self.Settings.Health.Position == "Top" then
        barStart = Vector2.new(rootPos2.X, rootPos2.Y - height - 10)
        barEnd = Vector2.new(rootPos2.X + width, rootPos2.Y - height - 10)
    elseif self.Settings.Health.Position == "Bottom" then
        barStart = Vector2.new(rootPos2.X, rootPos2.Y + 10)
        barEnd = Vector2.new(rootPos2.X + width, rootPos2.Y + 10)
    else -- Bar (health bar as part of box) - use left side
        barStart = Vector2.new(rootPos2.X - 10, rootPos2.Y)
        barEnd = Vector2.new(rootPos2.X - 10, rootPos2.Y - height * healthPercent)
    end

    -- Background
    obj.HealthBg.From = barStart
    obj.HealthBg.To = Vector2.new(barStart.X, barStart.Y - height)
    obj.HealthBg.Visible = true

    -- Health
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
                    -- Update all ESP elements
                    ESP:updateBox(player, obj, rootPart, head, humanoid)
                    ESP:updateTracer(player, obj, rootPart.Position)
                    ESP:updateName(player, obj, head)
                    ESP:updateHealthBar(player, obj, head, rootPart.Position)
                    ESP:updateDistance(player, obj, rootPart.Position)
                else
                    -- Hide all if out of range
                    for _, drawing in pairs(obj) do
                        drawing.Visible = false
                    end
                end
            else
                -- Hide if dead
                for _, drawing in pairs(obj) do
                    drawing.Visible = false
                end
            end
        else
            -- Hide if player invalid
            for _, drawing in pairs(obj) do
                drawing.Visible = false
            end
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
    -- Update existing objects with new colors/styles on next update
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
