-- ============================================================
--  AIMBOT & AUTO GRAB (RADIUS 9-10) AYARLARI
-- ============================================================

-- Aimbot temel hız ve durum değişkenleri
local aimbotSpeed = 58  
local autoBatEnabled = false
local autoSwingEnabled = true
local State = {
	AutoBat=false,
	BatAimbot=false
}

-- Auto Steal (Auto Grab) Konfigürasyonu (Radius 9-10 olarak ayarlandı)
CONFIG = {
	AUTO_STEAL_ENABLED=false,
	HOLD_MIN=1.3,
	HOLD_MAX=2.6,
	ENTRY_DELAY=0.3,
	COOLDOWN=0.05,
	STEAL_RANGE=10, -- İstediğin gibi 9-10 aralığına (10 olarak) ayarlandı
	PRIME_RANGE=80
}

local _aimbotTarget = nil
local _aimbotTargetPlr = nil

-- Bat / Aimbot Bulma ve Hedefleme Fonksiyonları
local function findBat()
	local char=LP.Character
	if not char then return nil end
	for _,tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
	end
	local bp=LP:FindFirstChild("Backpack")
	if bp then
		for _,tool in ipairs(bp:GetChildren()) do
			if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
		end
	end
	return nil
end

local function getClosestTarget()
	local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil,nil end
	local closest,closestPlr,minDist=nil,nil,math.huge
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=LP and plr.Character then
			local tRoot=plr.Character:FindFirstChild("HumanoidRootPart")
			local hum=plr.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and hum and hum.Health>0 then
				local dist=(tRoot.Position-root.Position).Magnitude
				if dist<minDist then minDist=dist;closest=tRoot;closestPlr=plr end
			end
		end
	end
	return closest,closestPlr,minDist
end

local function getStickyTarget(currentRoot)
	local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil,nil end
	local newClosest,newPlr,newDist=getClosestTarget()
	if not newClosest then return nil,nil end
	if currentRoot and currentRoot.Parent then
		local currentPlr=Players:GetPlayerFromCharacter(currentRoot.Parent)
		local hum=currentRoot.Parent:FindFirstChildOfClass("Humanoid")
		if currentPlr and hum and hum.Health>0 then
			local currentDist=(currentRoot.Position-root.Position).Magnitude
			if currentPlr==newPlr or newDist>currentDist*0.7 then
				return currentRoot,currentPlr
			end
		end
	end
	return newClosest,newPlr
end

local function swingCurrentBat(char)
	if not autoSwingEnabled then return end
	local bat=findBat()
	if bat and bat.Parent==char and bat:IsA("Tool") then
		pcall(function() bat:Activate() end)
	end
end

-- Aimbot Başlatma
local function startBatAimbot()
	if Conns.aimbot then Conns.aimbot:Disconnect() end
	autoBatEnabled=true
	State.AutoBat=true
	State.BatAimbot=true

	local hum0=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum0 then hum0.AutoRotate=false end

	Conns.aimbot=RunService.RenderStepped:Connect(function()
		if not autoBatEnabled then return end
		local char=LP.Character;if not char then return end
		local root=char:FindFirstChild("HumanoidRootPart");if not root then return end
		local hum=char:FindFirstChildOfClass("Humanoid");if not hum then return end

		if not char:FindFirstChildOfClass("Tool") then
			local bat=findBat()
			if bat then pcall(function() hum:EquipTool(bat) end) end
		end

		local target,targetPlr=getStickyTarget(_aimbotTarget)
		if not target then 
			_aimbotTarget=nil;_aimbotTargetPlr=nil
			swingCurrentBat(char);return 
		end
		_aimbotTarget=target
		_aimbotTargetPlr=targetPlr

		local targetVel=target.Velocity
		local myPos=root.Position
		local targetPos=target.Position
		local distance=(targetPos-myPos).Magnitude

		local speedFactor=math.clamp(targetVel.Magnitude/40,0,1.2)
		local distFactor=math.clamp(distance/80,0,1)
		local leadTime=0.14+speedFactor*0.12+distFactor*0.08
		local predictPos=targetPos+targetVel*leadTime
		predictPos=predictPos+target.CFrame.LookVector*0.3

		local direction=predictPos-myPos
		local flatDir=Vector3.new(direction.X,0,direction.Z)
		if flatDir.Magnitude>0.01 then flatDir=flatDir.Unit else flatDir=Vector3.new(0,0,0) end

		local chaseSpeed=aimbotSpeed
		local jumpOffset=math.max(0,targetVel.Y*0.18)
		local desiredHeight=targetPos.Y+3.7+jumpOffset
		local yVel=(desiredHeight-myPos.Y)*22+targetVel.Y*1.1
		if hum.FloorMaterial~=Enum.Material.Air then
			yVel=math.max(yVel,13)
		end
		yVel=math.clamp(yVel,-70,135)

		local desiredVel=Vector3.new(flatDir.X*chaseSpeed,yVel,flatDir.Z*chaseSpeed)
		root.Velocity=root.Velocity:Lerp(desiredVel,0.85)

		local rotPredictTime=math.clamp(targetVel.Magnitude/120,0.05,0.25)
		local predictedPos=targetPos+targetVel*rotPredictTime
		local toPredict=predictedPos-myPos
		if toPredict.Magnitude>0.1 then
			local goalCF=CFrame.lookAt(myPos,predictedPos)
			local diffCF=root.CFrame:Inverse()*goalCF
			local rx,ry,rz=diffCF:ToEulerAnglesXYZ()
			rx=math.clamp(rx,-2.5,2.5)
			ry=math.clamp(ry,-2.5,2.5)
			rz=math.clamp(rz,-2.5,2.5)
			root.AssemblyAngularVelocity=root.CFrame:VectorToWorldSpace(Vector3.new(rx*50,ry*50,rz*50))
		end

		swingCurrentBat(char)
	end)
end

-- Aimbot Durdurma
local function stopBatAimbot()
	if Conns.aimbot then Conns.aimbot:Disconnect();Conns.aimbot=nil end
	_aimbotTarget=nil
	_aimbotTargetPlr=nil
	autoBatEnabled=false
	State.AutoBat=false
	State.BatAimbot=false
	local char=LP.Character
	local root=char and char:FindFirstChild("HumanoidRootPart")
	if root then root.Velocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end
	local hum2=char and char:FindFirstChildOfClass("Humanoid")
	if hum2 then hum2.AutoRotate=true end
end
