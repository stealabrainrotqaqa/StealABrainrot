-- ============================================================
--  CANDY HUB: AIMBOT (SAĞ ÜST - KÜÇÜK & SÜRÜKLENEBİLİR) + INSTA AUTO GRAB
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- Eski kalıntıları temizle
pcall(function()
	if CoreGui:FindFirstChild("CandyAimbotMobileButton") then
		CoreGui.CandyAimbotMobileButton:Destroy()
	end
end)

-- Ayarlar ve Durumlar
local aimbotSpeed = 58
local autoBatEnabled = false
local autoSwingEnabled = true
local Conns = {aimbot = nil, autoGrab = nil}

-- ProximityPrompt tabanlı Auto Grab (Radius 10) Yapılandırması
local CONFIG = {
	AUTO_STEAL_ENABLED = true, -- Arka planda butonsuz otomatik çalışır
	STEAL_RANGE = 10,
	PRIME_RANGE = 40
}

-- Delta Uyumlu Ekran ve Sağ Üst Sürüklenebilir Buton
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CandyAimbotMobileButton"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true

pcall(function()
	if syn and syn.protect_gui then
		syn.protect_gui(screenGui)
		screenGui.Parent = CoreGui
	elseif gethui then
		screenGui.Parent = gethui()
	else
		screenGui.Parent = CoreGui
	end
end)
if not screenGui.Parent then
	screenGui.Parent = LP:WaitForChild("PlayerGui")
end

-- Sağ üst köşede küçük, şık ve sürüklenebilir AIM Butonu
local btn = Instance.new("TextButton", screenGui)
btn.Size = UDim2.new(0, 48, 0, 48)
btn.Position = UDim2.new(1, -65, 0, 20) -- Sağ üst köşe
btn.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
btn.Text = "AIM"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBlack
btn.TextSize = 11
btn.AutoButtonColor = false
btn.Active = true
btn.Draggable = true -- İstediğin yere taşıyabilirsin

local corner = Instance.new("UICorner", btn)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", btn)
stroke.Color = Color3.fromRGB(255, 92, 181)
stroke.Thickness = 1.5

-- ============================================================
--  1. INSTA AUTO GRAB (PROXIMITY PROMPT ANINDA TETİKLEME)
-- ============================================================
local function startInstaAutoGrab()
	if Conns.autoGrab then return end
	Conns.autoGrab = RunService.Heartbeat:Connect(function()
		if not CONFIG.AUTO_STEAL_ENABLED then return end
		local char = LP.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- Oyun içindeki tüm ProximityPrompt'ları tara (Radius 10 içinde olanları anında tetikle)
		for _, desc in ipairs(workspace:GetDescendants()) do
			if desc:IsA("ProximityPrompt") then
				local parentPart = desc.Parent
				if parentPart and parentPart:IsA("BasePart") then
					local dist = (parentPart.Position - hrp.Position).Magnitude
					if dist <= CONFIG.STEAL_RANGE then
						-- Beklemeden anında (insta) tetikle
						pcall(function()
							fireproximityprompt(desc, 0) -- Delta / Synapse destekli hızlı tetikleme
						end)
						pcall(function()
							desc:InputHoldBegin()
							desc:InputHoldEnd()
						end)
					end
				end
			end
		end
	end)
end

-- Otomatik başlat
startInstaAutoGrab()

-- ============================================================
--  2. AIMBOT MANTIĞI
-- ============================================================
local _aimbotTarget = nil
local _aimbotTargetPlr = nil

local function findBat()
	local char = LP.Character
	if not char then return nil end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
	end
	local bp = LP:FindFirstChild("Backpack")
	if bp then
		for _, tool in ipairs(bp:GetChildren()) do
			if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
		end
	end
	return nil
end

local function getClosestTarget()
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil, nil end
	local closest, closestPlr, minDist = nil, nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and hum and hum.Health > 0 then
				local dist = (tRoot.Position - root.Position).Magnitude
				if dist < minDist then
					minDist = dist
					closest = tRoot
					closestPlr = plr
				end
			end
		end
	end
	return closest, closestPlr, minDist
end

