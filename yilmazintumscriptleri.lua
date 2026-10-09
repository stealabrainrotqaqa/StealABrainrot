-- Script çalıştırıldığı anda tüm eklenen kodlar sırasıyla aktif olur.

-- 1. Script Yeri
task.spawn(function()
    local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "VerticalTiltGUI"

ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
-- Sağ ortada açılması için pozisyon ayarlandı
ToggleBtn.Position = UDim2.new(1, -190, 0.5, -22.5)
ToggleBtn.Size = UDim2.new(0, 180, 0, 45)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "180° Baş Aşağı: KAPALI"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16

-- UICorner eklendi (Köşeleri yuvarlatmak için)
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleBtn

-- Draggable (Sürüklenebilir) Özelliği
local dragging, dragInput, dragStart, startPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

local active = false
local bg = nil

-- Ragdoll ve düşme durumlarını kapatma fonksiyonu[cite: 1]
local function setAntiRagdoll(humanoid, enable)
    local states = {
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.PlatformStanding
    }
    for _, state in ipairs(states) do
        humanoid:SetStateEnabled(state, not enable)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    active = not active
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if active then
        ToggleBtn.Text = "180° Baş Aşağı: AÇIK"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)

        if hrp and humanoid then
            -- Ragdoll olmayı engelle[cite: 1]
            setAntiRagdoll(humanoid, true)
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

            -- Karakter parçalarının zeminle çakışmasını kapat[cite: 1]
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

            -- Başın yerin tam altına girmesini sağlayan derinlik (-7.5)[cite: 1]
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -7.5, 0)

            -- BodyGyro ile tam 180 derece baş aşağı çevirme[cite: 1]
            bg = Instance.new("BodyGyro")
            bg.Name = "TiltGyro"
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 25000
            bg.CFrame = hrp.CFrame * CFrame.Angles(math.rad(180), 0, 0)
            bg.Parent = hrp
        end
    else
        ToggleBtn.Text = "180° Baş Aşağı: KAPALI"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

        if bg then
            bg:Destroy()
            bg = nil
        end

        if char and hrp and humanoid then
            -- Ragdoll kısıtlamasını kaldır ve karakteri yukarı çek[cite: 1]
            setAntiRagdoll(humanoid, false)
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 7.5, 0)
            
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)
end)

-- 2. Script Yeri
task.spawn(function()
    local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 1. GUI Oluşturma
local ScreenGui = Instance.new("ScreenGui")
local KickButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "KickButtonGui"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

KickButton.Name = "KickButton"
KickButton.Parent = ScreenGui
KickButton.BackgroundColor3 = Color3.fromRGB(180, 35, 35) -- Kırmızı buton

-- Pozisyon daha yukarı (0.15) ve daha sola (0.01) çekildi
KickButton.Position = UDim2.new(0.01, 0, 0.15, 0) 

KickButton.Size = UDim2.new(0, 140, 0, 45)
KickButton.Font = Enum.Font.GothamBold
KickButton.Text = "Kick / Menu"
KickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KickButton.TextSize = 15.0
KickButton.Active = true

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = KickButton

-- 2. Sürüklenebilir (Draggable) Mantığı
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    KickButton.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

KickButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = KickButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

KickButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- 3. Butona Tıklanınca Kick Atma
KickButton.MouseButton1Click:Connect(function()
    LocalPlayer:Kick("\n\nSTEALED\n\nBrainrot Başarıyla Çalındı")
end)
end)

