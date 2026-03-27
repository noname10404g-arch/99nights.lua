-- I.S.-1 99 NIGHTS FARMER (РАБОЧАЯ ВЕРСИЯ ДЛЯ ANDROID)
-- БЕЗ ОБФУСКАЦИИ, ПРОСТОЙ, НО ЭФФЕКТИВНЫЙ

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- НАСТРОЙКИ (МОЖЕШЬ МЕНЯТЬ ПРЯМО В КОДЕ)
local settings = {
    autoAttack = true,      -- АВТОМАТИЧЕСКАЯ АТАКА
    autoCollect = true,     -- АВТОСБОР ПРЕДМЕТОВ
    autoUpgrade = true,     -- АВТОПРОКАЧКА (КНОПКИ В UI)
    attackSpeed = 0.2,      -- ЗАДЕРЖКА МЕЖДУ УДАРАМИ (СЕК)
    farmRange = 40          -- ДАЛЬНОСТЬ ПОИСКА ВРАГОВ
}

-- СОЗДАЁМ ПРОСТОЙ UI (НЕ БЛОКИРУЕТ ИГРУ)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IS1_99Nights"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 15, 0, 15)
MainFrame.Size = UDim2.new(0, 280, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "⚔️ I.S.-1 | 99 NIGHTS ⚔️"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
CloseBtn.TextSize = 20
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК-ТОГГЛОВ
local function addToggle(text, setting, yPos)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = text .. ": ✅ ВКЛ"
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    
    btn.MouseButton1Click:Connect(function()
        settings[setting] = not settings[setting]
        if settings[setting] then
            btn.Text = text .. ": ✅ ВКЛ"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        else
            btn.Text = text .. ": ❌ ВЫКЛ"
            btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        end
    end)
    
    return btn
end

addToggle("⚔️ АВТОАТАКА", "autoAttack", 45)
addToggle("💰 АВТОСБОР", "autoCollect", 95)
addToggle("⬆️ АВТОПРОКАЧКА", "autoUpgrade", 145)

-- СЛАЙДЕР СКОРОСТИ (ЧЕРЕЗ TEXTBOX)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 195)
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 25)
SpeedLabel.Text = "⚡ СКОРОСТЬ АТАКИ: " .. settings.attackSpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
SpeedLabel.BackgroundTransparency = 1

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = MainFrame
SpeedBox.Position = UDim2.new(0.05, 0, 0, 225)
SpeedBox.Size = UDim2.new(0.9, 0, 0, 35)
SpeedBox.Text = tostring(settings.attackSpeed)
SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 16

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val and val >= 0.05 and val <= 1 then
        settings.attackSpeed = val
        SpeedLabel.Text = "⚡ СКОРОСТЬ АТАКИ: " .. settings.attackSpeed
        SpeedBox.Text = tostring(settings.attackSpeed)
    else
        SpeedBox.Text = tostring(settings.attackSpeed)
    end
end)

-- ПОИСК ВРАГОВ
local function getEnemies()
    local enemies = {}
    local char = LocalPlayer.Character
    if not char then return enemies end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return enemies end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist < settings.farmRange then
                        table.insert(enemies, obj)
                    end
                end
            end
        end
    end
    return enemies
end

-- АВТОАТАКА (ЧЕРЕЗ ПОИСК КНОПКИ "ATTACK" ИЛИ КЛИК ПО ВРАГУ)
if settings.autoAttack then
    spawn(function()
        while true do
            if LocalPlayer.Character then
                local enemies = getEnemies()
                if #enemies > 0 then
                    local target = enemies[1]
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- ПОВОРАЧИВАЕМСЯ К ВРАГУ
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                            LocalPlayer.Character.HumanoidRootPart.Position,
                            hrp.Position
                        )
                        -- ПЫТАЕМСЯ НАЙТИ КНОПКУ АТАКИ В ИНТЕРФЕЙСЕ
                        local clicked = false
                        for _, gui in pairs(game:GetService("CoreGui"):GetDescendants()) do
                            if gui:IsA("TextButton") and gui.Visible then
                                local text = gui.Text:lower()
                                if text:find("attack") or text:find("fight") or text:find("hit") or text:find("strike") then
                                    gui:Click()
                                    clicked = true
                                    break
                                end
                            end
                        end
                        -- ЕСЛИ КНОПКИ НЕТ, ПЫТАЕМСЯ КЛИКНУТЬ ПО ВРАГУ
                        if not clicked then
                            local click = target:FindFirstChildOfClass("ClickDetector")
                            if click then click:Click() end
                        end
                        wait(settings.attackSpeed)
                    end
                end
            end
            wait(0.1)
        end
    end)
end

-- АВТОСБОР (ПРЕДМЕТЫ: МОНЕТЫ, КРИСТАЛЛЫ, DROP)
if settings.autoCollect then
    spawn(function()
        while true do
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("coin") or name:find("gem") or name:find("crystal") or name:find("drop") or name:find("reward") then
                        local click = obj:FindFirstChildOfClass("ClickDetector")
                        if click then
                            click:Click()
                            wait(0.05)
                        end
                    end
                end
            end
            wait(0.5)
        end
    end)
end

-- АВТОПРОКАЧКА (КЛИКАЕТ ПО КНОПКАМ "UPGRADE", "BUY", "LEVEL")
if settings.autoUpgrade then
    spawn(function()
        while true do
            for _, btn in pairs(game:GetService("CoreGui"):GetDescendants()) do
                if btn:IsA("TextButton") and btn.Visible then
                    local text = btn.Text:lower()
                    if text:find("upgrade") or text:find("buy") or text:find("level") or text:find("improve") then
                        btn:Click()
                        wait(0.2)
                    end
                end
            end
            wait(1)
        end
    end)
end

-- УВЕДОМЛЕНИЕ О ЗАПУСКЕ
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "I.S.-1 99 NIGHTS",
    Text = "✅ СКРИПТ АКТИВИРОВАН!\n⚔️ АВТОАТАКА + АВТОСБОР",
    Duration = 5
})

print("========================================")
print("I.S.-1 99 NIGHTS FARMER ЗАГРУЖЕН!")
print("⚔️ АВТОАТАКА, АВТОСБОР, АВТОПРОКАЧКА")
print("========================================")
