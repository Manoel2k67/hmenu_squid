local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Visuals = {}

local HIGHLIGHT_NAME = "HMenuGlassVision"
local LEGACY_HIGHLIGHT_NAME = "GlassESP"
local SAFE_FILL = Color3.fromRGB(35, 255, 105)
local SAFE_OUTLINE = Color3.fromRGB(0, 190, 65)
local FAKE_FILL = Color3.fromRGB(255, 55, 55)
local FAKE_OUTLINE = Color3.fromRGB(205, 0, 0)
local PLAYER_ESP_NAME = "HMenuPlayerESP"
local PLAYER_AURA_NAME = "HMenuPlayerAura"
local EXIT_ESP_NAME = "HMenuHideNSeekExitESP"
local EXIT_FILL = Color3.fromRGB(255, 171, 45)
local EXIT_OUTLINE = Color3.fromRGB(255, 205, 75)
local GLASS_MAKER_COLOR = Color3.fromRGB(255, 215, 55)
local BABY_COLOR = Color3.fromRGB(255, 105, 180)
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

function Visuals:Create()
    local connections = {}
    local folderConnections = {}
    local panelConnections = {}
    local highlights = {}
    local playerEspEntries = {}
    local exitEntries = {}
    local humanoidDisplayOriginals = setmetatable({}, { __mode = "k" })
    local activeFolder
    local activeExitFolder
    local glassScanElapsed = 0
    local playerScanElapsed = 0
    local exitScanElapsed = 0
    local missingFolderWarned = false
    local destroyed = false
    local settings = {
        GlassESP = false,
        GlassTransparency = 82,
        PlayerESP = false,
        PlayerESPHealth = true,
        PlayerESPTeams = true,
        PlayerESPAura = true,
        PlayerESPAuraIntensity = 45,
        PlayerESPGlassMaker = true,
        PlayerESPBaby = true,
        HideNSeekExitESP = false,
    }

    local runtime = {}

    local function connect(bucket, signal, callback)
        local connection = signal:Connect(callback)
        table.insert(bucket, connection)
        return connection
    end

    local function disconnectAll(bucket)
        for index = #bucket, 1, -1 do
            pcall(function() bucket[index]:Disconnect() end)
            table.remove(bucket, index)
        end
    end

    local function glassFolder()
        local map = Workspace:FindFirstChild("Map")
        local glass = map and map:FindFirstChild("Glass")
        return glass and glass:FindFirstChild("Glasses")
    end

    local function isPanel(instance)
        return instance and instance:IsA("BasePart")
            and string.find(instance.Name, "Pair", 1, true) ~= nil
    end

    local function removeHighlight(part)
        local highlight = highlights[part]
        if highlight then
            if highlight.Parent then highlight:Destroy() end
            highlights[part] = nil
        end
    end

    local function removeLegacyHighlight(part)
        local legacy = part:FindFirstChild(LEGACY_HIGHLIGHT_NAME)
        if legacy and legacy:IsA("Highlight") then legacy:Destroy() end
    end

    local function panelIsRemoved(part)
        return not activeFolder or not part:IsDescendantOf(activeFolder) or part.Position.Y < -1000
    end

    local function updatePanel(part)
        if destroyed or not settings.GlassESP or not isPanel(part) or panelIsRemoved(part) then
            removeHighlight(part)
            return
        end

        removeLegacyHighlight(part)
        local highlight = highlights[part]
        if not highlight or not highlight.Parent then
            highlight = Instance.new("Highlight")
            highlight.Name = HIGHLIGHT_NAME
            highlight.Adornee = part
            highlight.DepthMode = Enum.HighlightDepthMode.Occluded
            highlight.OutlineTransparency = 0.08
            highlight.Parent = part
            highlights[part] = highlight
        end

        local safe = part.CanCollide == true
        highlight.FillColor = safe and SAFE_FILL or FAKE_FILL
        highlight.OutlineColor = safe and SAFE_OUTLINE or FAKE_OUTLINE
        highlight.FillTransparency = math.clamp(settings.GlassTransparency / 100, 0.55, 0.95)
    end

    local function unwatchPanel(part)
        local bucket = panelConnections[part]
        if bucket then
            disconnectAll(bucket)
            panelConnections[part] = nil
        end
        removeHighlight(part)
    end

    local function watchPanel(part)
        if not isPanel(part) or panelConnections[part] then return end

        local bucket = {}
        panelConnections[part] = bucket
        connect(bucket, part:GetPropertyChangedSignal("CanCollide"), function()
            updatePanel(part)
        end)
        connect(bucket, part:GetPropertyChangedSignal("Position"), function()
            updatePanel(part)
        end)
        connect(bucket, part.AncestryChanged, function()
            if not activeFolder or not part:IsDescendantOf(activeFolder) then
                unwatchPanel(part)
            end
        end)
        updatePanel(part)
    end

    local function clearPanels()
        local parts = {}
        for part in pairs(panelConnections) do table.insert(parts, part) end
        for _, part in ipairs(parts) do unwatchPanel(part) end

        for part in pairs(highlights) do removeHighlight(part) end
    end

    local function bindFolder(folder)
        disconnectAll(folderConnections)
        clearPanels()
        activeFolder = folder
        if not activeFolder then return end

        missingFolderWarned = false
        for _, child in ipairs(activeFolder:GetChildren()) do watchPanel(child) end
        connect(folderConnections, activeFolder.ChildAdded, function(child)
            task.defer(function()
                if not destroyed and activeFolder and child.Parent == activeFolder then
                    watchPanel(child)
                end
            end)
        end)
        connect(folderConnections, activeFolder.ChildRemoved, unwatchPanel)
    end

    local function refreshFolder()
        local current = glassFolder()
        if current ~= activeFolder then bindFolder(current) end
        if settings.GlassESP and not current and not missingFolderWarned then
            missingFolderWarned = true
            warn("[HMenu/Visuals] A ponte ainda não foi carregada; o Glass Vision será aplicado quando ela aparecer.")
        end
    end

    local function removeLegacyHighlights()
        local folder = glassFolder()
        if not folder then return end
        for _, child in ipairs(folder:GetChildren()) do
            if isPanel(child) then removeLegacyHighlight(child) end
        end
    end

    local function exitDoorsFolder()
        local map = Workspace:FindFirstChild("Map")
        local hideNSeek = map and map:FindFirstChild("HideNSeek")
        local elements = hideNSeek and hideNSeek:FindFirstChild("Elements")
        return elements and elements:FindFirstChild("ExitDoors")
    end

    local function exitDoorAdornee(exitDoor)
        if exitDoor:IsA("BasePart") then return exitDoor end

        local door = exitDoor:FindFirstChild("Door")
        if door then
            local proximityPart = door:FindFirstChild("ProximityPart", true)
            if proximityPart and proximityPart:IsA("BasePart") then return proximityPart end
            local doorPart = door:FindFirstChildWhichIsA("BasePart", true)
            if doorPart then return doorPart end
        end
        return exitDoor:FindFirstChildWhichIsA("BasePart", true)
    end

    local function isExitDoor(instance)
        return instance and instance.Name == "ExitDoor"
            and (instance:IsA("Model") or instance:IsA("BasePart"))
    end

    local function removeExitEsp(exitDoor)
        local entry = exitEntries[exitDoor]
        if entry then
            if entry.Highlight and entry.Highlight.Parent then entry.Highlight:Destroy() end
            exitEntries[exitDoor] = nil
        end
    end

    local function clearExitEsp()
        local doors = {}
        for exitDoor in pairs(exitEntries) do table.insert(doors, exitDoor) end
        for _, exitDoor in ipairs(doors) do removeExitEsp(exitDoor) end

        local folder = exitDoorsFolder()
        if folder then
            for _, descendant in ipairs(folder:GetDescendants()) do
                if descendant.Name == EXIT_ESP_NAME or descendant.Name == "HMenuHideNSeekExitLabel" then
                    descendant:Destroy()
                end
            end
        end
    end

    local function createExitEsp(exitDoor)
        local adornee = exitDoorAdornee(exitDoor)
        if not adornee then return nil end

        local previousHighlight = exitDoor:FindFirstChild(EXIT_ESP_NAME)
        if previousHighlight then previousHighlight:Destroy() end
        local previousLabel = adornee:FindFirstChild("HMenuHideNSeekExitLabel")
        if previousLabel then previousLabel:Destroy() end

        local highlight = Instance.new("Highlight")
        highlight.Name = EXIT_ESP_NAME
        highlight.Adornee = exitDoor
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = EXIT_FILL
        highlight.FillTransparency = math.clamp(settings.GlassTransparency / 100, 0.55, 0.95)
        highlight.OutlineColor = EXIT_OUTLINE
        highlight.OutlineTransparency = 0.05
        highlight.Parent = exitDoor

        return {
            Highlight = highlight,
            Adornee = adornee,
        }
    end

    local function updateExitEsp()
        if not settings.HideNSeekExitESP then
            clearExitEsp()
            return
        end

        local folder = exitDoorsFolder()
        if folder ~= activeExitFolder then
            clearExitEsp()
            activeExitFolder = folder
        end
        if not folder then return end

        local present = {}
        for _, exitDoor in ipairs(folder:GetChildren()) do
            if isExitDoor(exitDoor) then
                present[exitDoor] = true
                local entry = exitEntries[exitDoor]
                if not entry or not entry.Highlight.Parent or not entry.Adornee:IsDescendantOf(exitDoor) then
                    removeExitEsp(exitDoor)
                    entry = createExitEsp(exitDoor)
                    exitEntries[exitDoor] = entry
                end
            end
        end

        local stale = {}
        for exitDoor in pairs(exitEntries) do
            if not present[exitDoor] or not exitDoor.Parent then table.insert(stale, exitDoor) end
        end
        for _, exitDoor in ipairs(stale) do removeExitEsp(exitDoor) end
    end

    local function fallbackTeamColor(name)
        local normalized = string.lower(tostring(name or ""))
        if TEAM_COLORS[normalized] then return TEAM_COLORS[normalized] end

        local hash = 0
        for index = 1, #normalized do hash = hash + string.byte(normalized, index) end
        return FALLBACK_TEAM_COLORS[(hash % #FALLBACK_TEAM_COLORS) + 1]
    end

    local function teamInfo(player)
        local hideNSeekTeam = player:GetAttribute("HideNSeek_Team")
        if type(hideNSeekTeam) == "string" and hideNSeekTeam ~= "" then
            return string.upper(hideNSeekTeam), fallbackTeamColor(hideNSeekTeam)
        end

        local team = player.Team
        if team then
            local ok, color = pcall(function() return team.TeamColor.Color end)
            return string.upper(team.Name), ok and color or fallbackTeamColor(team.Name)
        end
        return player.Neutral and "SEM TIME" or "TIME DESCONHECIDO", NEUTRAL_COLOR
    end

    local function makeText(parent, name, order)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(1, 0, 0, 15)
        label.Position = UDim2.fromOffset(0, 18 + ((order - 1) * 15))
        label.BackgroundTransparency = 1
        label.BorderSizePixel = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextStrokeColor3 = Color3.fromRGB(12, 14, 20)
        label.TextStrokeTransparency = 0.22
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Visible = false
        label.Parent = parent
        return label
    end

    local function hideNativeDisplay(humanoid)
        if not humanoidDisplayOriginals[humanoid] then
            humanoidDisplayOriginals[humanoid] = {
                DisplayDistanceType = humanoid.DisplayDistanceType,
                NameDisplayDistance = humanoid.NameDisplayDistance,
                HealthDisplayDistance = humanoid.HealthDisplayDistance,
            }
        end
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end

    local function restoreNativeDisplay(humanoid)
        local originals = humanoidDisplayOriginals[humanoid]
        if not originals then return end
        if humanoid and humanoid.Parent then
            humanoid.DisplayDistanceType = originals.DisplayDistanceType
            humanoid.NameDisplayDistance = originals.NameDisplayDistance
            humanoid.HealthDisplayDistance = originals.HealthDisplayDistance
        end
        humanoidDisplayOriginals[humanoid] = nil
    end

    local function updateAura(entry, color)
        local intensity = math.clamp(settings.PlayerESPAuraIntensity, 10, 100) / 100
        entry.Aura.Enabled = settings.PlayerESPAura
        entry.Aura.FillColor = color
        entry.Aura.OutlineColor = color
        entry.Aura.FillTransparency = math.clamp(1 - (intensity * 0.72), 0.24, 0.93)
        entry.Aura.OutlineTransparency = math.clamp(1 - intensity, 0.02, 0.88)
    end

    local function createPlayerEsp(player, adornee, character, humanoid)
        local previous = adornee:FindFirstChild(PLAYER_ESP_NAME)
        if previous then previous:Destroy() end
        local previousAura = character:FindFirstChild(PLAYER_AURA_NAME)
        if previousAura then previousAura:Destroy() end

        local gui = Instance.new("BillboardGui")
        gui.Name = PLAYER_ESP_NAME
        gui.Adornee = adornee
        gui.Size = UDim2.fromOffset(230, 83)
        gui.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
        gui.AlwaysOnTop = true
        gui.LightInfluence = 0
        gui.MaxDistance = 1500
        gui.ResetOnSpawn = false
        gui.Parent = adornee

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "PlayerName"
        nameLabel.Size = UDim2.new(1, 0, 0, 18)
        nameLabel.BackgroundTransparency = 1
        nameLabel.BorderSizePixel = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = Color3.fromRGB(245, 248, 255)
        nameLabel.TextStrokeColor3 = Color3.fromRGB(8, 10, 16)
        nameLabel.TextStrokeTransparency = 0.15
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.Parent = gui

        local aura = Instance.new("Highlight")
        aura.Name = PLAYER_AURA_NAME
        aura.Adornee = character
        aura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        aura.Parent = character

        return {
            Gui = gui,
            Aura = aura,
            Adornee = adornee,
            Character = character,
            Humanoid = humanoid,
            Name = nameLabel,
            Health = makeText(gui, "HealthTag", 1),
            Team = makeText(gui, "TeamTag", 2),
            GlassMaker = makeText(gui, "GlassMakerTag", 3),
            Baby = makeText(gui, "BabyTag", 4),
        }
    end

    local function removePlayerEsp(player)
        local entry = playerEspEntries[player]
        if entry then
            if entry.Gui and entry.Gui.Parent then entry.Gui:Destroy() end
            if entry.Aura and entry.Aura.Parent then entry.Aura:Destroy() end
            restoreNativeDisplay(entry.Humanoid)
            playerEspEntries[player] = nil
        end
    end

    local function clearPlayerEsp()
        local players = {}
        for player in pairs(playerEspEntries) do table.insert(players, player) end
        for _, player in ipairs(players) do removePlayerEsp(player) end

        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if character then
                for _, descendant in ipairs(character:GetDescendants()) do
                    if descendant:IsA("BillboardGui") and descendant.Name == PLAYER_ESP_NAME then
                        descendant:Destroy()
                    elseif descendant:IsA("Highlight") and descendant.Name == PLAYER_AURA_NAME then
                        descendant:Destroy()
                    end
                end
            end
        end

        local humanoids = {}
        for humanoid in pairs(humanoidDisplayOriginals) do table.insert(humanoids, humanoid) end
        for _, humanoid in ipairs(humanoids) do restoreNativeDisplay(humanoid) end
    end

    local function setTag(label, visible, value, color, row)
        label.Visible = visible
        if not visible then return row end
        label.Position = UDim2.fromOffset(0, 18 + (row * 15))
        label.Text = "[" .. value .. "]"
        label.TextColor3 = color
        return row + 1
    end

    local function updatePlayerEsp()
        if not settings.PlayerESP then
            clearPlayerEsp()
            return
        end

        local present = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                present[player] = true
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local adornee = character and (character:FindFirstChild("Head")
                    or character:FindFirstChild("HumanoidRootPart"))

                if not character or not adornee or not humanoid then
                    removePlayerEsp(player)
                else
                    local entry = playerEspEntries[player]
                    if not entry or not entry.Gui.Parent or entry.Adornee ~= adornee
                        or entry.Character ~= character or entry.Humanoid ~= humanoid then
                        removePlayerEsp(player)
                        entry = createPlayerEsp(player, adornee, character, humanoid)
                        playerEspEntries[player] = entry
                    end

                    hideNativeDisplay(humanoid)
                    entry.Name.Text = player.DisplayName ~= player.Name
                        and (player.DisplayName .. "  (@" .. player.Name .. ")") or player.Name

                    local teamName, teamColor = teamInfo(player)
                    updateAura(entry, teamColor)
                    local glassMaker = player:GetAttribute("GlassMaker") == true
                    local hasBaby = player:GetAttribute("HasBaby") == true
                        or character:FindFirstChild("BabyBack", true) ~= nil
                    local babyType = player:GetAttribute("BabyType")
                    local babyLabel = type(babyType) == "string" and babyType ~= ""
                        and ("COM BEBÊ: " .. string.upper(babyType)) or "COM BEBÊ"

                    local health = math.max(humanoid.Health, 0)
                    local maxHealth = math.max(humanoid.MaxHealth, 1)
                    local healthRatio = math.clamp(health / maxHealth, 0, 1)
                    local healthColor = Color3.fromHSV(healthRatio * 0.33, 0.88, 1)
                    local healthLabel = health <= 0 and "MORTO" or string.format(
                        "VIDA: %d/%d (%d%%)",
                        math.floor(health + 0.5),
                        math.floor(maxHealth + 0.5),
                        math.floor((healthRatio * 100) + 0.5)
                    )

                    local row = 0
                    row = setTag(entry.Health, settings.PlayerESPHealth,
                        healthLabel, healthColor, row)
                    row = setTag(entry.Team, settings.PlayerESPTeams, "TIME: " .. teamName, teamColor, row)
                    row = setTag(entry.GlassMaker, settings.PlayerESPGlassMaker and glassMaker,
                        "GLASS MAKER", GLASS_MAKER_COLOR, row)
                    setTag(entry.Baby, settings.PlayerESPBaby and hasBaby, babyLabel, BABY_COLOR, row)
                end
            end
        end

        local stale = {}
        for player in pairs(playerEspEntries) do
            if not present[player] or not player.Parent then table.insert(stale, player) end
        end
        for _, player in ipairs(stale) do removePlayerEsp(player) end
    end

    connect(connections, RunService.Heartbeat, function(deltaTime)
        if destroyed then return end
        if settings.GlassESP then
            glassScanElapsed = glassScanElapsed + deltaTime
        end
        if settings.PlayerESP then
            playerScanElapsed = playerScanElapsed + deltaTime
        end
        if settings.HideNSeekExitESP then
            exitScanElapsed = exitScanElapsed + deltaTime
        end
        if settings.GlassESP and glassScanElapsed >= 0.5 then
            glassScanElapsed = 0
            refreshFolder()
        end
        if settings.PlayerESP and playerScanElapsed >= 0.35 then
            playerScanElapsed = 0
            updatePlayerEsp()
        end
        if settings.HideNSeekExitESP and exitScanElapsed >= 0.35 then
            exitScanElapsed = 0
            updateExitEsp()
        end
    end)

    function runtime:Set(name, value)
        if destroyed then return end

        if name == "GlassESP" then
            settings.GlassESP = value == true
            glassScanElapsed = 0
            if settings.GlassESP then
                removeLegacyHighlights()
                refreshFolder()
                if activeFolder then
                    for _, child in ipairs(activeFolder:GetChildren()) do watchPanel(child) end
                end
            else
                bindFolder(nil)
            end
        elseif name == "GlassTransparency" then
            settings.GlassTransparency = math.clamp(tonumber(value) or 82, 55, 95)
            for part in pairs(highlights) do updatePanel(part) end
            for _, entry in pairs(exitEntries) do
                if entry.Highlight and entry.Highlight.Parent then
                    entry.Highlight.FillTransparency = math.clamp(settings.GlassTransparency / 100, 0.55, 0.95)
                end
            end
        elseif name == "PlayerESP" then
            settings.PlayerESP = value == true
            playerScanElapsed = 0
            if settings.PlayerESP then updatePlayerEsp() else clearPlayerEsp() end
        elseif name == "PlayerESPHealth" or name == "PlayerESPTeams" or name == "PlayerESPAura"
            or name == "PlayerESPGlassMaker" or name == "PlayerESPBaby" then
            settings[name] = value == true
            if settings.PlayerESP then updatePlayerEsp() end
        elseif name == "PlayerESPAuraIntensity" then
            settings.PlayerESPAuraIntensity = math.clamp(tonumber(value) or 45, 10, 100)
            if settings.PlayerESP then updatePlayerEsp() end
        elseif name == "HideNSeekExitESP" then
            settings.HideNSeekExitESP = value == true
            exitScanElapsed = 0
            if settings.HideNSeekExitESP then
                updateExitEsp()
            else
                clearExitEsp()
                activeExitFolder = nil
            end
        end
    end

    function runtime:Destroy()
        if destroyed then return end
        destroyed = true
        disconnectAll(folderConnections)
        clearPanels()
        clearPlayerEsp()
        clearExitEsp()
        disconnectAll(connections)
        activeFolder = nil
        activeExitFolder = nil
    end

    return runtime
end

return Visuals
