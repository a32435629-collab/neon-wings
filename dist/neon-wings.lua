-- ============================================
-- == NEON WINGS v1.0 (SINGLE FILE BUILD) ==
-- == Автор: a32435629-collab ==
-- == Для executor: скопируй всё и запусти ==
-- ============================================

local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ══════════════════════════════════════════
-- == CONFIG ==
-- ══════════════════════════════════════════
local Config = {
    ColorMode = "Gradient",
    ColorA = Color3.fromRGB(0, 200, 255),
    ColorB = Color3.fromRGB(180, 0, 255),
    HueSpeed = 0.003,

    SpineLength = 2.2,
    FeatherCount = 10,
    FeatherMin = 0.7,
    FeatherMax = 2.8,
    FeatherWidth = 0.12,
    FeatherThickness = 0.06,
    FeatherDropAngle = 75,

    AttachX = 0.5,
    AttachY = 0.7,
    AttachZ = 0.5,
    WingTiltBack = -50,
    WingTiltUp = 10,

    LeftWingExtraAxis = "Z",
    LeftWingExtraAngle = 122.5,

    LightBrightness = 0.3,
    LightRange = 2,

    SpringStiffness = 8,
    SpringDamping = 4,
    IdleFlapSpeed = 1.2,
    IdleFlapAmount = 3,
    RunFlapSpeed = 3,
    RunFlapAmount = 8,
    JumpFlapAmount = 25,
    FallFlapAmount = 20,
    WaveSpeed = 2,
    WaveAmount = 3,

    HaloEnabled = true,
    HaloRadius = 0.65,
    HaloThickness = 0.06,
    HaloHeight = 1.1,
    HaloSegments = 48,
    HaloSpinSpeed = 90,
    HaloLightBrightness = 1.0,
    HaloLightRange = 4,
    HaloBright = 1.0,
    HaloColorMode = "Rainbow",
    HaloHueSpeed = 0.15,
    HaloHueSpread = 1.0,

    ToggleWingsKey = Enum.KeyCode.G,
    ToggleHaloKey = Enum.KeyCode.H,
    Enabled = true,
    Debug = false,
}

-- ══════════════════════════════════════════
-- == UTILS ==
-- ══════════════════════════════════════════
local function spring(cur, target, vel, dt, stiffness, damping, maxVal)
    dt = math.min(dt, 1/30)
    local force = (target - cur) * stiffness
    local damp = math.exp(-damping * dt)
    vel = (vel + force * dt) * damp
    cur = cur + vel * dt
    if maxVal then
        cur = math.clamp(cur, -maxVal, maxVal)
        vel = math.clamp(vel, -maxVal * 10, maxVal * 10)
    end
    if cur ~= cur then cur = 0 end
    if vel ~= vel then vel = 0 end
    return cur, vel
end

local function makePart(size, name, parent)
    local p = Instance.new("Part")
    p.Name = name or "Part"
    p.Size = size
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(255, 255, 255)
    p.CanCollide = false
    p.Massless = true
    p.CastShadow = false
    p.Anchored = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function makeMotor(parent, child, c0, c1)
    local m = Instance.new("Motor6D")
    m.Part0 = parent
    m.Part1 = child
    m.C0 = c0 or CFrame.new()
    m.C1 = c1 or CFrame.new()
    m.Parent = child
    return m
end

local function buildExtraRotation(axis, angle)
    local a = math.rad(angle)
    if axis == "X" then return CFrame.Angles(a, 0, 0)
    elseif axis == "Y" then return CFrame.Angles(0, a, 0)
    else return CFrame.Angles(0, 0, a) end
end

local function cleanup(torso, head)
    if torso then
        local o = torso:FindFirstChild("NeonWings")
        if o then o:Destroy() end
    end
    if head then
        local o = head:FindFirstChild("NeonHalo")
        if o then o:Destroy() end
    end
end

-- ══════════════════════════════════════════
-- == ИНИЦИАЛИЗАЦИЯ ==
-- ══════════════════════════════════════════
local char = plr.Character or plr.CharacterAdded:Wait()
local torso = char:WaitForChild("Torso")
local head = char:WaitForChild("Head")
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

cleanup(torso, head)

local folder = Instance.new("Folder")
folder.Name = "NeonWings"
folder.Parent = torso

