local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- Estado global
getgenv().BestPetESP = getgenv().BestPetESP or {
    active = false,
    loop = nil,
    currentESP = nil
}

-- Parse valor (ex: "1.5K/s" -> 1500)
local function parseValue(text)
    text = tostring(text or ""):gsub("%s", "")
    local num, suffix = text:match("([%d%.]+)([KkMmBbTt]?)")
    if not num then return 0 end
    num = tonumber(num) or 0
    local multipliers = {K=1e3, M=1e6, B=1e9, T=1e12}
    local mult = multipliers[(suffix or ""):upper()] or 1
    return num * mult
end

-- Criar ESP Billboard
local function createESP(part, displayText, valueText)
    if getgenv().BestPetESP.currentESP then
        pcall(function() getgenv().BestPetESP.currentESP:Destroy() end)
    end
    
    if not part then 
        return 
    end
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "BestPetESP"
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = part
    bb.Parent = CoreGui
    
    local name = Instance.new("TextLabel", bb)
    name.Size = UDim2.new(1, 0, 0, 25)
    name.BackgroundTransparency = 1
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.Text = displayText
    name.TextColor3 = Color3.fromRGB(255, 255, 0)
    name.TextStrokeTransparency = 0.5
    
    local value = Instance.new("TextLabel", bb)
    value.Size = UDim2.new(1, 0, 0, 25)
    value.Position = UDim2.new(0, 0, 0, 25)
    value.BackgroundTransparency = 1
    value.TextScaled = true
    value.Font = Enum.Font.GothamBold
    value.Text = valueText
    value.TextColor3 = Color3.fromRGB(0, 255, 100)
    value.TextStrokeTransparency = 0.5
    
    getgenv().BestPetESP.currentESP = bb
end

-- Loop de detecção
local function startESP()
    if getgenv().BestPetESP.active then 
        return 
    end
    getgenv().BestPetESP.active = true
    
    getgenv().BestPetESP.loop = task.spawn(function()
        while getgenv().BestPetESP.active do
            local debris = Workspace:FindFirstChild("Debris")
            if not debris then
                task.wait(0.5)
                continue
            end
            
            local bestPet = {value = -1, part = nil, text = "", display = "", template = nil}
            local templatesFound = 0
            
            -- Procura TODOS os FastOverheadTemplate dentro de Debris
            for _, template in ipairs(debris:GetChildren()) do
                if template.Name == "FastOverheadTemplate" then
                    templatesFound = templatesFound + 1
                    
                    -- Procura SurfaceGui dentro do template
                    local surfaceGui = template:FindFirstChildOfClass("SurfaceGui")
                    if not surfaceGui then
                        continue
                    end
                    
                    -- Procura Generation dentro do SurfaceGui (recursivo)
                    local genLabel = surfaceGui:FindFirstChild("Generation", true)
                    if not genLabel or not genLabel:IsA("TextLabel") then
                        continue
                    end
                    
                    local text = genLabel.Text or ""
                    
                    -- Valida se tem valor
                    if text ~= "" and (text:find("/s") or text:find("K") or text:find("M") or text:find("B")) then
                        local val = parseValue(text)
                        
                        if val > bestPet.value then
                            -- Pega o Adornee (parte 3D onde o GUI está anexado)
                            local targetPart = surfaceGui.Adornee
                            if targetPart and targetPart:IsA("BasePart") then
                                local displayName = surfaceGui:FindFirstChild("DisplayName", true)
                                bestPet = {
                                    part = targetPart,
                                    value = val,
                                    text = text,
                                    display = displayName and displayName.Text or "Pet",
                                    template = template
                                }
                            end
                        end
                    end
                end
            end
            
            -- Cria ESP no melhor pet
            if bestPet.part and bestPet.part.Parent then
                createESP(bestPet.part, bestPet.display, bestPet.text)
            end
            
            task.wait(0.5)
        end
        
        -- Limpa ESP ao parar
        if getgenv().BestPetESP.currentESP then
            pcall(function() getgenv().BestPetESP.currentESP:Destroy() end)
            getgenv().BestPetESP.currentESP = nil
        end
    end)
end

local function stopESP()
    getgenv().BestPetESP.active = false
    
    if getgenv().BestPetESP.loop then
        task.cancel(getgenv().BestPetESP.loop)
    end
    if getgenv().BestPetESP.currentESP then
        pcall(function() getgenv().BestPetESP.currentESP:Destroy() end)
        getgenv().BestPetESP.currentESP = nil
    end
end

-- Eski GUI varsa kaldır
local old = CoreGui:FindFirstChild("SimplePetESP")
if old then old:Destroy() end

-- Doğrudan başlat
startESP()