-- 3. Script Yeri
task.spawn(function()
    local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local dropActive = false
local autoBatEnabled = false
local _wfConns = {}

-- Drop Brainrot Ana Fonksiyonu
local function runDrop()
    if dropActive then return end
    
    for _, c in ipairs(_wfConns) do
        if typeof(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        elseif type(c) == "thread" then
            pcall(coroutine.close, c)
        end
    end
    _wfConns = {}

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not root then return end

    if autoBatEnabled then
        autoBatEnabled = false
    end

    pcall(function() root.Anchored = false end)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.PlatformStand = false end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end

    dropActive = true
    local changedCollisions = {}

    local function cleanupDrop()
        dropActive = false
        for _, c in ipairs(_wfConns) do
            if typeof(c) == "RBXScriptConnection" then
                pcall(function() c:Disconnect() end)
            elseif type(c) == "thread" then
                pcall(coroutine.close, c)
            end
        end
        _wfConns = {}
        for part, wasCollide in pairs(changedCollisions) do
            if typeof(part) == "Instance" and part.Parent then
                pcall(function() part.CanCollide = wasCollide end)
            end
        end
    end

    local colConn = RunService.Stepped:Connect(function()
        if not dropActive then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if changedCollisions[part] == nil then 
                            changedCollisions[part] = part.CanCollide 
                        end
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end
        end
    end)
    table.insert(_wfConns, colConn)

    local flingThread = coroutine.create(function()
        while dropActive do
            RunService.Heartbeat:Wait()
            local c = LP.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not r then break end
            pcall(function() r.Anchored = false end)
            local vel = r.Velocity
            pcall(function() r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0) end)
            RunService.RenderStepped:Wait()
            if r and r.Parent then pcall(function() r.Velocity = vel end) end
            RunService.Stepped:Wait()
            if r and r.Parent then pcall(function() r.Velocity = vel + Vector3.new(0, 0.1, 0) end) end
        end
    end)
    table.insert(_wfConns, flingThread)

    local ok = coroutine.resume(flingThread)
    if not ok then cleanupDrop(); return end
    task.delay(0.25, cleanupDrop)
end

-- Klavyeden 'X' Tuşu Tetikleyicisi
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        runDrop()
    end
end)

-- Mobil Drop Butonu Arayüzü (Sürüklenebilir)
local function createDropButton()
    local screen = Instance.new("ScreenGui")
    screen.Name = "DropButtonGui"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 10
    
    local coreGui = game:GetService("CoreGui")
    if not pcall(function() screen.Parent = coreGui end) then
        screen.Parent = LP:WaitForChild("PlayerGui")
    end

    local frame = Instance.new("Frame", screen)
    frame.Name = "DropButtonFrame"
    frame.Size = UDim2.new(0, 70, 0, 45)
    frame.Position = UDim2.new(0.8, 0, 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 9)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 92, 181)
    stroke.Thickness = 1.5

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "DROP BR"
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 10

    -- Draggable (Sürükleme) Mantığı
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local hasMoved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            hasMoved = false
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not hasMoved then
                runDrop()
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                hasMoved = true
            end
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

createDropButton()
end)

