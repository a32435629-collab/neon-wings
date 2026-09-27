-- ============================================
-- == NEON WINGS — главный скрипт (точка входа) ==
-- == Автор: a32435629-collab ==
-- == Версия: 1.0.0 ==
-- ============================================

local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Подключение модулей
local Config = require(script.Parent.config)
local Utils = require(script.Parent.utils)
local Physics = require(script.Parent.physics)
local Wing = require(script.Parent.wing)
local Halo = require(script.Parent.halo)

-- ══════════════════════════════════════════
-- ИНИЦИАЛИЗАЦИЯ
-- ══════════════════════════════════════════
local char = plr.Character or plr.CharacterAdded:Wait()
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Удаляем старые
Utils.cleanup(torso, head)

-- Создаём папку
local folder = Instance.new("Folder")
folder.Name = "NeonWings"
folder.Parent = torso

-- ══════════════════════════════════════════
-- СОЗДАНИЕ КРЫЛЬЕВ
-- ══════════════════════════════════════════
local rightWing = Wing.create(torso, 1, Config)
rightWing.model.Parent = folder

local leftWing = Wing.create(torso, -1, Config)
leftWing.model.Parent = folder

-- ══════════════════════════════════════════
-- СОЗДАНИЕ НИМБА
-- ══════════════════════════════════════════
local haloData = Halo.create(head, Config)

-- ══════════════════════════════════════════
-- ФИЗИКА
-- ══════════════════════════════════════════
local physics = Physics.new(torso, root, hum)

-- ══════════════════════════════════════════
-- ЦВЕТ
-- ══════════════════════════════════════════
local hue = 0

local function getColor(t)
    if Config.ColorMode == "Rainbow" then
        hue = (hue + Config.HueSpeed) % 1
        return Color3.fromHSV((hue + t * 0.15) % 1, 1, 1)

    elseif Config.ColorMode == "Gradient" then
        local wave = (math.sin(t * 0.5 + tick() * 0.5) + 1) / 2
        return Config.ColorA:Lerp(Config.ColorB, wave)

    else  -- "Pulse"
        local pulse = (math.sin(tick() * 2) + 1) / 2
        return Config.ColorA:Lerp(Color3.new(1, 1, 1), pulse * 0.5)
    end
end

-- ══════════════════════════════════════════
-- УПРАВЛЕНИЕ
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- Вкл/выкл крылья
    if input.KeyCode == Config.ToggleWingsKey then
        Config.Enabled = not Config.Enabled
        if Config.Enabled then
            folder.Parent = torso
        else
            folder.Parent = nil
        end
        Utils.log("Крылья: " .. (Config.Enabled and "ON" or "OFF"), Config)
    end

    -- Вкл/выкл нимб
    if input.KeyCode == Config.ToggleHaloKey then
        Config.HaloEnabled = not Config.HaloEnabled
        if haloData then
            if Config.HaloEnabled then
                haloData.model.Parent = head
            else
                haloData.model.Parent = nil
            end
        end
        Utils.log("Нимб: " .. (Config.HaloEnabled and "ON" or "OFF"), Config)
    end
end)

-- ══════════════════════════════════════════
-- ГЛАВНЫЙ ЦИКЛ
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    if not char.Parent or not torso.Parent then return end
    if not Config.Enabled then return end

    -- Обновляем физику
    physics:update(dt)

    -- Обновляем крылья
    rightWing:update(physics, Config, dt, getColor)
    leftWing:update(physics, Config, dt, getColor)

    -- Обновляем нимб
    if haloData and Config.HaloEnabled then
        haloData:update(Config, dt, getColor)
    end
end)

-- ══════════════════════════════════════════
-- ОЧИСТКА ПРИ РЕСПАВНЕ
-- ══════════════════════════════════════════
plr.CharacterAdded:Connect(function(newChar)
    Utils.log("Персонаж сменился — перезапусти скрипт", Config)
end)

-- ══════════════════════════════════════════
-- СТАРТ
-- ══════════════════════════════════════════
Utils.log("========================================", Config)
Utils.log("  Neon Wings v1.0", Config)
Utils.log("  Автор: a32435629-collab", Config)
Utils.log("  G — вкл/выкл крылья", Config)
Utils.log("  H — вкл/выкл нимб", Config)
Utils.log("========================================", Config)