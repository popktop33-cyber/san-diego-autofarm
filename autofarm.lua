-- San Diego Complete GUI v7 - ПОЛНАЯ ВЕРСИЯ
-- Main, AutoFarm, Cards вкладки + рабочее движение

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Удаляем старый
if CoreGui:FindFirstChild("SmartGUI") then
    CoreGui:FindFirstChild("SmartGUI"):Destroy()
end

-- Remotes
local BankRobbery = RS.__remotes.BankRobbery

-- Маршруты (встроенные)
local Routes = {
    buy_crowbar = Vector3.new(6827.33, 17.48, -8.53),
    buy_c4 = Vector3.new(6802.78, 20.29, -7.83),

    spawn_to_jewelry = {
        jewelry_cases = {
            Vector3.new(-28.35, 18.81, 900.27), Vector3.new(-48.08, 18.81, 900.50),
            Vector3.new(-57.78, 19.30, 895.37), Vector3.new(-57.78, 19.30, 941.95),
            Vector3.new(-28.51, 19.09, 945.15), Vector3.new(-48.08, 18.81, 945.15),
            Vector3.new(-57.78, 19.30, 951.02), Vector3.new(-57.78, 19.30, 904.55),
        },
        waypoints = {
            Vector3.new(6901.40, 19.74, 77.69), Vector3.new(6422.13, 18.91, 158.56),
            Vector3.new(-114.48, 18.54, 160.28), Vector3.new(-110.64, 18.57, 747.43),
            Vector3.new(-199.92, 78.46, 931.56),
        }
    },
    spawn_to_bank = {
        trolley_check_waypoints = {9, 11},
        waypoints = {
            Vector3.new(6894.32, 20.37, 87.54), Vector3.new(-111.54, 17.31, 86.23),
            Vector3.new(-114.38, 17.90, -221.50), Vector3.new(-246.81, 18.44, -224.20),
            Vector3.new(-246.18, 16.82, -292.19), Vector3.new(-192.54, 0.74, -289.76),
            Vector3.new(-191.09, 0.70, -270.55), Vector3.new(-267.91, 1.08, -272.10),
            Vector3.new(-287.80, 0.31, -272.77), Vector3.new(-287.36, -0.52, -301.56),
            Vector3.new(-287.81, -0.47, -242.03), Vector3.new(-285.89, 0.49, -271.12),
            Vector3.new(-192.77, 0.71, -272.80), Vector3.new(-192.34, 1.03, -287.99),
            Vector3.new(-241.87, 18.78, -289.85), Vector3.new(-245.46, 19.01, -223.25),
        }
    }
}

local FARM_RUNNING = false
local noclipConnection = nil
local statusLabel, startButton

-- ============ GUI БАЗА (компактная) ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmartGUI"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(225, 230, 235)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
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
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamMedium
Title.Text = "San Diego Farm"
Title.TextColor3 = Color3.fromRGB(60, 70, 80)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 22, 0, 22)
Close.Position = UDim2.new(1, -28, 0.5, -11)
Close.BackgroundColor3 = Color3.fromRGB(180, 190, 200)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.TextColor3 = Color3.fromRGB(80, 90, 100)
Close.Parent = TopBar
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)
Close.MouseButton1Click:Connect(function() FARM_RUNNING = false ScreenGui:Destroy() end)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 35)
TabBar.Position = UDim2.new(0, 8, 0, 43)
TabBar.BackgroundColor3 = Color3.fromRGB(210, 215, 220)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 7)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local TabPad = Instance.new("UIPadding")
TabPad.PaddingLeft = UDim.new(0, 4)
TabPad.PaddingTop = UDim.new(0, 4)
TabPad.PaddingBottom = UDim.new(0, 4)
TabPad.Parent = TabBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -16, 1, -94)
Content.Position = UDim2.new(0, 8, 0, 86)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(180, 190, 200)
Content.Parent = Main

local CL = Instance.new("UIListLayout")
CL.Padding = UDim.new(0, 7)
CL.Parent = Content

local CP = Instance.new("UIPadding")
CP.PaddingTop = UDim.new(0, 4)
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

