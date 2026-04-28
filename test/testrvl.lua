local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ClickInterval = 0.001
local isRunning = true
local enabled = true

local targetPlayer = nil
local isRightMouseDown = false
local lastClickTime = 0

local connections = {}

local function setupCharacter()
	local character = localPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.AutoRotate = false
		end
	end
end

local function resetCharacter()
	local character = localPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.AutoRotate = true
		end
	end
end

local function isLobbyVisible()
	return localPlayer.PlayerGui:FindFirstChild("MainGui") and
		localPlayer.PlayerGui.MainGui:FindFirstChild("MainFrame") and
		localPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible == true
end

local function getClosestPlayerToMouse()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local mousePosition = UserInputService:GetMouseLocation()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)

			if onScreen then
				local screenPosition = Vector2.new(headPosition.X, headPosition.Y)
				local distance = (screenPosition - mousePosition).Magnitude

				if distance < shortestDistance then
					closestPlayer = player
					shortestDistance = distance
				end
			end
		end
	end

	return closestPlayer
end

local function lockCameraToHead()
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
		local head = targetPlayer.Character.Head
		local headPosition = camera:WorldToViewportPoint(head.Position)
		if headPosition.Z > 0 then
			local cameraPosition = camera.CFrame.Position
			camera.CFrame = CFrame.new(cameraPosition, head.Position)
		end
	end
end

localPlayer.CharacterAdded:Connect(setupCharacter)
if localPlayer.Character then
	setupCharacter()
end

local mainLoop = RunService.Heartbeat:Connect(function()
	if not isRunning then return end

	if enabled and isRightMouseDown and not isLobbyVisible() then
		targetPlayer = getClosestPlayerToMouse()
		if targetPlayer then
			lockCameraToHead()
		end

		local now = tick()
		if now - lastClickTime >= ClickInterval then
			mouse1click()
			lastClickTime = now
		end
	end
end)
table.insert(connections, mainLoop)

local inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.P then
		enabled = not enabled
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = true
		lastClickTime = 0
	elseif input.KeyCode == Enum.KeyCode.End then
		isRunning = false
		resetCharacter()
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		connections = {}
		targetPlayer = nil
	end
end)
table.insert(connections, inputBegan)

local inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = false
	end
end)
table.insert(connections, inputEnded)
