-- ============================================
-- == PHYSICS — отслеживание движения игрока ==
-- == Собирает скорость, поворот, ускорение ==
-- ============================================

local Physics = {}
Physics.__index = Physics

-- ══════════════════════════════════════════
-- СОЗДАНИЕ
-- ══════════════════════════════════════════
function Physics.new(torso, root, hum)
    local self = setmetatable({}, Physics)
    self.torso = torso
    self.root = root
    self.hum = hum

    -- История
    self.lastCF = root.CFrame
    self.smoothVel = Vector3.new()
    self.smoothAngular = Vector3.new()
    self.prevLocalVel = Vector3.new()

    -- Текущие значения (заполнятся в update)
    self.localVel = Vector3.new()
    self.localAccel = Vector3.new()
    self.speed = 0
    self.isJumping = false
    self.isFalling = false
    self.isRunning = false
    self.isIdle = true

    return self
end

-- ══════════════════════════════════════════
-- ОБНОВЛЕНИЕ (каждый кадр)
-- ══════════════════════════════════════════
function Physics:update(dt)
    dt = math.min(math.max(dt, 0.001), 1/30)

    -- Линейная скорость (клампим)
    local vel = self.root.AssemblyLinearVelocity
    if vel.Magnitude > 100 then
        vel = vel.Unit * 100
    end

    -- Угловая скорость (поворот персонажа)
    local cf = self.root.CFrame
    local diff = cf * self.lastCF:Inverse()
    local _, _, _, m00, m01, m02, m10, m11, m12, m20, m21, m22 = diff:GetComponents()
    local rawAngular = Vector3.new(m21 - m12, m02 - m20, m10 - m01) * 0.5 / dt
    if rawAngular.Magnitude > 5 then
        rawAngular = rawAngular.Unit * 5
    end
    self.lastCF = cf

    -- Сглаживание (убираем шум физики)
    self.smoothVel = self.smoothVel:Lerp(vel, math.min(dt * 15, 1))
    self.smoothAngular = self.smoothAngular:Lerp(rawAngular, math.min(dt * 10, 1))

    -- Локальная скорость (в осях торса)
    local localVel = self.torso.CFrame:VectorToObjectSpace(self.smoothVel)
    if localVel.Magnitude > 50 then
        localVel = localVel.Unit * 50
    end

    -- Ускорение (dVel/dt)
    local localAccel = (localVel - self.prevLocalVel) / dt
    if localAccel.Magnitude > 100 then
        localAccel = localAccel.Unit * 100
    end
    self.prevLocalVel = localVel

    -- Состояние Humanoid
    local state = self.hum:GetState()
    self.isJumping = state == Enum.HumanoidStateType.Jumping
    self.isFalling = state == Enum.HumanoidStateType.Freefall
    self.isRunning = state == Enum.HumanoidStateType.Running
        and math.abs(self.smoothVel.Magnitude) > 2
    self.isIdle = math.abs(self.smoothVel.Magnitude) < 1.5
    self.speed = self.smoothVel.Magnitude

    -- Сохраняем
    self.localVel = localVel
    self.localAccel = localAccel

    return self
end

-- ══════════════════════════════════════════
-- GETTER — удобные методы
-- ══════════════════════════════════════════
function Physics:getState()
    if self.isJumping then return "jump"
    elseif self.isFalling then return "fall"
    elseif self.isRunning then return "run"
    else return "idle" end
end

return Physics