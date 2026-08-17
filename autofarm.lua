-- San Diego Complete GUI v8 - ИСПРАВЛЕННАЯ ВЕРСИЯ
-- Исправлено: continue→goto, noclip на Jewelry, Bank таймер через GUI,
--             отдельные кнопки Jewelry/Bank, правильный BuyItem

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Удаляем старый GUI
if CoreGui:FindFirstChild("SmartGUI") then
    CoreGui:FindFirstChild("SmartGUI"):Destroy()
end

-- Remotes
local BankRobbery = RS.__remotes.BankRobbery
local WorldBuyableItem = RS.__remotes.WorldBuyableItemService.PurchaseWorldBuyableItem
local JewelleryService = RS.__remotes.JewelleryStoreService

-- Маршруты (встроенные)
local Routes = {
    -- Покупка предметов (CivilianArea рядом со спавном)
    buy_crowbar = Vector3.new(6826.94, 17.09, -8.90),
    buy_c4     = Vector3.new(6802.78, 20.29, -7.83),

    spawn_to_jewelry = {
        -- noclip_segments: диапазоны точек где включать noclip
        -- WP1→WP4 — весь путь через мост и город идёт с noclip
        noclip_from = 1,
        noclip_to   = 4,
        jewelry_cases = {
            Vector3.new(-28.35, 18.81, 900.27),
            Vector3.new(-48.08, 18.81, 900.50),
            Vector3.new(-57.78, 19.30, 895.37),
            Vector3.new(-57.78, 19.30, 941.95),
            Vector3.new(-28.51, 19.09, 945.15),
            Vector3.new(-48.08, 18.81, 945.15),
            Vector3.new(-57.78, 19.30, 951.02),
            Vector3.new(-57.78, 19.30, 904.55),
        },
        waypoints = {
            Vector3.new(6901.40, 19.74,  77.69),   -- 1 Спавн
            Vector3.new(6422.13, 18.91, 158.56),   -- 2
            Vector3.new(-114.48, 18.54, 160.28),   -- 3
            Vector3.new(-110.64, 18.57, 747.43),   -- 4 Вход в зону Jewelry
            Vector3.new(-199.92, 78.46, 931.56),   -- 5 Safe (fly+noclip к высокой точке)
        },
    },

    spawn_to_bank = {
        -- noclip включён на весь маршрут — много подземных стен
        trolley_check_waypoints = {9, 11},
        waypoints = {
            Vector3.new(6894.32, 20.37,  87.54),   -- 1
            Vector3.new(-111.54, 17.31,  86.23),   -- 2
            Vector3.new(-114.38, 17.90, -221.50),  -- 3
            Vector3.new(-246.81, 18.44, -224.20),  -- 4
            Vector3.new(-246.18, 16.82, -292.19),  -- 5
            Vector3.new(-192.54,  0.74, -289.76),  -- 6
            Vector3.new(-191.09,  0.70, -270.55),  -- 7
            Vector3.new(-267.91,  1.08, -272.10),  -- 8
            Vector3.new(-287.80,  0.31, -272.77),  -- 9  тележки
            Vector3.new(-287.36, -0.52, -301.56),  -- 10
            Vector3.new(-287.81, -0.47, -242.03),  -- 11 тележки
            Vector3.new(-285.89,  0.49, -271.12),  -- 12
            Vector3.new(-192.77,  0.71, -272.80),  -- 13
            Vector3.new(-192.34,  1.03, -287.99),  -- 14
            Vector3.new(-241.87, 18.78, -289.85),  -- 15
            Vector3.new(-245.46, 19.01, -223.25),  -- 16
        },
    },
}

-- Состояния фармов
local activeFarms = {jewelry = false, bank = false}
local noclipConnection = nil
local statusLabels = {}

-- ============ GUI БАЗА ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmartGUI"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 450)
Main.Position = UDim2.new(0.5, -160, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(225, 230, 235)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(200, 210, 220)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Cover = Instance.new("Frame")
Cover.Size = UDim2.new(1, 0, 0, 12)
Cover.Position = UDim2.new(0, 0, 1, -12)
Cover.BackgroundColor3 = Color3.fromRGB(200, 210, 220)
Cover.BorderSizePixel = 0
Cover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 1, 0)
Title.Position = UDim2.new(0, 13, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamMedium
Title.Text = "San Diego Farm v8"
Title.TextColor3 = Color3.fromRGB(60, 70, 80)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 24, 0, 24)
Close.Position = UDim2.new(1, -30, 0.5, -12)
Close.BackgroundColor3 = Color3.fromRGB(180, 190, 200)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 17
Close.TextColor3 = Color3.fromRGB(80, 90, 100)
Close.Parent = TopBar
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function()
    for k in pairs(activeFarms) do activeFarms[k] = false end
    ScreenGui:Destroy()
