-- ============================================
-- == HALO — неоновый нимб над головой ==
-- ============================================

local Utils = require(script.Parent.utils)

local Halo = {}
Halo.__index = Halo

-- ══════════════════════════════════════════
-- СОЗДАНИЕ НИМБА
-- ══════════════════════════════════════════
function Halo.create(head, config)
    if not config.HaloEnabled then return nil end

    local self = setmetatable({}, Halo)

    self.spin = 0
    self.hue = 0
    self.segments = {}

    -- Модель
    self.model = Instance.new("Model")
    self.model.Name = "NeonHalo"
    self.model.Parent = head

    -- Anchor (точка крепления)
    self.anchor = Utils.makePart(
        Vector3.new(0.01, 0.01, 0.01),
        "HaloAnchor",
        self.model
    )
    self.anchor.Transparency = 1

    -- Крепление к голове
    self.anchorMotor = Utils.makeMotor(
        head, self.anchor,
        CFrame.new(0, config.HaloHeight, 0)
    )
    self.anchorMotor.Name = "HaloRoot"

    -- ══ СЕГМЕНТЫ (48 штук кольцом) ══
    local segAngle = 360 / config.HaloSegments
    local segLength = 2 * math.pi * config.HaloRadius / config.HaloSegments * 1.2

    for i = 1, config.HaloSegments do
        local angle = math.rad((i - 1) * segAngle)

        local seg = Utils.makePart(
            Vector3.new(segLength, config.HaloThickness, config.HaloThickness),
            "HaloSeg" .. i,
            self.model
        )

        -- Позиция в круге
        local ringPos = (i - 1) / config.HaloSegments
        seg.Color = Color3.fromHSV(ringPos, 1, 1)

        -- CFrame
        local c0 = CFrame.new(
            math.cos(angle) * config.HaloRadius,
            0,
            math.sin(angle) * config.HaloRadius
        ) * CFrame.Angles(0, -angle, 0)

        local m = Utils.makeMotor(self.anchor, seg, c0)

        table.insert(self.segments, {
            part = seg,
            motor = m,
            ringPos = ringPos,
        })
    end

    -- ══ СВЕТ ══
    self.light = Instance.new("PointLight")
    self.light.Brightness = config.HaloLightBrightness
    self.light.Range = config.HaloLightRange
    self.light.Shadows = false
    self.light.Parent = self.anchor

    return self
end

-- ══════════════════════════════════════════
-- ОБНОВЛЕНИЕ АНИМАЦИИ
-- ══════════════════════════════════════════
function Halo:update(config, dt, getColor)
    local t = tick()

    -- Вращение
    self.spin = (self.spin + dt * config.HaloSpinSpeed) % 360
    self.hue = (self.hue + dt * config.HaloHueSpeed) % 1

    -- Парение вверх-вниз
    local floatY = math.sin(t * 1.5) * 0.08

    -- Применяем к anchor
    self.anchorMotor.C0 = CFrame.new(0, config.HaloHeight + floatY, 0)
        * CFrame.Angles(0, math.rad(self.spin), 0)

    -- ══ ЦВЕТ ══
    if config.HaloColorMode == "Rainbow" then
        -- Радуга по кругу
        for _, seg in ipairs(self.segments) do
            local segHue = (self.hue + seg.ringPos * config.HaloHueSpread) % 1
            seg.part.Color = Color3.fromHSV(segHue, 1, 1) * config.HaloBright
        end
        self.light.Color = Color3.fromHSV(self.hue, 1, 1)

    elseif config.HaloColorMode == "MatchWings" then
        -- Цвет как у крыльев
        local haloColor = getColor(0.2)
        for _, seg in ipairs(self.segments) do
            seg.part.Color = haloColor * config.HaloBright
        end
        self.light.Color = haloColor

    elseif config.HaloColorMode == "Gradient" then
        -- Градиент от ColorA к ColorB
        for _, seg in ipairs(self.segments) do
            seg.part.Color = config.ColorA:Lerp(config.ColorB, seg.ringPos)
                * config.HaloBright
        end
        self.light.Color = config.ColorA:Lerp(config.ColorB, 0.5)
    end

    -- Пульсация света
    self.light.Brightness = config.HaloLightBrightness
        * (1 + math.sin(t * 3) * 0.3)
end

-- ══════════════════════════════════════════
-- УДАЛЕНИЕ
-- ══════════════════════════════════════════
function Halo:destroy()
    if self.model then
        self.model:Destroy()
    end
end

return Halo