-- 4. Script Yeri
task.spawn(function()
    local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- Varsa eski ESP klasörünü temizleyelim
if CoreGui:FindFirstChild("List_ESP_Folder") then
    CoreGui.List_ESP_Folder:Destroy()
end

-- ESP nesnelerini tutacak klasör
local espFolder = Instance.new("Folder")
espFolder.Name = "List_ESP_Folder"
espFolder.Parent = CoreGui

-- Aranacak nesne isimlerinin listesi
local targetNames = {
    ["Strawberry Elephant"] = true,
    ["Headless Horseman"] = true,
    ["Meowl"] = true,
    ["John Pork"] = true,
    ["Skibidi Toilet"] = true,
    ["Griffin"] = true,
    ["Dragon Aquanini"] = true,
    ["Dragon Gingerini"] = true,
    ["Hydra Dragon Cannelloni"] = true,
    ["Signore Carapace"] = true,
    ["Dragon Cannelloni"] = true,
    ["Love Love Bear"] = true,
    ["Moby Bros"] = true,
    ["Arcadragon"] = true,
    ["Digi Narwhal"] = true,
    ["Kraken"] = true,
    ["La Supreme Combinasion"] = true,
    ["Elefanto Frigo"] = true,
    ["Hydra Bunny"] = true,
    ["Celestial Pegasus"] = true,
    ["Cerberus"] = true,
    ["Jelly Moby"] = true,
    ["Venuspino"] = true,
    ["Bumbatron"] = true,
    ["Bunny and Eggy"] = true,
    ["Popcuru and Fizzuru"] = true,
    ["La Breakfast Combinasion"] = true,
    ["Rosey and Teddy"] = true,
    ["Capitano Moby"] = true,
    ["Cooki and Milki"] = true,
    ["Orchidox"] = true,
    ["Burguro And Fryuro"] = true,
    ["Los Secret Combinasionas"] = true,
    ["Ketupat Bros"] = true,
    ["Reinito Sleighito"] = true,
    ["Fortunu and Cashuru"] = true,
    ["Los Amigos"] = true,
    ["Pizza and Ranch"] = true,
    ["Antonio"] = true,
    ["La Secret Combinasion"] = true,
    ["Pancake and Syrup"] = true,
    ["Fishino Clownino"] = true,
    ["Foxini Lanternini"] = true,
    ["Kalika Bros"] = true,
    ["Los Sekolahs"] = true,
    ["Sammyni Truckini"] = true,
    ["Cash or Card"] = true,
    ["Fragrama and Chocrama"] = true,
    ["La Casa Boo"] = true,
    ["La Fuse Machine"] = true,
    ["Los Admins"] = true,
    ["Duggy Bros"] = true,
    ["La Food Combinasion"] = true,
    ["Yetimatic"] = true,
    ["S'more Serat"] = true,
    ["Sammyni Cakini"] = true,
    ["Boppin Bunny"] = true,
    ["Spooky and Pumpky"] = true,
    ["Cangurato Gelato"] = true,
    ["Ginger Gerat"] = true,
    ["La Ginger Sekolah"] = true,
    ["Los Chillis"] = true,
    ["Los Hackers"] = true,
    ["Bearito Cabinito"] = true,
    ["Capitano Americano"] = true,
    ["Rubiko and Kubiko"] = true,
    ["Examen Bros"] = true,
    ["Los Spaghettis"] = true,
    ["Rubrikiko"] = true,
    ["Sammyni Fattini"] = true,
    ["Festive 67"] = true,
    ["Guest 666"] = true,
    ["Quackini Snackini"] = true,
    ["Queen Bee"] = true,
    ["Ventoliero Pavonero"] = true,
    ["Grabatron"] = true,
    ["Pop Pop Petalini"] = true,
    ["Cloverat Clapat"] = true,
    ["La Summer Grande"] = true,
    ["Los Tictacs"] = true,
    ["Spaphetti Tualetti"] = true,
    ["Candini Fluffini"] = true,
    ["Caylusaurus"] = true,
    ["Hopilikalika Hopilikalako"] = true,
    ["La Easter Grande"] = true,
    ["Polaroidini"] = true,
    ["Steakini Fattini"] = true,
    ["Garama and Madundung"] = true,
    ["La Anniversary Grande"] = true,
    ["Nacho Spyder"] = true,
    ["Money Money Bros"] = true,
    ["Gold Gold Gold"] = true,
    ["Jolly Jolly Sahur"] = true,
    ["Lavadorito Spinito"] = true,
    ["Gym Bros"] = true,
    ["Ketchuru and Musturu"] = true,
    ["Los Tangcitos"] = true,
    ["Rico Dinero"] = true,
    ["Tirilikalika Tirilikalako"] = true,
    ["La Lucky Grande"] = true,
    ["La Romantic Grande"] = true,
    ["Orcaledon"] = true,
    ["Swaggy Bros"] = true,
    ["Tictac Sahur"] = true,
    ["Dug dug dug"] = true,
    ["Ketupat Kepat"] = true,
    ["La Taco Combinasion"] = true,
    ["Coco and Mango"] = true,
    ["Tang Tang Keletang"] = true,
    ["Abyssaloco"] = true,
    ["Fragola La La La"] = true,
    ["Lovin Rose"] = true,
    ["Noo my Resume"] = true,
    ["Noo my Examen"] = true,
    ["Bufalino Boomberino"] = true,
    ["Honey Honey Bear"] = true,
    ["Los Tacoritas"] = true,
    ["Eviledon"] = true,
    ["Los Primos"] = true,
    ["La Jolly Grande"] = true,
    ["Los Cupids"] = true,
    ["Los Mariachis"] = true,
    ["Los Puggies"] = true,
    ["W or L"] = true,
    ["Globa Steppa"] = true,
    ["Gobblino Uniciclino"] = true,
    ["Tralaledon"] = true,
    ["Tacoturbo Tacorito"] = true,
    ["Chillin Chili"] = true,
    ["Chipso and Queso"] = true,
    ["Money Money Reindeer"] = true,
    ["La Spooky Grande"] = true,
    ["Los Bros"] = true,
    ["La Extinct Grande"] = true,
    ["Celularcini Viciosini"] = true,
    ["Money Money Puggy"] = true,
    ["Los Hotspotsitos"] = true,
    ["Los Jolly Combinasionas"] = true,
    ["Los Spooky Combinasionas"] = true,
    ["Los Planitos"] = true,
    ["Las Sis"] = true,
    ["Camera Ramena"] = true,
    ["Tacorita Bicicleta"] = true,
    ["Nuclearo Dinossauro"] = true,
    ["John Doe"] = true,
    ["Trenostruzzo Turbo 4000"] = true,
    ["Pretzo Robo"] = true,
    ["Tenini Ballini"] = true,
    ["Ginger Cisterna"] = true,
    ["Anpali Babel"] = true,
    ["Frio Ninja"] = true,
    ["Lazy Ducky"] = true,
    ["Brr es Teh Patipum"] = true,
    ["Pineaplino"] = true,
    ["Las Capuchinas"] = true,
    ["Centrucci Nuclucci"] = true,
    ["Rhino Helicopterino"] = true,
    ["Tob Tobi Tobi"] = true,
    ["Ganganzelli Trulala"] = true,
    ["Gorillo Subwoofero"] = true
}

-- Target için kafa/üst nokta bulma fonksiyonu
local function getHeadOrTopPart(target)
    if target:IsA("Model") then
        local head = target:FindFirstChild("Head") or target:FindFirstChild("head")
        if head then return head end
        if target.PrimaryPart then return target.PrimaryPart end
        return target:FindFirstChildWhichIsA("BasePart")
    elseif target:IsA("BasePart") then
        return target
    end
    return nil
end

-- ESP Vurgulama ve İsim Yazısı Fonksiyonu
local function createESP(target)
    local adornPart = getHeadOrTopPart(target)
    if not adornPart then return end

    -- 1. Parlama (Highlight) Efekti
    local highlight = Instance.new("Highlight")
    highlight.Name = target.Name .. "_Highlight"
    highlight.Adornee = target
    highlight.FillColor = Color3.fromRGB(0, 255, 150)
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = espFolder

    -- 2. Yeşil İsim Etiketi (BillboardGui) - BÜYÜTÜLDÜ
    local billboard = Instance.new("BillboardGui")
    billboard.Name = target.Name .. "_NameTag"
    billboard.Adornee = adornPart
    
    -- Pixel bazlı sabit boyut (Yazı büyüdüğü için burayı da büyüttük)
    billboard.Size = UDim2.new(0, 250, 0, 50) 
    billboard.SizeOffset = Vector2.new(0, 0)
    
    -- Kafanın tam üstünde durması için yükseklik ofseti
    billboard.StudsOffset = Vector3.new(0, 3, 0) 
    billboard.AlwaysOnTop = true
    billboard.Parent = espFolder

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = target.Name
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Yeşil
    textLabel.TextSize = 22                          -- Yazı boyutu büyütüldü (14 -> 22)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0             -- Siyah dış çizgi
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = billboard
end

-- Kontrol ve Uygulama
local function checkItem(child)
    if targetNames[child.Name] then
        createESP(child)
    end
end

-- 1. Haritadaki mevcut tüm nesneleri tara
for _, child in pairs(Workspace:GetDescendants()) do
    checkItem(child)
end

-- 2. Haritaya yeni eklenen nesneleri yakala
Workspace.DescendantAdded:Connect(function(child)
    checkItem(child)
end)
end)

