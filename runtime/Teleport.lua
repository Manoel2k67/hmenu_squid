local Players = game:GetService("Players")

local Teleport = {}

function Teleport:Create()
    local localPlayer = Players.LocalPlayer
    local destroyed = false
    local settings = {
        SelectedPlayer = "Selecione um jogador",
        ArrivalMode = "Atrás",
        ArrivalDistance = 4,
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