local function WalkTo(pos)
    local hrp = GetHRP()
    if not hrp then return false end
    local start = tick()
    while FARM_RUNNING and tick() - start < 90 do
        hrp = GetHRP()
        if not hrp then break end
        local flat = Vector3.new(pos.X, hrp.Position.Y, pos.Z)
        if (flat - hrp.Position).Magnitude <= 10 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        hrp.AssemblyLinearVelocity = Vector3.new((flat - hrp.Position).Unit.X * 250, hrp.AssemblyLinearVelocity.Y, (flat - hrp.Position).Unit.Z * 250)
        task.wait(0.05)
    end
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    return false
end

local function TeleportThroughWall(fromPos, toPos)
    -- Быстрый телепорт через стену с fly+noclip
    local hrp = GetHRP()
    if not hrp then return false end

    statusLabel.Text = "🏦 Bank\n⚡ Телепорт через стену..."

    Noclip(true)
    local start = tick()

    while FARM_RUNNING and tick() - start < 10 do
        hrp = GetHRP()
        if not hrp then break end

        if (toPos - hrp.Position).Magnitude <= 15 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            Noclip(false)
            return true
        end

        local direction = (toPos - hrp.Position).Unit
        hrp.AssemblyLinearVelocity = direction * 500  -- Высокая скорость

        task.wait(0.02)
    end

    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    Noclip(false)
    return false
end

local function FlyTo(pos)
    local hrp = GetHRP()
    if not hrp then return false end
    Noclip(true)
    local start = tick()
    while FARM_RUNNING and tick() - start < 90 do
        hrp = GetHRP()
        if not hrp then break end
        if (pos - hrp.Position).Magnitude <= 15 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            Noclip(false)
            return true
        end
        hrp.AssemblyLinearVelocity = (pos - hrp.Position).Unit * 250
        task.wait(0.03)
    end
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    Noclip(false)
    return false
end

-- ============ ФАРМ ============
local function HasItem(itemName)
    return LocalPlayer.Backpack:FindFirstChild(itemName) ~= nil or
           (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName) ~= nil)
end

local function BuyItem(itemPos, itemName)
    if HasItem(itemName) then return true end
    statusLabel.Text = "🛒 Покупка " .. itemName .. "..."
    WalkTo(itemPos)
    task.wait(0.5)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") then
            if (obj.Parent.Position - itemPos).Magnitude < 10 and obj.ActionText:lower():match("buy") then
                pcall(fireproximityprompt, obj)
                task.wait(1)
                return HasItem(itemName)
            end
        end
    end
    return false
end