-- 5. Script Yeri
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/stealabrainrotqaqa/StealABrainrot/refs/heads/main/esp.lua"))()
end)

-- 6. Script Yeri
task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("SolaraJoinGUI") then
    playerGui.SolaraKickGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SolaraJoinGUI"
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "PSButton"
-- Boyutu küçültüldü, konumu ortanın biraz sağında ayarlandı
button.Size = UDim2.new(0, 140, 0, 40)
button.Position = UDim2.new(0.55, -70, 0.5, -20)
button.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.Font = Enum.Font.GothamBold
button.Text = "Join PS"
button.Parent = screenGui

-- Kenarları ovalleştirmek için UICorner eklendi
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = button

-- Sürüklenebilir (Draggable) yapma kısmı
local dragging, dragInput, dragStart, startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Tıklayınca kickleme
button.MouseButton1Click:Connect(function()
    -- ============================================================
-- DIRECT PRIVATE SERVER TELEPORT SCRIPT
-- ============================================================

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlaceId = 109983668079237
local PrivateServerCode = "47431846278029804177859411428304"

-- Işınlanma işlemi
local success, err = pcall(function()
    TeleportService:TeleportToPrivateServer(PlaceId, PrivateServerCode, {LocalPlayer})
end)

-- TeleportToPrivateServer alternatifi (LinkCode desteği için yedek yöntem)
if not success then
    pcall(function()
        game:GetService("ExperienceService"):LaunchExperience({
            placeId = PlaceId,
            linkCode = PrivateServerCode
        })
    end)
end
end)
end)