local function getStickyTarget(currentRoot)
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil, nil end
	local newClosest, newPlr, newDist = getClosestTarget()
	if not newClosest then return nil, nil end
	if currentRoot and currentRoot.Parent then
		local currentPlr = Players:GetPlayerFromCharacter(currentRoot.Parent)
		local hum = currentRoot.Parent:FindFirstChildOfClass("Humanoid")
		if currentPlr and hum and hum.Health > 0 then
			local currentDist = (currentRoot.Position - root.Position).Magnitude
			if currentPlr == newPlr or newDist > currentDist * 0.7 then
				return currentRoot, currentPlr
			end
		end
	end
	return newClosest, newPlr
end

local function swingCurrentBat(char)
	if not autoSwingEnabled then return end
	local bat = findBat()
	if bat and bat.Parent == char and bat:IsA("Tool") then
		pcall(function() bat:Activate() end)
	end
end

local function startBatAimbot()
	if Conns.aimbot then Conns.aimbot:Disconnect() end
	autoBatEnabled = true

	local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum0 then hum0.AutoRotate = false end

	Conns.aimbot = RunService.RenderStepped:Connect(function()
		if not autoBatEnabled then return end
		local char = LP.Character; if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
		local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end

		if not char:FindFirstChildOfClass("Tool") then
			local bat = findBat()
			if bat then pcall(function() hum:EquipTool(bat) end) end
		end

		local target, targetPlr = getStickyTarget(_aimbotTarget)
		if not target then 
			_aimbotTarget = nil; _aimbotTargetPlr = nil
			swingCurrentBat(char); return 
		end
		_aimbotTarget = target
		_aimbotTargetPlr = targetPlr

		local targetVel = target.Velocity
		local myPos = root.Position
		local targetPos = target.Position
		local distance = (targetPos - myPos).Magnitude

		local speedFactor = math.clamp(targetVel.Magnitude / 40, 0, 1.2)
		local distFactor = math.clamp(distance / 80, 0, 1)
		local leadTime = 0.14 + speedFactor * 0.12 + distFactor * 0.08
		local predictPos = targetPos + targetVel * leadTime
		predictPos = predictPos + target.CFrame.LookVector * 0.3

		local direction = predictPos - myPos
		local flatDir = Vector3.new(direction.X, 0, direction.Z)
		if flatDir.Magnitude > 0.01 then flatDir = flatDir.Unit else flatDir = Vector3.new(0, 0, 0) end

		local chaseSpeed = aimbotSpeed
		local jumpOffset = math.max(0, targetVel.Y * 0.18)
		local desiredHeight = targetPos.Y + 3.7 + jumpOffset
		local yVel = (desiredHeight - myPos.Y) * 22 + targetVel.Y * 1.1
		if hum.FloorMaterial ~= Enum.Material.Air then
			yVel = math.max(yVel, 13)
		end
		yVel = math.clamp(yVel, -70, 135)

		local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
		root.Velocity = root.Velocity:Lerp(desiredVel, 0.85)

		local rotPredictTime = math.clamp(targetVel.Magnitude / 120, 0.05, 0.25)
		local predictedPos = targetPos + targetVel * rotPredictTime
		local toPredict = predictedPos - myPos
		if toPredict.Magnitude > 0.1 then
			local goalCF = CFrame.lookAt(myPos, predictedPos)
			local diffCF = root.CFrame:Inverse() * goalCF
			local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
			rx = math.clamp(rx, -2.5, 2.5)
			ry = math.clamp(ry, -2.5, 2.5)
			rz = math.clamp(rz, -2.5, 2.5)
			root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 50, ry * 50, rz * 50))
		end

		swingCurrentBat(char)
	end)
end

local function stopBatAimbot()
	if Conns.aimbot then Conns.aimbot:Disconnect(); Conns.aimbot = nil end
	_aimbotTarget = nil
	_aimbotTargetPlr = nil
	autoBatEnabled = false
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then root.Velocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
	local hum2 = char and char:FindFirstChildOfClass("Humanoid")
	if hum2 then hum2.AutoRotate = true end
end

-- Sağ üstteki AIM butonuna basınca aç/kapat
btn.MouseButton1Click:Connect(function()
	if not autoBatEnabled then
		startBatAimbot()
		stroke.Color = Color3.fromRGB(0, 180, 255) -- Aktif (Mavi)
		btn.BackgroundColor3 = Color3.fromRGB(15, 25, 40)
	else
		stopBatAimbot()
		stroke.Color = Color3.fromRGB(255, 92, 181) -- Kapalı (Pembe)
		btn.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
	end
end)

print("[Candy Hub] Sağ üst aimbot butonu ve arkada çalışan 10 yarıçaplı Insta Auto Grab aktif!")
