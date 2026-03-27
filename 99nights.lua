-- I.S.-1 99 NIGHTS FARMER (ANDROID FIX)
-- БЕЗ VIRTUALUSER, ТОЛЬКО CLICKDETECTOR

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- НАСТРОЙКИ
local settings = {
    autoAttack = true,
    autoCollect = true,
    autoUpgrade = true,
    attackSpeed = 0.2,
    farmRange = 50
}

-- СОЗДАЁМ UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NinetyNineFarmer"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "I.S.-1 | 99 NIGHTS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

-- ПОИСК ВРАГОВ
local function getEnemies()
    local enemies = {}
    local character = LocalPlayer.Character
    if not character then return enemies end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return enemies end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= character then
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

-- АВТОАТАКА (ЧЕРЕЗ CLICKDETECTOR)
if settings.autoAttack then
    spawn(function()
        while true do
            if LocalPlayer.Character then
                local enemies = getEnemies()
                if #enemies > 0 then
                    local target = enemies[1]
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- ПОВОРОТ К ВРАГУ
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                            LocalPlayer.Character.HumanoidRootPart.Position,
                            hrp.Position
                        )
                        -- ИЩЕМ КНОПКУ АТАКИ В UI
                        for _, btn in pairs(game:GetService("CoreGui"):GetDescendants()) do
                            if btn:IsA("TextButton") and (btn.Text:lower():find("attack") or btn.Text:lower():find("fight")) then
                                btn:Click()
                                break
                            end
                        end
                        wait(settings.attackSpeed)
                    end
                end
            end
            wait(0.1)
        end
    end)
end

-- АВТОСБОР (ПОДБИРАЕМ ДОБЫЧУ)
if settings.autoCollect then
    spawn(function()
        while true do
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("drop")) then
                    local click = obj:FindFirstChildOfClass("ClickDetector")
                    if click then
                        click:Click()
                    end
                    wait(0.05)
                end
            end
            wait(0.5)
        end
    end)
end

-- АВТОПРОКАЧКА
if settings.autoUpgrade then
    spawn(function()
        while true do
            for _, btn in pairs(game:GetService("CoreGui"):GetDescendants()) do
                if btn:IsA("TextButton") and (btn.Text:lower():find("upgrade") or btn.Text:lower():find("buy") or btn.Text:lower():find("level")) then
                    btn:Click()
                    wait(0.2)
                end
            end
            wait(1)
        end
    end)
end

-- УВЕДОМЛЕНИЕ
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "I.S.-1 99 NIGHTS",
    Text = "СКРИПТ АКТИВИРОВАН!\nАВТОАТАКА + АВТОСБОР",
    Duration = 5
})

print("========================================")
print("I.S.-1 99 NIGHTS FARMER (ANDROID) ЗАГРУЖЕН!")
print("АВТОАТАКА, АВТОСБОР, АВТОПРОКАЧКА")
print("========================================")
