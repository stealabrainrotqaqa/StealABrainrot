task.spawn(function()
-- Auto-Exec və Re-execution garantisi
if queue_on_teleport then
    queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()]]) -- Və ya öz auto-exec qovluğunuzda saxlayın
elseif queueonteleport then
    queueonteleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()]])
end

repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TARGET_PLACE_ID = 109983668079237

-- Əvvəlki serverləri yaddaşda saxlamaq üçün global cədvəl
getgenv().VisitedServers = getgenv().VisitedServers or {}
table.insert(getgenv().VisitedServers, game.JobId)

-- Hop Sayacı
getgenv().CurrentHopCount = (getgenv().CurrentHopCount or 0) + 1
local hopCount = getgenv().CurrentHopCount

-- Frio Ninja silinmiş güncel hedef listesi
local TargetBrainrots = {
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

local function UpdateGUI(text, color, isClickable)
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local gui = playerGui:FindFirstChild("HopStatusGui")
    
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "HopStatusGui"
        gui.ResetOnSpawn = false
        gui.Parent = playerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 260, 0, 70)
        frame.Position = UDim2.new(0.5, -130, 0.8, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local statusButton = Instance.new("TextButton")
        statusButton.Name = "StatusBtn"
        statusButton.Size = UDim2.new(0.9, 0, 0.7, 0)
        statusButton.Position = UDim2.new(0.05, 0, 0.15, 0)
        statusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusButton.TextSize = 16
        statusButton.Font = Enum.Font.SourceSansBold
        statusButton.Parent = frame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = statusButton
    end

    local statusButton = gui.Frame.StatusBtn
    statusButton.Text = text
    statusButton.BackgroundColor3 = color or Color3.fromRGB(0, 170, 255)
    
    if isClickable then
        statusButton.Active = true
        return statusButton
    else
        statusButton.Active = false
        return nil
    end
end

-- Server Hop (Əvvəl gedilmiş serverləri keçir)
local function ServerHop()
    print("[SERVER HOP] Yeni və gedilməmiş sunucu taranır...")
    UpdateGUI("Yeni Sunucu Araniyor... (Hop: " .. hopCount .. ")", Color3.fromRGB(200, 100, 0), false)

    local cursor = ""
    local foundServer = nil

    while not foundServer do
        local url = "https://games.roblox.com/v1/games/" .. TARGET_PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end

        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and response and response.data then
            for _, server in ipairs(response.data) do
                -- Əgər server daha öncə girilməyibsə və dolu deyilsə
                if not table.find(getgenv().VisitedServers, server.id) and server.playing < server.maxPlayers then
                    foundServer = server.id
                    break
                end
            end

            if not foundServer then
                if response.nextPageCursor and response.nextPageCursor ~= null then
                    cursor = response.nextPageCursor
                else
                    cursor = "" -- Bütün səhifələr bitərsə başa dön
                end
            end
        else
            task.wait(2)
        end
        task.wait(0.5)
    end

    if foundServer then
        table.insert(getgenv().VisitedServers, foundServer)
        print("[SERVER HOP] " .. foundServer .. " sunucusuna keçilir...")
        TeleportService:TeleportToPlaceInstance(TARGET_PLACE_ID, foundServer, LocalPlayer)
    end
end

-- Plots Kontrolü
local function CheckPlots()
    print("[SERVER HOP] Plots bekleniyor... (Hop: " .. hopCount .. ")")
    UpdateGUI("Plots Yükleniyor... (Hop: " .. hopCount .. ")", Color3.fromRGB(200, 100, 0), false)
    
    local plots = workspace:WaitForChild("Plots", 15)
    
    if not plots then
        print("[SERVER HOP] Plots tapılmadı, yeni servere keçilir...")
        ServerHop()
        return
    end

    task.wait(1.5) -- Obyektlərin tam yüklənməsi üçün bekleme

    local found = false
    local foundName = ""

    for _, descendant in ipairs(plots:GetDescendants()) do
        if TargetBrainrots[descendant.Name] then
            found = true
            foundName = descendant.Name
            break
        end
    end

    if found then
        print("[SERVER HOP SUCCESS] Tapıldı: " .. foundName .. " | Hop: " .. hopCount)
        local btn = UpdateGUI("DEVAM ET (" .. foundName .. ")", Color3.fromRGB(0, 255, 127), true)
        
        btn.MouseButton1Click:Connect(function()
            ServerHop()
        end)
    else
        print("[SERVER HOP] Hədəf tapılmadı. Avtomatik yeni servere keçilir...")
        ServerHop()
    end
end

-- Teleport xətası verərsə
TeleportService.TeleportInitFailed:Connect(function()
    print("[SERVER HOP ERROR] Teleport xətası! Təkrar denenir...")
    task.wait(2)
    ServerHop()
end)

-- Avtomatik Başlatma
task.spawn(function()
    task.wait(3)
    CheckPlots()
end)