-- ══════════════════════════════════════════
-- == СОЗДАНИЕ КРЫЛА ==
-- ══════════════════════════════════════════
local function createWing(side)
    local model = Instance.new("Model")
    model.Name = side == 1 and "WingR" or "WingL"
    model.Parent = folder

    local feathers = {}

    local spine = makePart(
        Vector3.new(Config.SpineLength, 0.15, 0.15),
        "Spine", model
    )

    local wingAngleBack = math.rad(Config.WingTiltBack)
    local wingAngle90 = math.rad(side * 90)
    local wingAngleUp = math.rad(-Config.WingTiltUp * side)

    local baseC0 = CFrame.new(
        side * Config.AttachX,
        Config.AttachY,
        Config.AttachZ
    ) * CFrame.Angles(wingAngleBack, wingAngle90, wingAngleUp)

    if side == -1 then
        baseC0 = baseC0 * buildExtraRotation(
            Config.LeftWingExtraAxis,
            Config.LeftWingExtraAngle
        )
    end

    local spineMotor = makeMotor(torso, spine, baseC0)
    spineMotor.Name = "WingRoot"

    local spineLight = Instance.new("PointLight")
    spineLight.Brightness = Config.LightBrightness
    spineLight.Range = Config.LightRange
    spineLight.Shadows = false
    spineLight.Parent = spine

    for i = 1, Config.FeatherCount do
        local t = (i - 1) / (Config.FeatherCount - 1)
        local alongSpine = (t - 0.5) * Config.SpineLength
        local lengthCurve = math.sin(t * math.pi)
        local length = Config.FeatherMin + lengthCurve * (Config.FeatherMax - Config.FeatherMin)
        local dropAngle = Config.FeatherDropAngle - t * 20

        local feather = makePart(
            Vector3.new(Config.FeatherWidth, length, Config.FeatherThickness),
            "Feather", model
        )

        local c0 = CFrame.new(alongSpine, 0, 0)
            * CFrame.Angles(0, 0, math.rad(-dropAngle * side))
            * CFrame.new(0, -length / 2, 0)

        local m = makeMotor(spine, feather, c0)

        table.insert(feathers, {
            part = feather, motor = m, baseC0 = c0,
            t = t, length = length,
            bend = 0, bendVel = 0,
        })
    end

    -- Trail
    local longestIdx = 1
    local longestLen = 0
    for i, f in ipairs(feathers) do
        if f.length > longestLen then
            longestLen = f.length
            longestIdx = i
        end
    end
    local longest = feathers[longestIdx]

    local att0 = Instance.new("Attachment")
    att0.Position = Vector3.new(0, -longest.part.Size.Y / 2, 0)
    att0.Parent = longest.part

    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(0, -longest.part.Size.Y / 2, 0)
    att1.Parent = longest.part

    local trail = Instance.new("Trail")
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Lifetime = 0.4
    trail.MinLength = 0
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.LightEmission = 0.5
    trail.LightInfluence = 0
    trail.Parent = longest.part

    return {
        model = model, side = side, spine = spine,
        spineMotor = spineMotor, baseRootC0 = baseC0,
        spineLight = spineLight, feathers = feathers,
        trail = trail, flap = 0, flapVel = 0,
    }
end

local rightWing = createWing(1)
local leftWing = createWing(-1)

-- ══════════════════════════════════════════
-- == СОЗДАНИЕ НИМБА ==
-- ══════════════════════════════════════════
local haloData = nil

