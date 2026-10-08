local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Combat = {}

local HITBOX_VISUAL_NAME = "HMenuCombatHitbox"
local NEUTRAL_COLOR = Color3.fromRGB(190, 200, 220)
local TEAM_COLORS = {
    red = Color3.fromRGB(255, 75, 75),
    blue = Color3.fromRGB(80, 155, 255),
    green = Color3.fromRGB(70, 225, 115),
    yellow = Color3.fromRGB(255, 215, 70),
    orange = Color3.fromRGB(255, 145, 60),
    pink = Color3.fromRGB(255, 105, 180),
    purple = Color3.fromRGB(185, 105, 255),
    guard = Color3.fromRGB(255, 80, 80),
    player = Color3.fromRGB(95, 190, 255),
}
local FALLBACK_TEAM_COLORS = {
    Color3.fromRGB(95, 190, 255),
    Color3.fromRGB(105, 225, 135),
    Color3.fromRGB(255, 180, 70),
    Color3.fromRGB(195, 115, 255),
    Color3.fromRGB(255, 105, 170),
}

local COOLDOWN_NAMES = {
    attackdelay = true,
    attackwait = true,
    debouncetime = true,
    hitdelay = true,
    reloadtime = true,
    swingdelay = true,
    swingtime = true,
    usecooldown = true,
}

local READY_NAMES = {
    canattack = true,
    canhit = true,
    canuse = true,
    ready = true,
}

local function normalizedName(name)
    return string.lower(tostring(name or "")):gsub("[^%w]", "")
end

local function cooldownValue(name, value)
    local normalized = normalizedName(name)
    local isCooldown = string.find(normalized, "cooldown", 1, true) ~= nil
        or string.find(normalized, "debounce", 1, true) ~= nil
        or COOLDOWN_NAMES[normalized] == true
    if isCooldown then
        if type(value) == "number" then return 0 end
        if type(value) == "boolean" then return false end
    elseif READY_NAMES[normalized] and type(value) == "boolean" then
        return true
    end
    return nil
end