end)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -18, 0, 36)
TabBar.Position = UDim2.new(0, 9, 0, 46)
TabBar.BackgroundColor3 = Color3.fromRGB(210, 215, 220)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local TabPad = Instance.new("UIPadding")
TabPad.PaddingLeft = UDim.new(0, 5)
TabPad.PaddingTop = UDim.new(0, 5)
TabPad.PaddingBottom = UDim.new(0, 5)
TabPad.Parent = TabBar

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -18, 1, -102)
Content.Position = UDim2.new(0, 9, 0, 92)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(180, 190, 200)
Content.Parent = Main

local CL = Instance.new("UIListLayout")
CL.Padding = UDim.new(0, 8)
CL.Parent = Content

local CP = Instance.new("UIPadding")
CP.PaddingTop = UDim.new(0, 5)
CP.Parent = Content

-- ============ ДВИЖЕНИЕ ============
local function GetHRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function Noclip(on)
    if on and not noclipConnection then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    elseif not on and noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function WalkTo(pos, reachDist, useNoclip)
    local hrp = GetHRP()
    if not hrp then return false end

    reachDist = reachDist or 10
    if useNoclip then Noclip(true) end

    local start = tick()
    while tick() - start < 90 do
        hrp = GetHRP()
        if not hrp then break end

        local flat = Vector3.new(pos.X, hrp.Position.Y, pos.Z)
        local dist = (flat - hrp.Position).Magnitude

        if dist <= reachDist then
            hrp.AssemblyLinearVelocity = Vector3.zero
            if useNoclip then Noclip(false) end
            return true
        end

        local dir = (flat - hrp.Position).Unit
        hrp.AssemblyLinearVelocity = Vector3.new(dir.X * 250, hrp.AssemblyLinearVelocity.Y, dir.Z * 250)
        task.wait(0.05)
    end

    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    if useNoclip then Noclip(false) end
    return false
end

local function FlyTo(pos, reachDist, speed)
    local hrp = GetHRP()
    if not hrp then return false end

    reachDist = reachDist or 15
    speed = speed or 250
    Noclip(true)

    local start = tick()
    while tick() - start < 90 do
        hrp = GetHRP()
        if not hrp then break end

        local dist = (pos - hrp.Position).Magnitude
        if dist <= reachDist then
            hrp.AssemblyLinearVelocity = Vector3.zero
            Noclip(false)
            return true
        end

        local dir = (pos - hrp.Position).Unit
        hrp.AssemblyLinearVelocity = dir * speed
        task.wait(0.03)
    end

    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    Noclip(false)
    return false
end

-- ============ ФАРМ ФУНКЦИИ ============
local function HasItem(itemName)
    return LocalPlayer.Backpack:FindFirstChild(itemName) ~= nil or
           (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName) ~= nil)
end

