local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Teleport = {}

function Teleport:Create()
    local localPlayer = Players.LocalPlayer
    local destroyed = false
    local settings = {
        SelectedPlayer = "Selecione um jogador",
        ArrivalMode = "Atrás",
        ArrivalDistance = 4,
        SelectedArea = "Incinerador",
    }

    local runtime = {}

    local function characterRoot(player)
        local character = player and player.Character
        if not character then return nil, nil end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root then return nil, nil end
        return character, root
    end

    local function selectedPlayer()
        local name = settings.SelectedPlayer
        if type(name) ~= "string" or name == "Selecione um jogador" then return nil end
        return Players:FindFirstChild(name)
    end

    local function destinationFor(targetRoot)
        local distance = math.clamp(tonumber(settings.ArrivalDistance) or 4, 2, 12)
        if settings.ArrivalMode == "Na frente" then
            return targetRoot.CFrame * CFrame.new(0, 0, -distance)
        elseif settings.ArrivalMode == "Acima" then
            return targetRoot.CFrame * CFrame.new(0, distance, 0)
        end
        return targetRoot.CFrame * CFrame.new(0, 0, distance)
    end

    local function teleportToSelected()
        local target = selectedPlayer()
        if not target or target == localPlayer then
            warn("[HMenu/Teleport] Selecione outro jogador.")
            return
        end

        local character, root = characterRoot(localPlayer)
        local _, targetRoot = characterRoot(target)
        if not character or not root then
            warn("[HMenu/Teleport] Seu personagem não está disponível.")
            return
        end
        if not targetRoot then
            warn("[HMenu/Teleport] O personagem selecionado não está disponível.")
            return
        end

        character:PivotTo(destinationFor(targetRoot))
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    local function findPath(root, path)
        local current = root
        for _, name in ipairs(path) do
            current = current and current:FindFirstChild(name)
            if not current then return nil end
        end
        return current
    end

    local function frontmanOffice()
        return findPath(Workspace, { "LobbyMale", "LOBBY_GAME", "FrontmanOffce" })
            or Workspace:FindFirstChild("FrontmanOffce", true)
            or Workspace:FindFirstChild("FrontmanOffice", true)
    end

    local areaResolvers = {
        ["Incinerador"] = function()
            return findPath(Workspace, { "Data", "IncinerationRoom", "Inside" })
                or findPath(Workspace, { "Data", "IncinerationRoom", "Burn" })
        end,
        ["Elevador do lobby"] = function()
            return findPath(Workspace, { "Data", "Elevator", "Lobby", "UIPrompt" })
                or findPath(Workspace, { "Data", "Elevator", "Lobby", "Door" })
        end,
        ["Sala do Frontman"] = frontmanOffice,
        ["Instalação / Ilha"] = function()
            return findPath(Workspace, { "Data", "Elevator", "Island", "UIPrompt" })
                or findPath(Workspace, { "Data", "Elevator", "Island", "Door" })
        end,
    }

    local function modelDestination(model)
        local preferredPart
        local preferredScore = -math.huge

        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("BasePart") then
                local normalized = string.lower(descendant.Name)
                local isFloor = string.find(normalized, "floor", 1, true)
                    or string.find(normalized, "ground", 1, true)
                    or string.find(normalized, "carpet", 1, true)
                if isFloor and descendant.CFrame.UpVector.Y > 0.65 then
                    local score = descendant.Size.X * descendant.Size.Z
                    if score > preferredScore then
                        preferredPart = descendant
                        preferredScore = score
                    end
                end
            end
        end

        if preferredPart then
            return CFrame.new(preferredPart.Position + Vector3.new(0, (preferredPart.Size.Y / 2) + 3, 0))
        end

        local boxCFrame, boxSize = model:GetBoundingBox()
        local bottom = boxCFrame.Position.Y - (boxSize.Y / 2)
        return CFrame.new(boxCFrame.Position.X, bottom + 4, boxCFrame.Position.Z)
    end

    local function destinationForArea(target)
        if target:IsA("BasePart") then
            return target.CFrame + Vector3.new(0, 3, 0)
        elseif target:IsA("Model") then
            return modelDestination(target)
        end

        local part = target:FindFirstChildWhichIsA("BasePart", true)
        return part and (part.CFrame + Vector3.new(0, 3, 0)) or nil
    end

    local function teleportToArea()
        local resolver = areaResolvers[settings.SelectedArea]
        if not resolver then
            warn("[HMenu/Teleport] Selecione uma área válida.")
            return
        end

        local character, root = characterRoot(localPlayer)
        if not character or not root then
            warn("[HMenu/Teleport] Seu personagem não está disponível.")
            return
        end

        local target = resolver()
        if not target or not target:IsDescendantOf(Workspace) then
            warn("[HMenu/Teleport] A área '" .. settings.SelectedArea .. "' não está carregada neste momento.")
            return
        end

        local destination = destinationForArea(target)
        if not destination then
            warn("[HMenu/Teleport] Não foi encontrado um ponto seguro nessa área.")
            return
        end

        character:PivotTo(destination)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    function runtime:GetOptions(source)
        if source ~= "Players" then return { "Selecione um jogador" } end

        local names = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then table.insert(names, player.Name) end
        end
        table.sort(names, function(left, right)
            return string.lower(left) < string.lower(right)
        end)
        table.insert(names, 1, "Selecione um jogador")
        return names
    end

    function runtime:Set(name, value)
        if destroyed then return end
        if name == "TeleportToSelected" then
            teleportToSelected()
        elseif name == "TeleportToArea" then
            teleportToArea()
        elseif settings[name] ~= nil then
            settings[name] = value
        end
    end

    function runtime:Destroy()
        destroyed = true
    end

    return runtime
end

return Teleport