if Config.HaloEnabled then
    haloData = {
        model = Instance.new("Model"),
        segments = {},
        spin = 0,
        hue = 0,
    }
    haloData.model.Name = "NeonHalo"
    haloData.model.Parent = head

    haloData.anchor = makePart(
        Vector3.new(0.01, 0.01, 0.01),
        "HaloAnchor", haloData.model
    )
    haloData.anchor.Transparency = 1

    haloData.anchorMotor = makeMotor(
        head, haloData.anchor,
        CFrame.new(0, Config.HaloHeight, 0)
    )
    haloData.anchorMotor.Name = "HaloRoot"

    local segAngle = 360 / Config.HaloSegments
    local segLength = 2 * math.pi * Config.HaloRadius / Config.HaloSegments * 1.2

    for i = 1, Config.HaloSegments do
        local angle = math.rad((i - 1) * segAngle)
        local seg = makePart(
            Vector3.new(segLength, Config.HaloThickness, Config.HaloThickness),
            "HaloSeg" .. i, haloData.model
        )
        local ringPos = (i - 1) / Config.HaloSegments
        seg.Color = Color3.fromHSV(ringPos, 1, 1)

        local c0 = CFrame.new(
            math.cos(angle) * Config.HaloRadius,
            0,
            math.sin(angle) * Config.HaloRadius
        ) * CFrame.Angles(0, -angle, 0)

        local m = makeMotor(haloData.anchor, seg, c0)

        table.insert(haloData.segments, {
            part = seg, motor = m, ringPos = ringPos,
        })
    end

    haloData.light = Instance.new("PointLight")
    haloData.light.Brightness = Config.HaloLightBrightness
    haloData.light.Range = Config.HaloLightRange
    haloData.light.Shadows = false
    haloData.light.Parent = haloData.anchor
end

-- ══════════════════════════════════════════
-- == ФИЗИКА ==
-- ══════════════════════════════════════════
local physics = {
    lastCF = root.CFrame,
    smoothVel = Vector3.new(),
    smoothAngular = Vector3.new(),
    prevLocalVel = Vector3.new(),
    localVel = Vector3.new(),
    localAccel = Vector3.new(),
    speed = 0,
    isJumping = false,
    isFalling = false,
    isRunning = false,
    isIdle = true,
}

local function physicsUpdate(dt)
    dt = math.min(math.max(dt, 0.001), 1/30)

    local vel = root.AssemblyLinearVelocity
    if vel.Magnitude > 100 then vel = vel.Unit * 100 end

    local cf = root.CFrame
    local diff = cf * physics.lastCF:Inverse()
    local _, _, _, m00, m01, m02, m10, m11, m12, m20, m21, m22 = diff:GetComponents()
    local rawAngular = Vector3.new(m21 - m12, m02 - m20, m10 - m01) * 0.5 / dt
    if rawAngular.Magnitude > 5 then rawAngular = rawAngular.Unit * 5 end
    physics.lastCF = cf

    physics.smoothVel = physics.smoothVel:Lerp(vel, math.min(dt * 15, 1))
    physics.smoothAngular = physics.smoothAngular:Lerp(rawAngular, math.min(dt * 10, 1))

    local localVel = torso.CFrame:VectorToObjectSpace(physics.smoothVel)
    if localVel.Magnitude > 50 then localVel = localVel.Unit * 50 end

    local localAccel = (localVel - physics.prevLocalVel) / dt
    if localAccel.Magnitude > 100 then localAccel = localAccel.Unit * 100 end
    physics.prevLocalVel = localVel

    local state = hum:GetState()
    physics.isJumping = state == Enum.HumanoidStateType.Jumping
    physics.isFalling = state == Enum.HumanoidStateType.Freefall
    physics.isRunning = state == Enum.HumanoidStateType.Running
        and math.abs(physics.smoothVel.Magnitude) > 2
    physics.isIdle = math.abs(physics.smoothVel.Magnitude) < 1.5
    physics.speed = physics.smoothVel.Magnitude

    physics.localVel = localVel
    physics.localAccel = localAccel
end

-- ══════════════════════════════════════════
-- == ЦВЕТ ==
-- ══════════════════════════════════════════
local hue = 0

local function getColor(t)
    if Config.ColorMode == "Rainbow" then
        hue = (hue + Config.HueSpeed) % 1
        return Color3.fromHSV((hue + t * 0.15) % 1, 1, 1)
    elseif Config.ColorMode == "Gradient" then
        local wave = (math.sin(t * 0.5 + tick() * 0.5) + 1) / 2
        return Config.ColorA:Lerp(Config.ColorB, wave)
    else
        local pulse = (math.sin(tick() * 2) + 1) / 2
        return Config.ColorA:Lerp(Color3.new(1, 1, 1), pulse * 0.5)
    end
end

-- ══════════════════════════════════════════
-- == УПРАВЛЕНИЕ ==
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleWingsKey then
        Config.Enabled = not Config.Enabled
        folder.Parent = Config.Enabled and torso or nil
    end
    if input.KeyCode == Config.ToggleHaloKey and haloData then
        Config.HaloEnabled = not Config.HaloEnabled
        haloData.model.Parent = Config.HaloEnabled and head or nil
    end
