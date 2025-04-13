local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UI untuk player sendiri (sudah akurat)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HealthUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local background = Instance.new("Frame")
background.Name = "HealthBarBackground"
background.Parent = screenGui
background.AnchorPoint = Vector2.new(0, 1)
background.Position = UDim2.new(0.02, 0, 0.97, 0)
background.Size = UDim2.new(0.12, 0, 0.04, 0) -- 2x height
background.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
background.BorderSizePixel = 0

local fill = Instance.new("Frame")
fill.Name = "HealthBarFill"
fill.Parent = background
fill.Size = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fill.BorderSizePixel = 0

local label = Instance.new("TextLabel")
label.Parent = background
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.Arcade
label.TextScaled = true
label.Text = "100/100"

-- Player sendiri
local healthConnection
local function setupCharacter(char)
	local humanoid = char:WaitForChild("Humanoid", 5)
	if humanoid then
		if healthConnection then healthConnection:Disconnect() end
		local function onHealthChanged(health)
			local maxHealth = humanoid.MaxHealth
			local percent = math.clamp(health / maxHealth, 0, 1)
			fill.Size = UDim2.new(percent, 0, 1, 0)
			label.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
		end
		healthConnection = humanoid.HealthChanged:Connect(onHealthChanged)
		onHealthChanged(humanoid.Health)
	end
end
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- ESP Friendly Healthbar (untuk yang dekat saja)
local function createHealthBarForPlayer(player)
	if player == LocalPlayer then return end

	local function onCharacterAdded(char)
		local head = char:WaitForChild("Head", 5)
		local humanoid = char:WaitForChild("Humanoid", 5)
		if not head or not humanoid then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "HealthESP"
		billboard.Adornee = head
		billboard.Parent = head
		billboard.Size = UDim2.new(4, 0, 0.6, 0) -- Lebih besar
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = false -- Biar realistis
		billboard.MaxDistance = 40 -- Hanya terlihat jika dekat

		local bg = Instance.new("Frame")
		bg.Parent = billboard
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		bg.BorderSizePixel = 0

		local bar = Instance.new("Frame")
		bar.Name = "HealthFill"
		bar.Parent = bg
		bar.Size = UDim2.new(1, 0, 1, 0)
		bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		bar.BorderSizePixel = 0

		local healthText = Instance.new("TextLabel")
		healthText.Parent = bg
		healthText.Size = UDim2.new(1, 0, 1, 0)
		healthText.BackgroundTransparency = 1
		healthText.TextColor3 = Color3.new(1, 1, 1)
		healthText.TextStrokeTransparency = 0.5
		healthText.TextStrokeColor3 = Color3.new(0, 0, 0)
		healthText.Font = Enum.Font.Arcade
		healthText.TextScaled = true

		local function updateHealth()
			local hp = humanoid.Health
			local maxHp = humanoid.MaxHealth
			local ratio = math.clamp(hp / maxHp, 0, 1)
			bar.Size = UDim2.new(ratio, 0, 1, 0)
			healthText.Text = math.floor(hp) .. "/" .. math.floor(maxHp)
			if ratio > 0.5 then
				bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			elseif ratio > 0.25 then
				bar.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
			else
				bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			end
		end

		humanoid:GetPropertyChangedSignal("Health"):Connect(updateHealth)
		humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)
		updateHealth()

		-- Hanya tampilkan kalau dekat
		RunService.RenderStepped:Connect(function()
			if not billboard or not billboard.Parent then return end
			local distance = (Camera.CFrame.Position - head.Position).Magnitude
			billboard.Enabled = distance < 40
		end)
	end

	if player.Character then onCharacterAdded(player.Character) end
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- Pasang ke semua player
for _, p in ipairs(Players:GetPlayers()) do
	createHealthBarForPlayer(p)
end
Players.PlayerAdded:Connect(createHealthBarForPlayer)