local function fallbackTeamColor(name)
    local normalized = string.lower(tostring(name or ""))
    if TEAM_COLORS[normalized] then return TEAM_COLORS[normalized] end

    local hash = 0
    for index = 1, #normalized do hash = hash + string.byte(normalized, index) end
    return FALLBACK_TEAM_COLORS[(hash % #FALLBACK_TEAM_COLORS) + 1]
end

local function teamColor(player)
    local hideNSeekTeam = player:GetAttribute("HideNSeek_Team")
    if type(hideNSeekTeam) == "string" and hideNSeekTeam ~= "" then
        return fallbackTeamColor(hideNSeekTeam)
    end

    local team = player.Team
    if team then
        local ok, color = pcall(function() return team.TeamColor.Color end)
        return ok and color or fallbackTeamColor(team.Name)
    end
    return NEUTRAL_COLOR
end

function Combat:Create()
    local localPlayer = Players.LocalPlayer
    local connections = {}
    local originals = setmetatable({}, { __mode = "k" })
    local visuals = setmetatable({}, { __mode = "k" })
    local originalCooldownValues = setmetatable({}, { __mode = "k" })
    local originalCooldownAttributes = setmetatable({}, { __mode = "k" })
    local destroyed = false
    local scanElapsed = 0
    local cooldownElapsed = 0
    local settings = {
        NoCooldown = false,
        HitboxEnabled = false,
        HitboxRange = 15,
        HitboxVisible = true,
        HitboxTransparency = 78,
    }

    local runtime = {}

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function patchAttributes(object)
        local ok, attributes = pcall(function() return object:GetAttributes() end)
        if not ok then return end

        for name, value in pairs(attributes) do
            local replacement = cooldownValue(name, value)
            if replacement ~= nil and value ~= replacement then
                local saved = originalCooldownAttributes[object]
                if not saved then
                    saved = {}
                    originalCooldownAttributes[object] = saved
                end
                if saved[name] == nil then saved[name] = value end
                pcall(function() object:SetAttribute(name, replacement) end)
            end
        end
    end

    local function patchValueObject(object)
        local supported = object:IsA("NumberValue") or object:IsA("IntValue") or object:IsA("BoolValue")
        if not supported then return end

        local replacement = cooldownValue(object.Name, object.Value)
        if replacement == nil or object.Value == replacement then return end
        if originalCooldownValues[object] == nil then originalCooldownValues[object] = object.Value end
        pcall(function() object.Value = replacement end)
    end

    local function patchObject(object)
        patchAttributes(object)
        patchValueObject(object)
    end

    local function patchTool(tool)
        if not tool:IsA("Tool") then return end
        pcall(function() tool.Enabled = true end)
        patchObject(tool)
        for _, object in ipairs(tool:GetDescendants()) do patchObject(object) end
    end

    local function applyNoCooldown()
        if not settings.NoCooldown then return end
        patchAttributes(localPlayer)

        local backpack = localPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            patchAttributes(backpack)
            for _, child in ipairs(backpack:GetChildren()) do patchTool(child) end
        end

        local character = localPlayer.Character
        if character then
            patchAttributes(character)
            for _, child in ipairs(character:GetChildren()) do patchTool(child) end
        end
    end

    local function restoreCooldownValues()
        for object, value in pairs(originalCooldownValues) do
            if object.Parent then pcall(function() object.Value = value end) end
        end
        originalCooldownValues = setmetatable({}, { __mode = "k" })

        for object, attributes in pairs(originalCooldownAttributes) do
            if object.Parent then
                for name, value in pairs(attributes) do
                    pcall(function() object:SetAttribute(name, value) end)
                end
            end
        end
        originalCooldownAttributes = setmetatable({}, { __mode = "k" })
    end

    local function rememberRoot(root)
        if root and not originals[root] then
            originals[root] = {
                Size = root.Size,
                Transparency = root.Transparency,
                CanCollide = root.CanCollide,
                CanTouch = root.CanTouch,
                CanQuery = root.CanQuery,
            }
        end
        return root and originals[root]
    end

    local function removeVisual(root)
        local visual = visuals[root]
        if visual then
            if visual.Parent then visual:Destroy() end
            visuals[root] = nil
        end
        local legacy = root and root:FindFirstChild(HITBOX_VISUAL_NAME)
        if legacy and legacy:IsA("BoxHandleAdornment") then legacy:Destroy() end
    end

    local function restoreRoot(root)
        removeVisual(root)
        local original = originals[root]
        if original and root and root.Parent then
            root.Size = original.Size
            root.Transparency = original.Transparency
            root.CanCollide = original.CanCollide
            root.CanTouch = original.CanTouch
            root.CanQuery = original.CanQuery
        end
        originals[root] = nil
    end

    local function createVisual(root)
        removeVisual(root)
        local visual = Instance.new("BoxHandleAdornment")
        visual.Name = HITBOX_VISUAL_NAME
        visual.Adornee = root
        visual.AlwaysOnTop = true
        visual.ZIndex = 4
        visual.Parent = root
        visuals[root] = visual
        return visual
    end

    local function applyToPlayer(player, present)
        if player == localPlayer then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then return end

        present[root] = true
        rememberRoot(root)
        local diameter = math.clamp(settings.HitboxRange, 5, 500) * 2
        local size = Vector3.new(diameter, diameter, diameter)
        root.Size = size
        root.Transparency = 1
        root.CanCollide = false
        root.CanTouch = true
        root.CanQuery = true

        local visual = visuals[root]
        if not visual or not visual.Parent then visual = createVisual(root) end
        visual.Size = size
        visual.Color3 = teamColor(player)
        visual.Transparency = math.clamp(settings.HitboxTransparency / 100, 0.2, 0.95)
        visual.Visible = settings.HitboxVisible
    end

    local function updateHitboxes()
        if not settings.HitboxEnabled then return end
        local present = {}
        for _, player in ipairs(Players:GetPlayers()) do applyToPlayer(player, present) end

        local stale = {}
        for root in pairs(originals) do
            if not present[root] or not root.Parent then table.insert(stale, root) end
        end
        for _, root in ipairs(stale) do restoreRoot(root) end
    end

    local function clearHitboxes()
        local roots = {}
        for root in pairs(originals) do table.insert(roots, root) end
        for _, root in ipairs(roots) do restoreRoot(root) end

        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then removeVisual(root) end
        end
    end

    connect(RunService.Heartbeat, function(deltaTime)
        if destroyed then return end
        if settings.HitboxEnabled then
            scanElapsed = scanElapsed + deltaTime
            if scanElapsed >= 0.1 then
                scanElapsed = 0
                updateHitboxes()
            end
        end
        if settings.NoCooldown then
            cooldownElapsed = cooldownElapsed + deltaTime
            if cooldownElapsed >= 0.05 then
                cooldownElapsed = 0
                applyNoCooldown()
            end
        end
    end)

    function runtime:Set(name, value)
        if destroyed then return end
        if name == "NoCooldown" then
            settings.NoCooldown = value == true
            cooldownElapsed = 0
            if settings.NoCooldown then
                applyNoCooldown()
            else
                restoreCooldownValues()
            end
        elseif name == "HitboxEnabled" then
            settings.HitboxEnabled = value == true
            if settings.HitboxEnabled then
                updateHitboxes()
            else
                clearHitboxes()
            end
        elseif name == "HitboxRange" then
            settings.HitboxRange = math.clamp(tonumber(value) or 15, 5, 500)
            if settings.HitboxEnabled then updateHitboxes() end
        elseif name == "HitboxVisible" then
            settings.HitboxVisible = value == true
            if settings.HitboxEnabled then updateHitboxes() end
        elseif name == "HitboxTransparency" then
            settings.HitboxTransparency = math.clamp(tonumber(value) or 78, 20, 95)
            if settings.HitboxEnabled then updateHitboxes() end
        end
    end

    function runtime:Destroy()
        if destroyed then return end
        destroyed = true
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        connections = {}
        restoreCooldownValues()
        clearHitboxes()
    end

    return runtime
end

return Combat