end)

-- ══════════════════════════════════════════
-- == ГЛАВНЫЙ ЦИКЛ ==
-- ══════════════════════════════════════════
local function updateWing(wing, dt)
    local side = wing.side
    local t = tick()

    local targetFlap = 0
    if physics.isJumping then
        targetFlap = -Config.JumpFlapAmount
    elseif physics.isFalling then
        targetFlap = Config.FallFlapAmount
    elseif physics.isIdle then
        targetFlap = math.sin(t * Config.IdleFlapSpeed) * Config.IdleFlapAmount
    else
        targetFlap = math.clamp(physics.localVel.Z * 2, -15, 15)
    end

    wing.flap, wing.flapVel = spring(
        wing.flap, targetFlap, wing.flapVel, dt,
        Config.SpringStiffness, Config.SpringDamping, 45
    )

    wing.spineMotor.C0 = CFrame.Angles(0, 0, math.rad(wing.flap * side))
        * wing.baseRootC0

    for _, f in ipairs(wing.feathers) do
        local wave = math.sin(t * Config.WaveSpeed + f.t * 3) * Config.WaveAmount
            + physics.localVel.Y * 0.3
            - physics.speed * 0.1

        f.bend, f.bendVel = spring(
            f.bend, wave, f.bendVel, dt,
            Config.SpringStiffness * 0.8, Config.SpringDamping * 1.1, 20
        )

        f.motor.C0 = CFrame.Angles(0, 0, math.rad(f.bend * side)) * f.baseC0
        f.part.Color = getColor(f.t * 0.9)
    end

    wing.spineLight.Color = getColor(0)
    wing.spineLight.Brightness = Config.LightBrightness
        * (1 + math.min(physics.speed * 0.05, 0.5))

    if wing.trail then
        wing.trail.Color = ColorSequence.new(
            getColor(0.5),
            getColor(0.5):Lerp(Color3.new(1, 1, 1), 0.5)
        )
    end
end

local function updateHalo(dt)
    if not haloData or not Config.HaloEnabled then return end
    local t = tick()

    haloData.spin = (haloData.spin + dt * Config.HaloSpinSpeed) % 360
    haloData.hue = (haloData.hue + dt * Config.HaloHueSpeed) % 1

    local floatY = math.sin(t * 1.5) * 0.08
    haloData.anchorMotor.C0 = CFrame.new(0, Config.HaloHeight + floatY, 0)
        * CFrame.Angles(0, math.rad(haloData.spin), 0)

    if Config.HaloColorMode == "Rainbow" then
        for _, seg in ipairs(haloData.segments) do
            local segHue = (haloData.hue + seg.ringPos * Config.HaloHueSpread) % 1
            seg.part.Color = Color3.fromHSV(segHue, 1, 1) * Config.HaloBright
        end
        haloData.light.Color = Color3.fromHSV(haloData.hue, 1, 1)
    elseif Config.HaloColorMode == "MatchWings" then
        local c = getColor(0.2)
        for _, seg in ipairs(haloData.segments) do
            seg.part.Color = c * Config.HaloBright
        end
        haloData.light.Color = c
    else
        for _, seg in ipairs(haloData.segments) do
            seg.part.Color = Config.ColorA:Lerp(Config.ColorB, seg.ringPos)
                * Config.HaloBright
        end
        haloData.light.Color = Config.ColorA:Lerp(Config.ColorB, 0.5)
    end

    haloData.light.Brightness = Config.HaloLightBrightness
        * (1 + math.sin(t * 3) * 0.3)
end

RunService.Heartbeat:Connect(function(dt)
    if not char.Parent or not torso.Parent then return end
    if not Config.Enabled then return end

    physicsUpdate(dt)
    updateWing(rightWing, dt)
    updateWing(leftWing, dt)
    updateHalo(dt)
end)

-- ══════════════════════════════════════════
-- СТАРТ
-- ══════════════════════════════════════════
print("========================================")
print("  Neon Wings v1.0 загружено!")
print("  G — вкл/выкл крылья")
print("  H — вкл/выкл нимб")
print("  github.com/a32435629-collab/neon-wings")
print("========================================")