local function CheckRobberyTimer(robberyType)
    if robberyType == "Jewelry" then
        -- Проверяем через GUI таймер
        local timerModel = workspace.JewelleryStore.Scriptable:FindFirstChild("JewelleryCooldownTimer")
        if timerModel then
            for _, obj in pairs(timerModel:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text:match("%d%d:%d%d") then
                    local timeText = obj.Text
                    if timeText ~= "00:00" then
                        statusLabel.Text = "⏰ Jewelry закрыт\n" .. timeText

                        -- Ждём пока откроется
                        while FARM_RUNNING do
                            task.wait(5)
                            timeText = obj.Text
                            if timeText == "00:00" or not timeText:match("%d%d:%d%d") then
                                break
                            end
                            statusLabel.Text = "⏰ Jewelry закрыт\n" .. timeText
                        end

                        if not FARM_RUNNING then return false end
                        task.wait(2)
                    end
                    break
                end
            end
        end
    elseif robberyType == "Bank" then
        -- Bank таймер (если есть)
        local timerAttr = LocalPlayer:GetAttribute("BankTimer") or 0
        if timerAttr > 0 then
            while timerAttr > 0 and FARM_RUNNING do
                timerAttr = LocalPlayer:GetAttribute("BankTimer") or 0
                statusLabel.Text = string.format("⏰ Bank закрыт\nОсталось: %d сек", timerAttr)
                task.wait(5)
            end
            if not FARM_RUNNING then return false end
            task.wait(2)
        end
    end
    return true
end

local function FarmJewelry()
    if not HasItem("Crowbar") then BuyItem(Routes.buy_crowbar, "Crowbar") end
    if not CheckRobberyTimer("Jewelry") then return end
    statusLabel.Text = "💎 Jewelry\n⏳ Идём..."
    local r = Routes.spawn_to_jewelry
    for i, wp in ipairs(r.waypoints) do
        if not FARM_RUNNING then break end
        if i == #r.waypoints then
            statusLabel.Text = "💎 Jewelry\n⏳ Летим к safe (fly+noclip)..."
            FlyTo(wp)
        else
            WalkTo(wp)
        end
    end
    if not FARM_RUNNING then return end
    statusLabel.Text = "💎 Jewelry\n⏳ Грабим витрины..."
    for _, cpos in ipairs(r.jewelry_cases) do
        if not FARM_RUNNING then break end
        WalkTo(cpos)
        for _, obj in pairs(workspace.JewelleryStore:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") and (obj.Parent.Position - cpos).Magnitude < 5 then
                pcall(fireproximityprompt, obj)
                task.wait(0.5)
                break
            end
        end
    end
    statusLabel.Text = "💎 Jewelry\n✅ Готово!"
end

local function FarmBank()
    if not HasItem("C4") then BuyItem(Routes.buy_c4, "C4") end
    if not CheckRobberyTimer("Bank") then return end

    -- Включаем noclip на весь Bank маршрут (много препятствий)
    Noclip(true)

    statusLabel.Text = "🏦 Bank\n⏳ Идём..."
    local r = Routes.spawn_to_bank
    for i, wp in ipairs(r.waypoints) do
        if not FARM_RUNNING then break end
        if i == 12 then
            statusLabel.Text = "🏦 Bank\n⚡ Телепорт через стену..."
            TeleportThroughWall(r.waypoints[11], r.waypoints[12])
            task.wait(0.5)
            continue
        end
        WalkTo(wp)
        for _, ck in ipairs(r.trolley_check_waypoints) do
            if i == ck and FARM_RUNNING then
                statusLabel.Text = "🏦 Bank\n⏳ Грабим тележки..."
                for _, tr in pairs(workspace.Bank:GetDescendants()) do
                    if tr.Name == "Trolley" and tr:IsA("Model") and (tr:GetPivot().Position - wp).Magnitude < 25 then
                        pcall(function() BankRobbery.StartRobTrolley:FireServer(tr) end)
                        task.wait(2)
                    end
                end
            end
        end
    end

    -- Выключаем noclip после Bank
    Noclip(false)
    statusLabel.Text = "🏦 Bank\n✅ Готово!"
end

-- ============ ВКЛАДКИ ============
local tabs = {}
local function CreateTab(name, ico)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 88, 0, 27)
    t.BackgroundColor3 = Color3.fromRGB(190, 200, 210)
    t.BorderSizePixel = 0
    t.Font = Enum.Font.Gotham
    t.Text = ico .. " " .. name
    t.TextSize = 10
    t.TextColor3 = Color3.fromRGB(70, 80, 90)
    t.AutoButtonColor = false
    t.Parent = TabBar
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
    tabs[name] = t
    return t
end

local function Switch(name)
    for _, c in pairs(Content:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then c:Destroy() end
    end
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
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 70)
        l.BackgroundColor3 = Color3.fromRGB(210, 220, 230)
        l.BorderSizePixel = 0
        l.Font = Enum.Font.Gotham
        l.Text = "Игрок: " .. LocalPlayer.Name .. "\nУровень: " .. (LocalPlayer:GetAttribute("Level") or 1)
        l.TextSize = 11
        l.TextColor3 = Color3.fromRGB(70, 80, 90)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.Parent = Content
        Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 10)
        p.PaddingTop = UDim.new(0, 10)
        p.Parent = l

    elseif name == "Farm" then
        statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 0, 55)
        statusLabel.BackgroundColor3 = Color3.fromRGB(210, 220, 230)
        statusLabel.BorderSizePixel = 0
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Text = "⚫ Фарм остановлен"
        statusLabel.TextSize = 11
        statusLabel.TextColor3 = Color3.fromRGB(70, 80, 90)
        statusLabel.TextWrapped = true
        statusLabel.Parent = Content
        Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 6)
        local sp = Instance.new("UIPadding")
        sp.PaddingLeft = UDim.new(0, 8)
        sp.PaddingTop = UDim.new(0, 8)
        sp.Parent = statusLabel

        startButton = Instance.new("TextButton")
        startButton.Size = UDim2.new(1, 0, 0, 40)
        startButton.BackgroundColor3 = Color3.fromRGB(120, 180, 120)
        startButton.BorderSizePixel = 0
        startButton.Font = Enum.Font.GothamBold
        startButton.Text = "▶ СТАРТ ФАРМ"
        startButton.TextSize = 13
        startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        startButton.Parent = Content
        Instance.new("UICorner", startButton).CornerRadius = UDim.new(0, 6)

        startButton.MouseButton1Click:Connect(function()
            if FARM_RUNNING then
                FARM_RUNNING = false
                Noclip(false)  -- Выключаем noclip при остановке
                startButton.Text = "▶ СТАРТ ФАРМ"
                startButton.BackgroundColor3 = Color3.fromRGB(120, 180, 120)
                statusLabel.Text = "⚫ Фарм остановлен"
            else
                FARM_RUNNING = true
                startButton.Text = "⏸ СТОП ФАРМ"
                startButton.BackgroundColor3 = Color3.fromRGB(180, 100, 100)
                task.spawn(function()
                    while FARM_RUNNING do
                        FarmJewelry()
                        if not FARM_RUNNING then break end
                        task.wait(2)
                        FarmBank()
                        if not FARM_RUNNING then break end
                        task.wait(5)
                    end
                    Noclip(false)  -- Выключаем после завершения
                end)
            end
        end)

        local b1 = Instance.new("TextButton")
        b1.Size = UDim2.new(1, 0, 0, 32)
        b1.BackgroundColor3 = Color3.fromRGB(200, 210, 220)
        b1.Text = "Jewelry Store"
        b1.Font = Enum.Font.Gotham
        b1.TextSize = 11
        b1.TextColor3 = Color3.fromRGB(70, 80, 90)
        b1.TextXAlignment = Enum.TextXAlignment.Left
        b1.BorderSizePixel = 0
        b1.Parent = Content
        Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 6)
        Instance.new("UIPadding", b1).PaddingLeft = UDim.new(0, 10)

        local b2 = Instance.new("TextButton")
        b2.Size = UDim2.new(1, 0, 0, 32)
        b2.BackgroundColor3 = Color3.fromRGB(200, 210, 220)
        b2.Text = "Bank"
        b2.Font = Enum.Font.Gotham
        b2.TextSize = 11
        b2.TextColor3 = Color3.fromRGB(70, 80, 90)
        b2.TextXAlignment = Enum.TextXAlignment.Left
        b2.BorderSizePixel = 0
        b2.Parent = Content
        Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 6)
        Instance.new("UIPadding", b2).PaddingLeft = UDim.new(0, 10)

    elseif name == "Cards" then
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 45)
        l.BackgroundColor3 = Color3.fromRGB(210, 220, 230)
        l.Text = "🃏 Игра в дурака\nВ разработке..."
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextColor3 = Color3.fromRGB(70, 80, 90)
        l.BorderSizePixel = 0
        l.Parent = Content
        Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)
    end
end

CreateTab("Main", "🏠").MouseButton1Click:Connect(function() Switch("Main") end)
CreateTab("Farm", "⚙️").MouseButton1Click:Connect(function() Switch("Farm") end)
CreateTab("Cards", "🃏").MouseButton1Click:Connect(function() Switch("Cards") end)

Switch("Main")

-- Dragging
local drag, dstart, spos
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dstart = i.Position
        spos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dstart
        Main.Position = UDim2.new(spos.X.Scale, spos.X.Offset + d.X, spos.Y.Scale, spos.Y.Offset + d.Y)
    end
end)

ScreenGui.Parent = CoreGui
print("[GUI V7] Main/Farm/Cards вкладки + РАБОЧЕЕ ДВИЖЕНИЕ!")
