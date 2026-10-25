-- Bot Script (Sadece Temiz Eşya İsmi - Kesintisiz & Titreşimsiz)
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local FIREBASE_URL = "https://stealaneggnotifier-default-rtdb.firebaseio.com/servers/" .. game.JobId .. ".json"

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Brainrot Scanner",
        Text = "Script başarıyla çalıştırıldı!",
        Duration = 5
    })
end)

local targetItems = {
    "Abyssaloco", "Antonio", "Arcadragon", "Bearito Cabinito", "Boo Boo Rocket",
    "Boppin Bunny", "Bufalino Boomberino", "Bumbatron", "Bunny and Eggy", "Burguro And Fryuro",
    "Candini Fluffini", "Cangurato Gelato", "Capitano Americano", "Capitano Moby", "Cash or Card",
    "Caylusaurus", "Celestial Pegasus", "Celularcini Viciosini", "Cerberus", "Chicli Chicla",
    "Chillin Chili", "Chipso and Queso", "Cloverat Clapat", "Cobra Gelato", "Coco and Mango",
    "Cooki and Milki", "Deputy Leopard", "Digi Narwhal", "Donkeyturbo Express", "Draculino",
    "Dragon Aquanini", "Dragon Cannelloni", "Dragon Gingerini", "Dragon Skeletonini", "Dug dug dug",
    "Duggy Bros", "Elefanto Frigo", "Esok Sekolah", "Eviledon", "Examen Bros",
    "Festive 67", "Fishino Clownino", "Flying Dutchman", "Fortunu and Cashuru", "Foxini Lanternini",
    "Fragola La La La", "Fragrama and Chocrama", "Garama and Madundung", "Ginger Gerat", "Globa Steppa",
    "Gobblino Uniciclino", "Gold and Diamond", "Gold Gold Gold", "Grabatron", "Griffin",
    "Guest 666", "Gym Bros", "Headless Horseman", "Honey Honey Bear", "Honey Honey Narwhal",
    "Hopilikalika Hopilikalako", "Hydra Bunny", "Hydra Dragon Cannelloni", "Hydra Serpent", "Jelly Moby",
    "John Pork", "Jolly Jolly Sahur", "Kalika Bros", "Ketchuru and Musturu", "Ketupat Bros",
    "Ketupat Kepat", "Kraken", "La Anniversary Grande", "La Breakfast Combinasion", "La Casa Boo",
    "La Craft Machine", "La Easter Grande", "La Extinct Grande", "La Food Combinasion", "La Fuse Machine",
    "La Ginger Sekolah", "La Jolly Grande", "La Lucky Grande", "La Romantic Grande", "La Secret Combinasion",
    "La Spooky Grande", "La Summer Grande", "La Supreme Combinasion", "La Taco Combinasion", "Las Sis",
    "Lavadorito Spinito", "Lionello Casarello", "Los Admins", "Los Amigos", "Los Bros",
    "Los Cupids", "Los Dragons", "Los Hackers", "Los Hotspotsitos", "Los Jolly Combinasionas",
    "Los Mariachis", "Los Planitos", "Los Primos", "Los Puggies", "Los Secret Combinasionas",
    "Los Sekolahs", "Los Spaghettis", "Los Spooky Combinasionas", "Los Tacoritas", "Los Tangcitos",
    "Los Tictacs", "Love Love Bear", "Lovin Rose", "Lucky Block", "Meowl",
    "Moby Bros", "Money Money Bros", "Money Money Puggy", "Money Money Reindeer", "Nacho Spyder",
    "Nachorilla", "Naughty Naughty", "Noo my examine", "Noo my Resume", "Nuclearo Dinossauro",
    "Orcaledon", "Orchidox", "Pancake and Syrup", "Phoenix", "Pizza and Ranch",
    "Plant Bros", "Polaroidini", "Pop Pop Petalini", "Popcuru and Fizzuru", "Puffino Builderino",
    "Quackini Snackini", "Queen Bee", "Quesadillo Vampiro", "Reinito Sleighito", "Rico Dinero",
    "Rosetti Tualetti", "Rosey and Teddy", "Rubiko and Kubiko", "Rubrikiko", "S'more Serat",
    "Sammyni Cakini", "Sammyni Fattini", "Sammyni Spookyni", "Sammyni Truckini", "Sand Sand Sand",
    "Scorpino Coasterino", "Signore Carapace", "Sir Mangus", "Skibidi Toilet", "Spaghetti Tualetti",
    "Spooky and Pumpky", "Steakini Fattini", "Strawberry Elephant", "Swaggy Bros", "Tacorita Bicicleta",
    "Tacoturbo Tacorito", "Tang Tang Keletang", "Tictac Sahur", "Tirilikalika Tirilikalako", "Tralaledon",
    "Ventoliero Pavonero", "Venuspino", "W or L", "Yetimatic"
}

local function updateFirebase(itemsList)
    local httpRequest = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
    if not httpRequest then return end

    -- Sadece eşya listesi boş değilse güncelleme gönder
    -- Boş olsa bile veriyi SİLMEZ (DELETE çağrısını kaldırdık)
    if #itemsList > 0 then
        local data = {
            jobId = game.JobId,
            placeId = game.PlaceId,
            items = itemsList,
            timestamp = os.time()
        }
        httpRequest({
            Url = FIREBASE_URL,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end
end

local function scanServer()
    local foundItems = {}
    local plotsFolder = Workspace:FindFirstChild("Plots") or Workspace

    for _, itemName in ipairs(targetItems) do
        if itemName and itemName ~= "" then
            local foundItem = plotsFolder:FindFirstChild(itemName, true)
            if not foundItem then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        foundItem = player.Character:FindFirstChild(itemName, true)
                        if foundItem then break end
                    end
                end
            end

            if foundItem then
                table.insert(foundItems, itemName)
            end
        end
    end
    
    updateFirebase(foundItems)
end

task.spawn(function()
    while task.wait(3) do
        scanServer()
    end
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    scanServer()
end)

-- Sadece oyun/sunucu tamamen kapandığında Firebase'deki veriyi temizler
game:BindToClose(function()
    local httpRequest = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
    if httpRequest then
        httpRequest({ Url = FIREBASE_URL, Method = "DELETE" })
    end
end)