local function BuyItem(itemPos, itemName)
    if HasItem(itemName) then return true end

    WalkTo(itemPos, 8, false)
    task.wait(0.5)

    -- Ищем ProximityPrompt в WorldBuyableItems
    for _, obj in pairs(workspace.WorldBuyableItems:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local dist = (parent.Position - itemPos).Magnitude
                if dist < 10 then
                    local actionText = obj.ActionText or ""
                    if actionText:lower():find("buy") or actionText:lower():find("купить") then
                        pcall(fireproximityprompt, obj)
                        task.wait(1.5)
                        if HasItem(itemName) then return true end
                    end
                end
            end
        end
    end

    return HasItem(itemName)
end

local function CheckJewelryTimer()
    local timerModel = workspace.JewelleryStore.Scriptable:FindFirstChild("JewelleryCooldownTimer")
    if not timerModel then return true end

    for _, obj in pairs(timerModel:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local text = obj.Text or ""
            if text:match("%d%d:%d%d") then
                if text ~= "00:00" then
                    -- Ждём открытия
                    while activeFarms.jewelry do
                        text = obj.Text or ""
                        if text == "00:00" or not text:match("%d%d:%d%d") then break end

                        if statusLabels.jewelry then
                            statusLabels.jewelry.Text = "💎 Jewelry\n⏰ Закрыт: " .. text
                        end
                        task.wait(5)
                    end

                    if not activeFarms.jewelry then return false end
                    task.wait(2)
                end
                break
            end
        end
    end
    return true
end

local function CheckBankTimer()
    -- Проверяем таймер через GUI (если есть)
    local bankModel = workspace.Bank:FindFirstChild("Scriptable")
    if bankModel then
        local timerModel = bankModel:FindFirstChild("BankCooldownTimer")
        if timerModel then
            for _, obj in pairs(timerModel:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    local text = obj.Text or ""
                    if text:match("%d%d:%d%d") then
                        if text ~= "00:00" then
                            while activeFarms.bank do
                                text = obj.Text or ""
                                if text == "00:00" or not text:match("%d%d:%d%d") then break end

                                if statusLabels.bank then
                                    statusLabels.bank.Text = "🏦 Bank\n⏰ Закрыт: " .. text
                                end
                                task.wait(5)
                            end

                            if not activeFarms.bank then return false end
                            task.wait(2)
                        end
                        break
                    end
                end
            end
        end
    end
    return true
end

local function FarmJewelry()
    -- Покупка Crowbar
    if not HasItem("Crowbar") then
        if statusLabels.jewelry then
            statusLabels.jewelry.Text = "💎 Jewelry\n🛒 Покупка Crowbar..."
        end
        if not BuyItem(Routes.buy_crowbar, "Crowbar") then
            if statusLabels.jewelry then
                statusLabels.jewelry.Text = "💎 Jewelry\n❌ Не удалось купить Crowbar"
            end
            return
        end
    end

    -- Проверка таймера
    if not CheckJewelryTimer() then return end

    -- Маршрут к ювелирке
    local route = Routes.spawn_to_jewelry
    if statusLabels.jewelry then
        statusLabels.jewelry.Text = "💎 Jewelry\n⏳ Идём к ювелирке..."
    end

    for i, wp in ipairs(route.waypoints) do
        if not activeFarms.jewelry then break end

        -- Последняя точка — fly+noclip вверх к safe
        if i == #route.waypoints then
            if statusLabels.jewelry then
                statusLabels.jewelry.Text = "💎 Jewelry\n🚁 Летим к safe..."
            end
            FlyTo(wp, 15, 250)
        else
            -- WP1-4: движение с noclip (через мост и стены)
            local useNoclip = (i >= route.noclip_from and i <= route.noclip_to)
            WalkTo(wp, 10, useNoclip)
        end
    end

    if not activeFarms.jewelry then return end

    -- Грабим витрины
    if statusLabels.jewelry then
        statusLabels.jewelry.Text = "💎 Jewelry\n⏳ Грабим витрины..."
    end

    for idx, casePos in ipairs(route.jewelry_cases) do
        if not activeFarms.jewelry then break end

        WalkTo(casePos, 5, false)
        task.wait(0.3)

        -- Ищем ProximityPrompt у витрин
        for _, obj in pairs(workspace.JewelleryStore:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") then
                local dist = (obj.Parent.Position - casePos).Magnitude
                if dist < 5 then
                    pcall(fireproximityprompt, obj)
                    task.wait(0.5)
                    break
                end
            end
        end
    end

    if statusLabels.jewelry then
        statusLabels.jewelry.Text = "💎 Jewelry\n✅ Завершено!"
    end
    task.wait(2)
end

local function FarmBank()
    -- Покупка C4
    if not HasItem("C4") then
        if statusLabels.bank then
            statusLabels.bank.Text = "🏦 Bank\n🛒 Покупка C4..."
        end
        if not BuyItem(Routes.buy_c4, "C4") then
            if statusLabels.bank then
                statusLabels.bank.Text = "🏦 Bank\n❌ Не удалось купить C4"
            end
            return
        end
    end

    -- Проверка таймера
    if not CheckBankTimer() then return end

    -- Маршрут к банку (весь с noclip)
    if statusLabels.bank then
        statusLabels.bank.Text = "🏦 Bank\n⏳ Идём к банку..."
    end

    Noclip(true)
    local route = Routes.spawn_to_bank

    for i, wp in ipairs(route.waypoints) do
        if not activeFarms.bank then
            Noclip(false)
            return
        end

        WalkTo(wp, 10, false) -- noclip уже включен глобально

        -- Грабим тележки на контрольных точках
        for _, checkIdx in ipairs(route.trolley_check_waypoints) do
            if i == checkIdx and activeFarms.bank then
                if statusLabels.bank then
                    statusLabels.bank.Text = "🏦 Bank\n💰 Грабим тележки..."
                end

                for _, trolley in pairs(workspace.Bank:GetDescendants()) do
                    if trolley.Name == "Trolley" and trolley:IsA("Model") then
                        local trolleyPos = trolley:GetPivot().Position
                        if (trolleyPos - wp).Magnitude < 25 then
                            pcall(function()
                                BankRobbery.StartRobTrolley:FireServer(trolley)
                            end)
                            task.wait(2)
                        end
                    end
                end
            end
        end
    end

    Noclip(false)

    if statusLabels.bank then
        statusLabels.bank.Text = "🏦 Bank\n✅ Завершено!"
    end
    task.wait(2)
end

-- ============ ВКЛАДКИ ============
local tabs = {}

local function CreateTab(name, icon)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 92, 0, 26)
    t.BackgroundColor3 = Color3.fromRGB(190, 200, 210)
    t.BorderSizePixel = 0
    t.Font = Enum.Font.Gotham
    t.Text = icon .. " " .. name
    t.TextSize = 10
    t.TextColor3 = Color3.fromRGB(70, 80, 90)
    t.AutoButtonColor = false
    t.Parent = TabBar
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
    tabs[name] = t
    return t
end

local function SwitchTab(name)
    -- Очищаем контент
    for _, c in pairs(Content:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then
            c:Destroy()
        end
    end

    -- Переключаем цвета вкладок
    for n, t in pairs(tabs) do
        if n == name then
            t.BackgroundColor3 = Color3.fromRGB(160, 180, 200)
            t.TextColor3 = Color3.fromRGB(40, 50, 60)
        else
            t.BackgroundColor3 = Color3.fromRGB(190, 200, 210)
            t.TextColor3 = Color3.fromRGB(70, 80, 90)
        end
    end

    if name == "Main" then
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, 0, 0, 75)
        info.BackgroundColor3 = Color3.fromRGB(210, 220, 230)
        info.BorderSizePixel = 0
        info.Font = Enum.Font.Gotham
        info.Text = "👤 Игрок: " .. LocalPlayer.Name .. "\n📊 Уровень: " .. (LocalPlayer:GetAttribute("Level") or "?") .. "\n\n✅ GUI v8 — Исправлены:\n• Застревания на маршрутах\n• Noclip на Jewelry\n• Таймеры банка"
        info.TextSize = 10
        info.TextColor3 = Color3.fromRGB(70, 80, 90)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.TextWrapped = true
        info.Parent = Content
        Instance.new("UICorner", info).CornerRadius = UDim.new(0, 7)

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingTop = UDim.new(0, 10)
        pad.Parent = info

    elseif name == "Farm" then
        -- Карточка Jewelry
        local jewelryCard = Instance.new("Frame")
        jewelryCard.Size = UDim2.new(1, 0, 0, 85)
        jewelryCard.BackgroundColor3 = Color3.fromRGB(210, 220, 230)
        jewelryCard.BorderSizePixel = 0
        jewelryCard.Parent = Content
        Instance.new("UICorner", jewelryCard).CornerRadius = UDim.new(0, 7)

        local jewelryStatus = Instance.new("TextLabel")
        jewelryStatus.Size = UDim2.new(1, -16, 0, 45)
        jewelryStatus.Position = UDim2.new(0, 8, 0, 5)
        jewelryStatus.BackgroundTransparency = 1
        jewelryStatus.Font = Enum.Font.GothamBold
        jewelryStatus.Text = "💎 Jewelry Store\n⚫ Остановлен"
        jewelryStatus.TextSize = 10
        jewelryStatus.TextColor3 = Color3.fromRGB(70, 80, 90)
        jewelryStatus.TextXAlignment = Enum.TextXAlignment.Left
        jewelryStatus.TextYAlignment = Enum.TextYAlignment.Top
        jewelryStatus.TextWrapped = true
        jewelryStatus.Parent = jewelryCard
        statusLabels.jewelry = jewelryStatus

        local jewelryBtn = Instance.new("TextButton")
        jewelryBtn.Size = UDim2.new(1, -16, 0, 28)
        jewelryBtn.Position = UDim2.new(0, 8, 1, -33)
        jewelryBtn.BackgroundColor3 = Color3.fromRGB(120, 180, 120)
        jewelryBtn.BorderSizePixel = 0
        jewelryBtn.Font = Enum.Font.GothamBold
        jewelryBtn.Text = "▶ СТАРТ"
        jewelryBtn.TextSize = 11
        jewelryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        jewelryBtn.Parent = jewelryCard
        Instance.new("UICorner", jewelryBtn).CornerRadius = UDim.new(0, 6)

        jewelryBtn.MouseButton1Click:Connect(function()
            if activeFarms.jewelry then
                activeFarms.jewelry = false
                jewelryBtn.Text = "▶ СТАРТ"
                jewelryBtn.BackgroundColor3 = Color3.fromRGB(120, 180, 120)
                jewelryStatus.Text = "💎 Jewelry Store\n⚫ Остановлен"
            else
                activeFarms.jewelry = true
                jewelryBtn.Text = "⏸ СТОП"
                jewelryBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 100)
                task.spawn(function()
                    while activeFarms.jewelry do
                        FarmJewelry()
                        if not activeFarms.jewelry then break end
                        task.wait(5)
                    end
                    jewelryStatus.Text = "💎 Jewelry Store\n⚫ Остановлен"
                end)
            end
        end)

        -- Карточка Bank
        local bankCard = Instance.new("Frame")
        bankCard.Size = UDim2.new(1, 0, 0, 85)
        bankCard.BackgroundColor3 = Color3.fromRGB(210, 220, 230)
        bankCard.BorderSizePixel = 0
        bankCard.Parent = Content
        Instance.new("UICorner", bankCard).CornerRadius = UDim.new(0, 7)

        local bankStatus = Instance.new("TextLabel")
        bankStatus.Size = UDim2.new(1, -16, 0, 45)
        bankStatus.Position = UDim2.new(0, 8, 0, 5)
        bankStatus.BackgroundTransparency = 1
        bankStatus.Font = Enum.Font.GothamBold
        bankStatus.Text = "🏦 Bank\n⚫ Остановлен"
        bankStatus.TextSize = 10
        bankStatus.TextColor3 = Color3.fromRGB(70, 80, 90)
        bankStatus.TextXAlignment = Enum.TextXAlignment.Left
        bankStatus.TextYAlignment = Enum.TextYAlignment.Top
        bankStatus.TextWrapped = true
        bankStatus.Parent = bankCard
        statusLabels.bank = bankStatus

        local bankBtn = Instance.new("TextButton")
        bankBtn.Size = UDim2.new(1, -16, 0, 28)
        bankBtn.Position = UDim2.new(0, 8, 1, -33)
        bankBtn.BackgroundColor3 = Color3.fromRGB(120, 180, 120)
        bankBtn.BorderSizePixel = 0
        bankBtn.Font = Enum.Font.GothamBold
        bankBtn.Text = "▶ СТАРТ"
        bankBtn.TextSize = 11
        bankBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bankBtn.Parent = bankCard
        Instance.new("UICorner", bankBtn).CornerRadius = UDim.new(0, 6)

        bankBtn.MouseButton1Click:Connect(function()
            if activeFarms.bank then
                activeFarms.bank = false
                Noclip(false)
                bankBtn.Text = "▶ СТАРТ"
                bankBtn.BackgroundColor3 = Color3.fromRGB(120, 180, 120)
                bankStatus.Text = "🏦 Bank\n⚫ Остановлен"
            else
                activeFarms.bank = true
                bankBtn.Text = "⏸ СТОП"
                bankBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 100)
                task.spawn(function()
                    while activeFarms.bank do
                        FarmBank()
                        if not activeFarms.bank then break end
                        task.wait(5)
                    end
                    Noclip(false)
                    bankStatus.Text = "🏦 Bank\n⚫ Остановлен"
                end)
            end
        end)

    elseif name == "Cards" then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 50)
        label.BackgroundColor3 = Color3.fromRGB(210, 220, 230)
        label.Text = "🃏 Игра в дурака\nВ разработке..."
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextColor3 = Color3.fromRGB(70, 80, 90)
        label.BorderSizePixel = 0
        label.Parent = Content
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 7)
    end
end

-- Создаём вкладки
CreateTab("Main", "🏠").MouseButton1Click:Connect(function() SwitchTab("Main") end)
CreateTab("Farm", "⚙️").MouseButton1Click:Connect(function() SwitchTab("Farm") end)
CreateTab("Cards", "🃏").MouseButton1Click:Connect(function() SwitchTab("Cards") end)

SwitchTab("Main")

-- Dragging
local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

ScreenGui.Parent = CoreGui

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("San Diego Farm GUI v8 загружен!")
print("✅ Исправлено:")
print("  • continue → убран (Luau)")
print("  • Noclip на Jewelry WP1-4")
print("  • Bank таймер через GUI")
print("  • Отдельные кнопки Jewelry/Bank")
print("  • BuyItem улучшен")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