-- 7. Script Yeri
task.spawn(function()
    local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local infJumpEnabled = false
local holdJumpPressed = false
local holdJumpActive = false

-- Eski GUI Temizliği
local oldGui = CoreGui:FindFirstChild("InfJumpToggleGui") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("InfJumpToggleGui")
if oldGui then oldGui:Destroy() end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InfJumpToggleGui"
screenGui.ResetOnSpawn = false

pcall(function()
	if syn and syn.protect_gui then syn.protect_gui(screenGui) end
	screenGui.Parent = CoreGui
end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Sürüklenebilir Buton
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Name = "InfJumpButton"
toggleBtn.Size = UDim2.new(0, 140, 0, 45)
toggleBtn.Position = UDim2.new(0.82, 0, 0.75, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
toggleBtn.Text = "Inf Jump: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 92, 181)
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 14
toggleBtn.Active = true
toggleBtn.Draggable = true

local corner = Instance.new("UICorner", toggleBtn)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", toggleBtn)
stroke.Color = Color3.fromRGB(255, 92, 181)
stroke.Thickness = 1.5

-- Jump Logic
local function applyInfJumpBoost(boost)
	if not infJumpEnabled then return end
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then 
		root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, boost, root.AssemblyLinearVelocity.Z)
	end
end

toggleBtn.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	if infJumpEnabled then
		toggleBtn.Text = "Inf Jump: ON"
		toggleBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
		stroke.Color = Color3.fromRGB(0, 180, 255)
	else
		toggleBtn.Text = "Inf Jump: OFF"
		toggleBtn.TextColor3 = Color3.fromRGB(255, 92, 181)
		stroke.Color = Color3.fromRGB(255, 92, 181)
		holdJumpActive = false
		holdJumpPressed = false
	end
end)

UserInputService.JumpRequest:Connect(function() 
	applyInfJumpBoost(50) 
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
		holdJumpPressed = true
		task.delay(0.12, function()
			if holdJumpPressed then
				holdJumpActive = true
				applyInfJumpBoost(50)
			end
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then 
		holdJumpPressed = false
		holdJumpActive = false 
	end
end)

RunService.Heartbeat:Connect(function()
	if holdJumpActive then 
		applyInfJumpBoost(50) 
	end
end)
end)

-- 8. Script Yeri
task.spawn(function()
    local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true
local TeamCheck = true

local Container = Instance.new("Folder")
Container.Name = "SolaraESP_Folder"

pcall(function()
	Container.Parent = CoreGui
end)
if not Container.Parent then Container.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function applyESP(player)
	if player == LocalPlayer then return end

	local function setupCharacter(char)
		if not char then return end
		local root = char:WaitForChild("HumanoidRootPart", 5)
		local humanoid = char:WaitForChild("Humanoid", 5)
		local head = char:WaitForChild("Head", 5)

		if not root or not humanoid or not head then return end

		-- Eski ESP varsa temizle
		if char:FindFirstChild("SolaraHighlight") then char.SolaraHighlight:Destroy() end
		if head:FindFirstChild("SolaraBillboard") then head.SolaraBillboard:Destroy() end

		-- 1. Chams (Duvar Arkası Parlama)
		local highlight = Instance.new("Highlight")
		highlight.Name = "SolaraHighlight"
		highlight.Adornee = char
		highlight.FillColor = Color3.fromRGB(255, 50, 50)
		highlight.FillTransparency = 0.5
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = char

		-- 2. Billboard (İsim ve Can Metni)
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "SolaraBillboard"
		billboard.Adornee = head
		billboard.Size = UDim2.new(0, 150, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local textLabel = Instance.new("TextLabel", billboard)
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextSize = 14
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextStrokeTransparency = 0
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

		-- Can ve Takım Kontrol Döngüsü
		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not char or not char.Parent or not humanoid or humanoid.Health <= 0 or not ESPEnabled then
				highlight.Enabled = false
				billboard.Enabled = false
				return
			end

			-- Takım Filtresi
			if TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
				highlight.Enabled = false
				billboard.Enabled = false
				return
			end

			highlight.Enabled = true
			billboard.Enabled = true
			textLabel.Text = string.format("%s\n[%d HP]", player.Name, math.floor(humanoid.Health))
		end)

		humanoid.Died:Connect(function()
			if connection then connection:Disconnect() end
			highlight:Destroy()
			billboard:Destroy()
		end)
	end

	if player.Character then setupCharacter(player.Character) end
	player.CharacterAdded:Connect(setupCharacter)
end

-- Mevcut Oyuncular
for _, p in ipairs(Players:GetPlayers()) do
	applyESP(p)
end

-- Yeni Katılan Oyuncular
Players.PlayerAdded:Connect(applyESP)
end)

-- 9. Script Yeri
task.spawn(function()
    repeat task.wait(0.5) until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local function getRainbowColor()
	return Color3.fromHSV((tick() % 3) / 3, 0.9, 1)
end

local function applyRainbowBase()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart", 20)
	
	-- Workspace ve Plots yüklenene kadar bekle
	local plotsFolder = Workspace:WaitForChild("Plots", 20)
	if not root or not plotsFolder then return end

	-- Spawn parçasına göre en yakın Plot'u bul
	local myPlot = nil
	local shortestDist = math.huge

	-- Plots tam yüklenene kadar sürekli tarama dener
	for attempt = 1, 10 do
		for _, plot in ipairs(plotsFolder:GetChildren()) do
			local spawnPart = plot:FindFirstChild("Spawn", true)
			if spawnPart and spawnPart:IsA("BasePart") then
				local dist = (root.Position - spawnPart.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					myPlot = plot
				end
			end
		end
		
		if myPlot then break end
		task.wait(1)
	end

	if not myPlot then return end

	-- Eski Efekt Temizliği
	if myPlot:FindFirstChild("SolaraAutoExecHighlight") then myPlot.SolaraAutoExecHighlight:Destroy() end
	if myPlot:FindFirstChild("SolaraAutoExecGui") then myPlot.SolaraAutoExecGui:Destroy() end

	-- Highlight (Duvar Arkası Rainbow Parlama)
	local highlight = Instance.new("Highlight")
	highlight.Name = "SolaraAutoExecHighlight"
	highlight.Adornee = myPlot
	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = myPlot

	-- Base Üstü Tabela (BillboardGui)
	local spawnPart = myPlot:FindFirstChild("Spawn", true) or myPlot
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SolaraAutoExecGui"
	billboard.Size = UDim2.new(0, 250, 0, 60)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 12, 0)
	billboard.Adornee = spawnPart
	billboard.Parent = myPlot

	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "★ MY BASE ★"
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 22
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

	-- Kesintisiz Renk Döngüsü
	RunService.RenderStepped:Connect(function()
		if myPlot and highlight and highlight.Parent then
			local color = getRainbowColor()
			highlight.FillColor = color
			highlight.OutlineColor = color
			label.TextColor3 = color
		end
	end)
end

-- Otomatik Başlatıcılar (Autoexec)
task.spawn(function()
	task.wait(2)
	applyRainbowBase()
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1.5)
	applyRainbowBase()
end)
end)

