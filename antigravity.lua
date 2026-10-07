local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

local enabled = false
local lockedY = nil -- Sabitlenecek yükseklik

-- --- UI OLUŞTURMA ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiGravityGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = pgui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 160, 0, 45)

-- Ekranın Tam Ortasında Başlatma
toggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
toggleBtn.Position = UDim2.new(0.5, 0, 0.5, 0)

toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Anti Gravity: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(225, 75, 75)
toggleBtn.TextSize = 15
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = toggleBtn

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(225, 75, 75)
stroke.Thickness = 2
stroke.Parent = toggleBtn

-- --- DRAGGABLE (SÜRÜKLE BIRAK) SİSTEMİ ---
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	toggleBtn.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

toggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = toggleBtn.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

toggleBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- --- DURUM GÜNCELLEME VE YÜKSEKLİK KİLİTLEME ---
local function toggleState()
	enabled = not enabled
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if enabled then
		toggleBtn.Text = "Anti Gravity: ON"
		toggleBtn.TextColor3 = Color3.fromRGB(75, 225, 125)
		stroke.Color = Color3.fromRGB(75, 225, 125)
		
		-- Açıldığı andaki Y yüksekliğini kaydet
		if hrp then
			lockedY = hrp.Position.Y
		end
	else
		toggleBtn.Text = "Anti Gravity: OFF"
		toggleBtn.TextColor3 = Color3.fromRGB(225, 75, 75)
		stroke.Color = Color3.fromRGB(225, 75, 75)
		lockedY = nil
	end
end

toggleBtn.MouseButton1Click:Connect(toggleState)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		toggleState()
	end
end)

-- --- KESİN YÜKSEKLİK VE FİZİK KİLİTLEME DÖNGÜSÜ ---
RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if hrp and humanoid and enabled then
		-- Yüksekliği henüz almadıysa güncelle
		if not lockedY then
			lockedY = hrp.Position.Y
		end
		
		-- Dikey hızı (Y) tamamen sıfırla
		local currentVel = hrp.AssemblyLinearVelocity
		hrp.AssemblyLinearVelocity = Vector3.new(currentVel.X, 0, currentVel.Z)
		
		-- Karakter yukarı kalktıysa anında kayıtlı Y yüksekliğine geri çek
		if hrp.Position.Y > lockedY then
			hrp.CFrame = CFrame.new(hrp.Position.X, lockedY, hrp.Position.Z) * hrp.CFrame.Rotation
		elseif hrp.Position.Y < lockedY - 2 then
			-- Aşağı düşerse (çukura girerse) yeni yüksekliği güncelle
			lockedY = hrp.Position.Y
		end
		
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	elseif humanoid and not enabled then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end)
