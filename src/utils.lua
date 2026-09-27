-- ============================================
-- == UTILS — вспомогательные функции ==
-- ============================================

local Utils = {}

-- ══════════════════════════════════════════
-- SPRING — пружина с затуханием
-- ══════════════════════════════════════════
function Utils.spring(cur, target, vel, dt, stiffness, damping, maxVal)
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

-- ══════════════════════════════════════════
-- MAKE PART — создать неоновую часть
-- ══════════════════════════════════════════
function Utils.makePart(size, name, parent)
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

-- ══════════════════════════════════════════
-- MAKE MOTOR — создать Motor6D
-- ══════════════════════════════════════════
function Utils.makeMotor(parent, child, c0, c1)
    local m = Instance.new("Motor6D")
    m.Part0 = parent
    m.Part1 = child
    m.C0 = c0 or CFrame.new()
    m.C1 = c1 or CFrame.new()
    m.Parent = child
    return m
end

-- ══════════════════════════════════════════
-- MAKE WELD — создать Weld
-- ══════════════════════════════════════════
function Utils.makeWeld(parent, child, c0, c1)
    local w = Instance.new("Weld")
    w.Part0 = parent
    w.Part1 = child
    w.C0 = c0 or CFrame.new()
    w.C1 = c1 or CFrame.new()
    w.Parent = child
    return w
end

-- ══════════════════════════════════════════
-- BUILD EXTRA ROTATION — доп. поворот левого крыла
-- ══════════════════════════════════════════
function Utils.buildExtraRotation(axis, angle)
    local a = math.rad(angle)
    if axis == "X" then
        return CFrame.Angles(a, 0, 0)
    elseif axis == "Y" then
        return CFrame.Angles(0, a, 0)
    else
        return CFrame.Angles(0, 0, a)
    end
end

-- ══════════════════════════════════════════
-- LOG — лог с префиксом
-- ══════════════════════════════════════════
function Utils.log(msg, config)
    if config and config.Debug then
        print("[NeonWings] " .. tostring(msg))
    end
end

-- ══════════════════════════════════════════
-- CLEANUP — удалить старые крылья и нимб
-- ══════════════════════════════════════════
function Utils.cleanup(torso, head)
    if torso then
        local old = torso:FindFirstChild("NeonWings")
        if old then old:Destroy() end
    end
    if head then
        local oldHalo = head:FindFirstChild("NeonHalo")
        if oldHalo then oldHalo:Destroy() end
    end
end

return Utils