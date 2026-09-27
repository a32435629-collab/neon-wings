-- ============================================
-- == CONFIG — все настройки в одном месте ==
-- ============================================

local Config = {}

-- ══════════════════════════════════════════
-- ЦВЕТА
-- ══════════════════════════════════════════
Config.ColorMode = "Gradient"                    -- "Rainbow" | "Gradient" | "Pulse"
Config.ColorA = Color3.fromRGB(0, 200, 255)      -- для Gradient
Config.ColorB = Color3.fromRGB(180, 0, 255)      -- для Gradient
Config.HueSpeed = 0.003                          -- скорость смены цвета

-- ══════════════════════════════════════════
-- ФОРМА КРЫЛА
-- ══════════════════════════════════════════
Config.SpineLength = 2.2
Config.FeatherCount = 10
Config.FeatherMin = 0.7
Config.FeatherMax = 2.8
Config.FeatherWidth = 0.12
Config.FeatherThickness = 0.06
Config.FeatherDropAngle = 75

-- ══════════════════════════════════════════
-- ПОЗИЦИЯ КРЫЛА
-- ══════════════════════════════════════════
Config.AttachX = 0.5
Config.AttachY = 0.7
Config.AttachZ = 0.5
Config.WingTiltBack = -50                        -- -50 = назад, 0 = в стороны
Config.WingTiltUp = 10                           -- 10 = чуть вверх

-- ══════════════════════════════════════════
-- ЛЕВОЕ КРЫЛО (доп. поворот для симметрии)
-- ══════════════════════════════════════════
Config.LeftWingExtraAxis = "Z"                   -- "X" | "Y" | "Z"
Config.LeftWingExtraAngle = 122.5                -- подбирал чтобы было зеркало

-- ══════════════════════════════════════════
-- СВЕТ
-- ══════════════════════════════════════════
Config.LightBrightness = 0.3
Config.LightRange = 2

-- ══════════════════════════════════════════
-- АНИМАЦИЯ
-- ══════════════════════════════════════════
Config.SpringStiffness = 8                       -- жёсткость пружины
Config.SpringDamping = 4                         -- затухание
Config.IdleFlapSpeed = 1.2
Config.IdleFlapAmount = 3
Config.RunFlapSpeed = 3
Config.RunFlapAmount = 8
Config.JumpFlapAmount = 25
Config.FallFlapAmount = 20
Config.WaveSpeed = 2
Config.WaveAmount = 3

-- ══════════════════════════════════════════
-- НИМБ
-- ══════════════════════════════════════════
Config.HaloEnabled = true
Config.HaloRadius = 0.65
Config.HaloThickness = 0.06
Config.HaloHeight = 1.1
Config.HaloSegments = 48
Config.HaloSpinSpeed = 90
Config.HaloLightBrightness = 1.0
Config.HaloLightRange = 4
Config.HaloBright = 1.0
Config.HaloColorMode = "Rainbow"                 -- "Rainbow" | "MatchWings" | "Gradient"
Config.HaloHueSpeed = 0.15
Config.HaloHueSpread = 1.0

-- ══════════════════════════════════════════
-- УПРАВЛЕНИЕ
-- ══════════════════════════════════════════
Config.ToggleWingsKey = Enum.KeyCode.G
Config.ToggleHaloKey = Enum.KeyCode.H
Config.Enabled = true
Config.Debug = false

return Config