-- 10. Script Yeri
task.spawn(function()
    -- Executor platform script (CoreGui destekli)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Eğer daha önce açtıysan eski menüyü temizler (Üst üste binmesin diye)
if CoreGui:FindFirstChild("ExecPlatformGui") then
    CoreGui.ExecPlatformGui:Destroy()
end

-- Durum Değişkenleri
local isActive = false
local platform = nil
local connection = nil

-- GUI Oluşturma (Executor uyumlu CoreGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExecPlatformGui"
screenGui.Parent = CoreGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 140, 0, 45)
-- Position değeri yukarı çekildi (Y scale: 0.3 -> 0.15)
toggleButton.Position = UDim2.new(0.1, 0, 0.15, 0) 
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.Text = "Platform: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 85, 85)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.BorderSizePixel = 0
toggleButton.Active = true
toggleButton.Draggable = true -- Butonu ekranda mouse ile sürükleyebilirsin!
toggleButton.Parent = screenGui

-- Buton Yuvarlama
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = toggleButton

-- Karakter Yenilenince Güncelleme (Ölünce hata vermemesi için)
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if isActive then
        task.wait(0.5) -- Karakterin yüklenmesini bekle
        createPlatform()
    end
end)

-- Platform Oluşturma Fonksiyonu
function createPlatform()
    if platform then platform:Destroy() end
    
    platform = Instance.new("Part")
    platform.Size = Vector3.new(7, 0.6, 7) -- Altındaki platformun genişliği
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Neon
    platform.Color = Color3.fromRGB(0, 255, 150) -- Yeşil/Mavi Neon Renk
    platform.Transparency = 0.4
    platform.Parent = workspace
