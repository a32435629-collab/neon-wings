-- ============================================
-- == WING — создание и анимация крыла ==
-- == v1.0.7 (Mode 2 — симметрия) ==
-- ============================================

local Utils = require(script.Parent.utils)

local Wing = {}
Wing.__index = Wing

-- ══════════════════════════════════════════
-- СОЗДАНИЕ КРЫЛА
-- ══════════════════════════════════════════
function Wing.create(torso, side, config)
    local self = setmetatable({}, Wing)

    self.side = side
    self.feathers = {}
    self.flap = 0
    self.flapVel = 0

    -- Модель для группировки
    self.model = Instance.new("Model")
    self.model.Name = side == 1 and "WingR" or "WingL"

    -- ══ SPINE (кость крыла) ══
    local spine = Utils.makePart(
        Vector3.new(config.SpineLength, 0.15, 0.15),
        "Spine",
        self.model
    )
    self.spine = spine

    -- ══ КРЕПЛЕНИЕ (Mode 2: все углы БЕЗ side) ══
    local baseC0 = CFrame.new(
        side * config.AttachX,
        config.AttachY,
        config.AttachZ
    ) * CFrame.Angles(
        math.rad(config.WingTiltBack),   -- Rx
        math.rad(90),                    -- Ry (без side)
        math.rad(-config.WingTiltUp)     -- Rz (без side)
    )

    self.baseRootC0 = baseC0

    -- Motor6D для корня
    self.spineMotor = Utils.makeMotor(torso, spine, baseC0)
    self.spineMotor.Name = "WingRoot"

    -- Свет
    self.spineLight = Instance.new("PointLight")
    self.spineLight.Brightness = config.LightBrightness
    self.spineLight.Range = config.LightRange
    self.spineLight.Shadows = false
    self.spineLight.Parent = spine

    -- ══ ПЕРЬЯ ══
    for i = 1, config.FeatherCount do
        local t = (i - 1) / (config.FeatherCount - 1)
        local alongSpine = (t - 0.5) * config.SpineLength

        -- Длина: короткие → длинные → средние
        local lengthCurve = math.sin(t * math.pi)
        local length = config.FeatherMin + lengthCurve * (config.FeatherMax - config.FeatherMin)

        -- Угол свисания
        local dropAngle = config.FeatherDropAngle - t * 20

        local feather = Utils.makePart(
            Vector3.new(config.FeatherWidth, length, config.FeatherThickness),
            "Feather",
            self.model
        )

        -- ⭐ Mode 2: перья БЕЗ side
        local c0 = CFrame.new(alongSpine, 0, 0)
            * CFrame.Angles(0, 0, math.rad(-dropAngle))
            * CFrame.new(0, -length / 2, 0)

        local m = Utils.makeMotor(spine, feather, c0)

        table.insert(self.feathers, {
            part = feather,
            motor = m,
            baseC0 = c0,
            t = t,
            length = length,
            bend = 0,
            bendVel = 0,
        })
    end

    -- ══ TRAIL на самом длинном пере ══
    local longestIdx = 1
    local longestLen = 0
    for i, f in ipairs(self.feathers) do
        if f.length > longestLen then
            longestLen = f.length
            longestIdx = i
        end
    end
    local longest = self.feathers[longestIdx]

    local att0 = Instance.new("Attachment")
    att0.Position = Vector3.new(0, -longest.part.Size.Y / 2, 0)
    att0.Parent = longest.part

    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(0, -longest.part.Size.Y / 2, 0)
    att1.Parent = longest.part

    self.trail = Instance.new("Trail")
    self.trail.Attachment0 = att0
    self.trail.Attachment1 = att1
    self.trail.Lifetime = 0.4
    self.trail.MinLength = 0
    self.trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    self.trail.LightEmission = 0.5
    self.trail.LightInfluence = 0
    self.trail.Parent = longest.part

    return self
end

-- ══════════════════════════════════════════
-- ОБНОВЛЕНИЕ АНИМАЦИИ
-- ══════════════════════════════════════════
function Wing:update(physics, config, dt, getColor)
    local side = self.side
    local t = tick()

    -- ══ ЦЕЛЕВОЙ МАХ ══
    local targetFlap = 0
    if physics.isJumping then
        targetFlap = -config.JumpFlapAmount
    elseif physics.isFalling then
        targetFlap = config.FallFlapAmount
    elseif physics.isIdle then
        targetFlap = math.sin(t * config.IdleFlapSpeed) * config.IdleFlapAmount
    else
        targetFlap = math.clamp(physics.localVel.Z * 2, -15, 15)
    end

    -- Пружина для маха
    self.flap, self.flapVel = Utils.spring(
        self.flap, targetFlap, self.flapVel, dt,
        config.SpringStiffness, config.SpringDamping, 45
    )

    -- ⭐ Мах — С side (чтобы крылья махали симметрично)
    self.spineMotor.C0 = CFrame.Angles(0, 0, math.rad(self.flap * side))
        * self.baseRootC0

    -- ══ ПЕРЬЯ ══
    for _, f in ipairs(self.feathers) do
        local wave = math.sin(t * config.WaveSpeed + f.t * 3) * config.WaveAmount
            + physics.localVel.Y * 0.3
            - physics.speed * 0.1

        f.bend, f.bendVel = Utils.spring(
            f.bend, wave, f.bendVel, dt,
            config.SpringStiffness * 0.8,
            config.SpringDamping * 1.1,
            20
        )

        -- ⭐ Mode 2: bend БЕЗ side
        f.motor.C0 = CFrame.Angles(0, 0, math.rad(f.bend)) * f.baseC0
        f.part.Color = getColor(f.t * 0.9)
    end

    -- Свет
    self.spineLight.Color = getColor(0)
    self.spineLight.Brightness = config.LightBrightness
        * (1 + math.min(physics.speed * 0.05, 0.5))

    -- Trail
    if self.trail then
        self.trail.Color = ColorSequence.new(
            getColor(0.5),
            getColor(0.5):Lerp(Color3.new(1, 1, 1), 0.5)
        )
    end
end

-- ══════════════════════════════════════════
-- УДАЛЕНИЕ
-- ══════════════════════════════════════════
function Wing:destroy()
    if self.model then
        self.model:Destroy()
    end
end

return Wing
