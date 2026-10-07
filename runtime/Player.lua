local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = {}

function Player:Create()
    local localPlayer = Players.LocalPlayer
    local connections = {}
    local humanoidOriginals = setmetatable({}, { __mode = "k" })
    local collisionOriginals = setmetatable({}, { __mode = "k" })
    local ragdollAttributeOriginals = setmetatable({}, { __mode = "k" })
    local lightingOriginals
    local lastSafeCFrame
    local impactUntil = 0
    local returnPending = false
    local destroyed = false
    local settings = {
        WalkSpeed = nil,
        JumpBoost = nil,
        Noclip = false,
        FullBright = false,
        AntiRagdoll = false,
        AntiKnockback = false,
        KnockbackThreshold = 55,
    }

    local runtime = {}

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function currentCharacter()
        return localPlayer and localPlayer.Character
    end

    local function currentHumanoid()
        local character = currentCharacter()
        return character and character:FindFirstChildOfClass("Humanoid")
    end

    local function currentRootPart()
        local character = currentCharacter()
        return character and character:FindFirstChild("HumanoidRootPart")
    end

    local function rememberHumanoid(humanoid)
        if humanoid and not humanoidOriginals[humanoid] then
            humanoidOriginals[humanoid] = {
                WalkSpeed = humanoid.WalkSpeed,
                UseJumpPower = humanoid.UseJumpPower,
                JumpPower = humanoid.JumpPower,
                JumpHeight = humanoid.JumpHeight,
                PlatformStand = humanoid.PlatformStand,
                AutoRotate = humanoid.AutoRotate,
                RagdollEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Ragdoll),
                FallingDownEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown),
            }
        end
        return humanoid and humanoidOriginals[humanoid]
    end

    local function applyMovement()
        local humanoid = currentHumanoid()
        if not humanoid or humanoid.Health <= 0 then return end

        local originals = rememberHumanoid(humanoid)
        if settings.WalkSpeed ~= nil then
            humanoid.WalkSpeed = settings.WalkSpeed
        end
        if settings.JumpBoost ~= nil then
            if originals.UseJumpPower then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = originals.JumpPower * settings.JumpBoost
            else
                humanoid.UseJumpPower = false
                humanoid.JumpHeight = originals.JumpHeight * settings.JumpBoost
            end
        end
    end

    local function applyNoclip()
        local character = currentCharacter()
        if not character then return end

        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if collisionOriginals[descendant] == nil then
                    collisionOriginals[descendant] = { CanCollide = descendant.CanCollide }
                end
                descendant.CanCollide = false
            end
        end
    end

    local function restoreCollision()
        for part, original in pairs(collisionOriginals) do
            if part and part.Parent then part.CanCollide = original.CanCollide end
            collisionOriginals[part] = nil
        end
    end

    local function captureLighting()
        return {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ExposureCompensation = Lighting.ExposureCompensation,
        }
    end

    local function applyFullBright()
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ExposureCompensation = 0
    end

    local function restoreLighting()
        if not lightingOriginals then return end
        for property, value in pairs(lightingOriginals) do
            Lighting[property] = value
        end
        lightingOriginals = nil
    end

    local function rememberRagdollAttribute(character)
        if character and not ragdollAttributeOriginals[character] then
            local value = character:GetAttribute("RAGDOLL_FORCE_DISABLE")
            ragdollAttributeOriginals[character] = {
                HadValue = value ~= nil,
                Value = value,
            }
        end
    end

    local function applyAntiRagdoll()
        local character = currentCharacter()
        local humanoid = currentHumanoid()
        if not character or not humanoid or humanoid.Health <= 0 then return end

        rememberRagdollAttribute(character)
        rememberHumanoid(humanoid)
        character:SetAttribute("RAGDOLL_FORCE_DISABLE", true)
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown
            or state == Enum.HumanoidStateType.Physics then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    local function restoreAntiRagdoll()
        for humanoid, originals in pairs(humanoidOriginals) do
            if humanoid and humanoid.Parent then
                humanoid.PlatformStand = originals.PlatformStand
                humanoid.AutoRotate = originals.AutoRotate
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, originals.RagdollEnabled)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, originals.FallingDownEnabled)
            end
        end

        for character, original in pairs(ragdollAttributeOriginals) do
            if character and character.Parent then
                if original.HadValue then
                    character:SetAttribute("RAGDOLL_FORCE_DISABLE", original.Value)
                else
                    character:SetAttribute("RAGDOLL_FORCE_DISABLE", nil)
                end
            end
            ragdollAttributeOriginals[character] = nil
        end
    end

    local function rememberSafePosition()
        local humanoid = currentHumanoid()
        local rootPart = currentRootPart()
        if not humanoid or not rootPart or humanoid.Health <= 0 then return end
        if humanoid.FloorMaterial == Enum.Material.Air then return end
        if rootPart.AssemblyLinearVelocity.Magnitude > settings.KnockbackThreshold then return end
        lastSafeCFrame = rootPart.CFrame
    end

    local function neutralizeKnockback()
        local character = currentCharacter()
        local rootPart = currentRootPart()
        if not character or not rootPart then return end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        if returnPending and lastSafeCFrame then
            character:PivotTo(lastSafeCFrame)
            returnPending = false
        end
    end

    local function beginImpactWindow(duration)
        if not settings.AntiKnockback then return end
        impactUntil = math.max(impactUntil, os.clock() + math.clamp(tonumber(duration) or 0.75, 0.25, 3))
        returnPending = true
        neutralizeKnockback()
        task.defer(function()
            if not destroyed and settings.AntiKnockback then neutralizeKnockback() end
        end)
    end

    local function isLocalCharacter(value)
        return value == nil or value == currentCharacter()
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local movementRemote = remotes and remotes:FindFirstChild("PlayerMovementClientSide")
    if movementRemote and movementRemote:IsA("RemoteEvent") then
        connect(movementRemote.OnClientEvent, function(action, target, duration)
            if destroyed then return end

            if action == "impactCamShake" then
                beginImpactWindow(0.75)
            elseif action == "toggleRagdoll" and isLocalCharacter(target) then
                if settings.AntiRagdoll then
                    applyAntiRagdoll()
                    task.defer(function()
                        if not destroyed and settings.AntiRagdoll then applyAntiRagdoll() end
                    end)
                end
                beginImpactWindow(duration)
            end
        end)
    end

    connect(RunService.Stepped, function()
        if destroyed then return end
        if settings.WalkSpeed ~= nil or settings.JumpBoost ~= nil then applyMovement() end
        if settings.Noclip then applyNoclip() end
        if settings.FullBright then applyFullBright() end
        if settings.AntiRagdoll then applyAntiRagdoll() end
        if settings.AntiKnockback and os.clock() < impactUntil then
            neutralizeKnockback()
        elseif settings.AntiKnockback then
            rememberSafePosition()
        end
    end)

    connect(localPlayer.CharacterAdded, function(character)
        task.defer(function()
            if destroyed or character ~= currentCharacter() then return end
            local humanoid = character:WaitForChild("Humanoid", 10)
            if humanoid then
                rememberHumanoid(humanoid)
                applyMovement()
                lastSafeCFrame = character:GetPivot()
                if settings.AntiRagdoll then applyAntiRagdoll() end
            end
        end)
    end)

    function runtime:Set(name, value)
        if destroyed then return end

        if name == "WalkSpeed" then
            settings.WalkSpeed = math.clamp(tonumber(value) or 16, 8, 200)
            applyMovement()
        elseif name == "JumpBoost" then
            settings.JumpBoost = math.clamp(tonumber(value) or 1, 1, 5)
            applyMovement()
        elseif name == "Noclip" then
            settings.Noclip = value == true
            if settings.Noclip then applyNoclip() else restoreCollision() end
        elseif name == "FullBright" then
            local enabled = value == true
            if enabled and not settings.FullBright then
                lightingOriginals = captureLighting()
            end
            settings.FullBright = enabled
            if enabled then applyFullBright() else restoreLighting() end
        elseif name == "AntiRagdoll" then
            settings.AntiRagdoll = value == true
            if settings.AntiRagdoll then applyAntiRagdoll() else restoreAntiRagdoll() end
        elseif name == "AntiKnockback" then
            settings.AntiKnockback = value == true
            if settings.AntiKnockback then
                rememberSafePosition()
            else
                impactUntil = 0
                returnPending = false
            end
        elseif name == "KnockbackThreshold" then
            settings.KnockbackThreshold = math.clamp(tonumber(value) or 55, 20, 150)
        end
    end

    function runtime:Destroy()
        if destroyed then return end
        destroyed = true

        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        connections = {}
        restoreCollision()
        restoreLighting()
        restoreAntiRagdoll()

        for humanoid, originals in pairs(humanoidOriginals) do
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = originals.WalkSpeed
                humanoid.UseJumpPower = originals.UseJumpPower
                humanoid.JumpPower = originals.JumpPower
                humanoid.JumpHeight = originals.JumpHeight
            end
        end
    end

    return runtime
end

return Player