end

-- Platformu Kapatma Fonksiyonu
function removePlatform()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if platform then
        platform:Destroy()
        platform = nil
    end
end

-- Buton Tıklama Mantığı
toggleButton.MouseButton1Click:Connect(function()
    isActive = not isActive
    
    if isActive then
        toggleButton.Text = "Platform: ON"
        toggleButton.TextColor3 = Color3.fromRGB(85, 255, 85)
        
        createPlatform()
        
        -- Seni pürüzsüzce takip etmesi için RenderStepped döngüsü
        connection = RunService.RenderStepped:Connect(function()
            if platform and humanoidRootPart and humanoidRootPart.Parent then
                -- Karakterin tam altına (Y ekseninde -3.25 birim aşağıya) sabitler
                platform.CFrame = CFrame.new(humanoidRootPart.Position - Vector3.new(0, 3.25, 0))
            else
                -- Eğer karakter kaybolursa (ölürsen) hata vermemesi için koruma
                if character and character:FindFirstChild("HumanoidRootPart") then
                    humanoidRootPart = character.HumanoidRootPart
                end
            end
        end)
    else
        toggleButton.Text = "Platform: OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 85, 85)
        
        removePlatform()
    end
end)
end)

-- 11. Script Yeri
task.spawn(function()
    -- Steal a Brainrot - Velocity Speed Bypass

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("BrainrotSpeedUI") then
	CoreGui.BrainrotSpeedUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotSpeedUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "SpeedToggle"
ToggleBtn.Size = UDim2.new(0, 160, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "Hız: KAPALI (30)"
ToggleBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleBtn

local toggled = false
local TARGET_SPEED = 56

-- Velocity Tabanlı Hızlandırma
RunService.Heartbeat:Connect(function()
	if toggled then
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			local root = char:FindFirstChild("HumanoidRootPart")
			
			if hum and root and hum.MoveDirection.Magnitude > 0 then
				local currentY = root.AssemblyLinearVelocity.Y
				local moveDir = hum.MoveDirection.Unit
				-- Karakterin yatay hızını doğrudan TARGET_SPEED (56) yap, dikey hızı (yerçekimi/zıplama) koru
				root.AssemblyLinearVelocity = Vector3.new(moveDir.X * TARGET_SPEED, currentY, moveDir.Z * TARGET_SPEED)
			end
		end
	end
end)

ToggleBtn.MouseButton1Click:Connect(function()
	toggled = not toggled
	if toggled then
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		ToggleBtn.Text = "Hız: AÇIK (56)"
	else
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
		ToggleBtn.Text = "Hız: KAPALI (30)"
	end
end)

-- UI Sürükleme Mantığı
local dragging, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = ToggleBtn.Position
	end
end)
ToggleBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
end)

