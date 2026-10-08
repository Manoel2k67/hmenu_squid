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

local function installRaycastRedirect(listener)
    local key = "__HMENU_COMBAT_RAYCAST_REDIRECT"
    local state = rawget(_G, key)
    if type(state) ~= "table" or type(state.Listeners) ~= "table" then
        state = { Listeners = {}, NextId = 0, Available = false }
        rawset(_G, key, state)

        if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
            local oldNamecall
            local wrapper = function(self, ...)
                local method = ""
                pcall(function() method = getnamecallmethod() end)
                if method ~= "Raycast" or self ~= workspace then
                    return oldNamecall(self, ...)
                end

                local packed = table.pack(...)
                local result = oldNamecall(self, table.unpack(packed, 1, packed.n))
                local current = rawget(_G, key)
                if type(current) ~= "table" or type(current.Listeners) ~= "table" then
                    return result
                end

                local callerIsExecutor = false
                if type(checkcaller) == "function" then
                    pcall(function() callerIsExecutor = checkcaller() end)
                end
                if callerIsExecutor then return result end

                local function recast(...)
                    return oldNamecall(self, ...)
                end
                for _, callback in pairs(current.Listeners) do
                    local ok, handled, replacement = pcall(callback, result, packed, recast)
                    if ok and handled then return replacement end
                end
                return result
            end
            if type(newcclosure) == "function" then wrapper = newcclosure(wrapper) end
            local ok, original = pcall(function()
                oldNamecall = hookmetamethod(game, "__namecall", wrapper)
                return oldNamecall
            end)
            state.Available = ok and type(original) == "function"
        end
    end

    state.NextId = (tonumber(state.NextId) or 0) + 1
    local listenerId = state.NextId
    state.Listeners[listenerId] = listener
    return function()
        local current = rawget(_G, key)
        if type(current) == "table" and type(current.Listeners) == "table" then
            current.Listeners[listenerId] = nil
        end
    end
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
    local destroyed = false
    local scanElapsed = 0
    local removeRaycastRedirect = nil
    local settings = {
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

    local function gunIsEquipped()
        local character = localPlayer and localPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if not tool then return false end
        if tool:GetAttribute("IsGun") == true then return true end
        local weaponType = tool:FindFirstChild("WeaponType")
        return weaponType and weaponType:IsA("StringValue")
            and string.find(string.lower(weaponType.Value), "weapon", 1, true) ~= nil
    end

    removeRaycastRedirect = installRaycastRedirect(function(result, packed, recast)
        if destroyed or not settings.HitboxEnabled or not gunIsEquipped() then return false end
        if typeof(result) ~= "RaycastResult" then return false end

        local targetRoot = result.Instance
        if not targetRoot or not originals[targetRoot] then return false end

        local origin = packed[1]
        local direction = packed[2]
        if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3"
            or direction.Magnitude <= 0 then
            return false
        end

        local targetDirection = targetRoot.Position - origin
        if targetDirection.Magnitude <= 0 then return false end

        local expandedSizes = {}
        for root, original in pairs(originals) do
            if root and root.Parent and original then
                expandedSizes[root] = root.Size
                root.Size = original.Size
            end
        end

        local castLength = math.max(direction.Magnitude, targetDirection.Magnitude + 4)
        local redirectedDirection = targetDirection.Unit * castLength
        local ok, redirected = pcall(function()
            if packed.n >= 3 then
                return recast(origin, redirectedDirection, packed[3])
            end
            return recast(origin, redirectedDirection)
        end)

        for root, size in pairs(expandedSizes) do
            if root and root.Parent then root.Size = size end
        end

        if not ok then return false end
        return true, redirected
    end)

    connect(RunService.Heartbeat, function(deltaTime)
        if destroyed then return end
        if settings.HitboxEnabled then
            scanElapsed = scanElapsed + deltaTime
            if scanElapsed >= 0.1 then
                scanElapsed = 0
                updateHitboxes()
            end
        end
    end)

    function runtime:Set(name, value)
        if destroyed then return end
        if name == "HitboxEnabled" then
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
        if removeRaycastRedirect then
            removeRaycastRedirect()
            removeRaycastRedirect = nil
        end
        clearHitboxes()
    end

    return runtime
end

return Combat
