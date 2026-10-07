-- Rayfield UI Kütüphanesini Yükleme
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Steal a Brainrot | Auto-Walk Lock",
   LoadingTitle = "Script Yükleniyor...",
   LoadingSubtitle = "Xeno Executor",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

local Tab = Window:CreateTab("Ana Menü", 4483362458)

-- Değişkenler
local targetPosition = nil
local isWalking = false
local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- Humanoid ve RootPart Alma Fonksiyonu
local function getCharacterComponents()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return humanoid, root
end

-- Yürüme Döngüsü (Heartbeat - Her Frame Çalışır)
runService.Heartbeat:Connect(function()
    if isWalking and targetPosition then
        local humanoid, root = getCharacterComponents()
        if humanoid and root then
            -- Karakteri belirlenen noktaya doğru yürütür
            humanoid:MoveTo(targetPosition)
        end
    end
end)

-- UI Elemanları

Tab:CreateButton({
   Name = "1. Durduğun Konumu Seç",
   Callback = function()
       local _, root = getCharacterComponents()
       if root then
           targetPosition = root.Position
           Rayfield:Notify({
              Title = "Nokta Kaydedildi!",
              Content = "Karakterinin şu anki koordinatı hedef yürüyüş noktası olarak ayarlandı.",
              Duration = 3,
              Image = 4483362458,
           })
       end
   end,
})

Tab:CreateToggle({
   Name = "2. Yürüyerek Noktaya Kilitlen (Active / Deactive)",
   CurrentValue = false,
   Flag = "WalkLockToggle",
   Callback = function(Value)
       if Value and not targetPosition then
           Rayfield:Notify({
              Title = "Hata!",
              Content = "Önce 'Durduğun Konumu Seç' butonuna basmalısın!",
              Duration = 3,
              Image = 4483362458,
           })
           return
       end
       
       isWalking = Value
       
       if isWalking then
           Rayfield:Notify({
              Title = "Yürüyüş Aktif",
              Content = "Karakter seçilen noktaya doğru sürekli yürüyecek.",
              Duration = 2,
              Image = 4483362458,
           })
       else
           local humanoid, _ = getCharacterComponents()
           if humanoid then
               -- Deaktif edildiğinde yürümeyi durdurur
               humanoid:MoveTo(humanoid.Parent.HumanoidRootPart.Position)
           end
           
           Rayfield:Notify({
              Title = "Yürüyüş Deaktif",
              Content = "Karakter serbest bırakıldı.",
              Duration = 2,
              Image = 4483362458,
           })
       end
   end,
})