-- 12. Script Yeri
task.spawn(function()
    -- Solara Uyumlu UI Corner + Orta-Üstün Biraz Altı TP Down Butonu
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- En uygun Parent seçimi (CoreGui veya PlayerGui)
local parentTarget = nil
local success = pcall(function()
    parentTarget = game:GetService("CoreGui")
end)
if not success or not parentTarget then
    parentTarget = LP:WaitForChild("PlayerGui")
end

-- Eski UI temizliği (Üst üste binmeyi engeller)
if parentTarget:FindFirstChild("ZypherisFixTP") then
    parentTarget.ZypherisFixTP:Destroy()
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZypherisFixTP"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = parentTarget

-- Ekranın Orta-Üstünün Birazcık Altında Buton (%16 Y pozisyonu)
local TPButton = Instance.new("TextButton")
TPButton.Name = "TPBtn"
TPButton.Size = UDim2.new(0, 160, 0, 45)
TPButton.Position = UDim2.new(0.5, -80, 0.16, 0) -- Biraz daha aşağı çekildi
TPButton.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TPButton.BorderColor3 = Color3.fromRGB(0, 170, 255)
TPButton.BorderSizePixel = 2
TPButton.Text = "TP DOWN (-7)"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.TextSize = 15
TPButton.Font = Enum.Font.SourceSansBold
TPButton.Active = true
TPButton.Draggable = true -- İstediğin yere sürükleyebilirsin
TPButton.Parent = ScreenGui

-- UICorner (Köşe Yuvarlatma)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = TPButton

-- TP Down İşlevi
TPButton.MouseButton1Click:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(hrp.Position.X, -7.00, hrp.Position.Z) * CFrame.Angles(0, select(2, hrp.CFrame:ToEulerAnglesYXZ()), 0)
    end
end)
end)
