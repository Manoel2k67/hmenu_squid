local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Visuals = {}

local HIGHLIGHT_NAME = "HMenuGlassVision"
local LEGACY_HIGHLIGHT_NAME = "GlassESP"
local SAFE_FILL = Color3.fromRGB(35, 255, 105)
local SAFE_OUTLINE = Color3.fromRGB(0, 190, 65)
local FAKE_FILL = Color3.fromRGB(255, 55, 55)
local FAKE_OUTLINE = Color3.fromRGB(205, 0, 0)

function Visuals:Create()
    local connections = {}
    local folderConnections = {}
    local panelConnections = {}
    local highlights = {}
    local activeFolder
    local scanElapsed = 0
    local missingFolderWarned = false
    local destroyed = false
    local settings = {
        GlassESP = false,
        GlassTransparency = 82,
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

    connect(connections, RunService.Heartbeat, function(deltaTime)
        if destroyed or not settings.GlassESP then return end
        scanElapsed = scanElapsed + deltaTime
        if scanElapsed >= 0.5 then
            scanElapsed = 0
            refreshFolder()
        end
    end)

    function runtime:Set(name, value)
        if destroyed then return end

        if name == "GlassESP" then
            settings.GlassESP = value == true
            scanElapsed = 0
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
        end
    end

    function runtime:Destroy()
        if destroyed then return end
        destroyed = true
        disconnectAll(folderConnections)
        clearPanels()
        disconnectAll(connections)
        activeFolder = nil
    end

    return runtime
end

return Visuals
