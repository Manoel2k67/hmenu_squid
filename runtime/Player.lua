local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = {}
local AUTO_COLLECT_BABY_KEY = "__HMENU_AUTO_COLLECT_BABY"
local AUTO_COMPLETE_HONEYCOMB_KEY = "__HMENU_AUTO_COMPLETE_HONEYCOMB"

function Player:Create(options)
    options = options or {}
    local localPlayer = Players.LocalPlayer
    local connections = {}
    local humanoidOriginals = setmetatable({}, { __mode = "k" })
    local collisionOriginals = setmetatable({}, { __mode = "k" })
    local ragdollAttributeOriginals = setmetatable({}, { __mode = "k" })
    local lightingOriginals
    local impactUntil = 0
    local destroyed = false
    local settings = {
        WalkSpeed = nil,
        JumpBoost = nil,
        Noclip = false,
        FullBright = false,
        AntiRagdoll = false,
        AntiKnockback = false,
        ManualSit = false,
        AutoCollectBaby = rawget(_G, AUTO_COLLECT_BABY_KEY) == true,
    }
    local attemptedBabyModels = setmetatable({}, { __mode = "k" })
    local babyAttemptGeneration = 0
    local attemptedHoneycombModels = setmetatable({}, { __mode = "k" })
    local honeycombAttemptGeneration = 0
    local honeycombMousePressed = false

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

    local function findBabyPrompt(model)
        if not model or not model.Parent or model.Name ~= "BabyPickup" then return nil end
        local trigger = model:FindFirstChild("Trigger")
        local prompt = trigger and trigger:FindFirstChild("PickupPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then return prompt end
        return nil
    end

    local function attemptBabyPickup(model, force)
        if destroyed or not model or not model.Parent then return end
        if not force and not settings.AutoCollectBaby then return end
        if localPlayer:GetAttribute("HasBaby") == true then return end
        if attemptedBabyModels[model] and not force then return end

        attemptedBabyModels[model] = true
        babyAttemptGeneration = babyAttemptGeneration + 1
        local generation = babyAttemptGeneration

        task.spawn(function()
            local deadline = os.clock() + 2
            local prompt = findBabyPrompt(model)
            while not prompt and model.Parent and os.clock() < deadline do
                task.wait()
                if destroyed or generation ~= babyAttemptGeneration then return end
                if not force and not settings.AutoCollectBaby then return end
                prompt = findBabyPrompt(model)
            end

            if not prompt or type(fireproximityprompt) ~= "function" then return end

            local originalDistance = prompt.MaxActivationDistance
            local originalHoldDuration = prompt.HoldDuration
            local originalLineOfSight = prompt.RequiresLineOfSight
            pcall(function()
                prompt.MaxActivationDistance = 1000
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
            end)
            local function finishPromptTest()
                pcall(function()
                    prompt.MaxActivationDistance = originalDistance
                    prompt.HoldDuration = originalHoldDuration
                    prompt.RequiresLineOfSight = originalLineOfSight
                end)
            end

            -- Give the client one frame to apply the local prompt range before triggering it.
            RunService.Heartbeat:Wait()
            if destroyed or generation ~= babyAttemptGeneration or not model.Parent then
                finishPromptTest()
                return
            end
            if not force and not settings.AutoCollectBaby then
                finishPromptTest()
                return
            end

            local ok = pcall(fireproximityprompt, prompt, 0, true)
            if not ok then
                ok = pcall(fireproximityprompt, prompt, 0)
            end
            if ok then
                task.wait(0.12)
                if model.Parent and localPlayer:GetAttribute("HasBaby") ~= true then
                    pcall(fireproximityprompt, prompt, 0)
                end
            end
            if not ok then
                finishPromptTest()
                return
            end

            local confirmationDeadline = os.clock() + 3
            while not destroyed and os.clock() < confirmationDeadline do
                if localPlayer:GetAttribute("HasBaby") == true then
                    finishPromptTest()
                    return
                end
                if not model.Parent then
                    finishPromptTest()
                    return
                end
                task.wait(0.05)
            end
            finishPromptTest()
        end)
    end

    local function currentBabyModel()
        local model = Workspace:FindFirstChild("BabyPickup")
        return model and model:IsA("Model") and model or nil
    end

    local function executorFunction(name)
        local environment = _G
        if type(getgenv) == "function" then
            local ok, result = pcall(getgenv)
            if ok and type(result) == "table" then environment = result end
        end
        local value = rawget(environment, name)
        return type(value) == "function" and value or nil
    end

    local function virtualInputManager()
        local ok, service = pcall(game.GetService, game, "VirtualInputManager")
        return ok and service or nil
    end

    local function moveMouse(position)
        local x = math.floor(position.X + 0.5)
        local y = math.floor(position.Y + 0.5)
        local moveAbsolute = executorFunction("mousemoveabs")
        if moveAbsolute then
            return pcall(moveAbsolute, x, y)
        end

        local moveRelative = executorFunction("mousemoverel")
        if moveRelative then
            local current = UserInputService:GetMouseLocation()
            return pcall(moveRelative, x - current.X, y - current.Y)
        end

        local manager = virtualInputManager()
        if manager then
            return pcall(function()
                manager:SendMouseMoveEvent(x, y, game)
            end)
        end
        return false
    end

    local function setHoneycombMousePressed(pressed, position)
        local functionName = pressed and "mouse1press" or "mouse1release"
        local executorInput = executorFunction(functionName)
        if executorInput then
            local ok = pcall(executorInput)
            if ok then
                honeycombMousePressed = pressed
                return true
            end
        end

        local manager = virtualInputManager()
        if manager then
            local x = math.floor(position.X + 0.5)
            local y = math.floor(position.Y + 0.5)
            local ok = pcall(function()
                manager:SendMouseButtonEvent(x, y, 0, pressed, game, 0)
            end)
            if ok then
                honeycombMousePressed = pressed
                return true
            end
        end
        return false
    end

    local function releaseHoneycombMouse()
        if not honeycombMousePressed then return end
        setHoneycombMousePressed(false, UserInputService:GetMouseLocation())
        honeycombMousePressed = false
    end

    local function currentHoneycombShape()
        local map = Workspace:FindFirstChild("Map")
        local honeycomb = map and map:FindFirstChild("Honeycomb")
        local shapes = honeycomb and honeycomb:FindFirstChild("Shapes")
        if not shapes then return nil, nil end

        local shape = shapes:FindFirstChild(localPlayer.Name)
        if shape then return shape, shape:FindFirstChild("Path") end

        -- Some rounds remove the local ownership attributes before the cookie
        -- view closes. In that case, use the shape that actually occupies the
        -- current camera instead of selecting another player's distant cookie.
        local camera = Workspace.CurrentCamera
        if not camera then return nil, nil end

        local viewportCenter = camera.ViewportSize / 2
        local bestShape
        local bestPath
        local bestScore = -math.huge
        for _, candidate in ipairs(shapes:GetChildren()) do
            local candidatePath = candidate:FindFirstChild("Path")
            if candidatePath then
                local visibleCount = 0
                local minimum = Vector2.new(math.huge, math.huge)
                local maximum = Vector2.new(-math.huge, -math.huge)
                local centerTotal = Vector2.zero
                for _, descendant in ipairs(candidatePath:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        local projected, visible = camera:WorldToScreenPoint(descendant.Position)
                        if visible and projected.Z > 0 then
                            local point = Vector2.new(projected.X, projected.Y)
                            visibleCount = visibleCount + 1
                            centerTotal = centerTotal + point
                            minimum = Vector2.new(math.min(minimum.X, point.X), math.min(minimum.Y, point.Y))
                            maximum = Vector2.new(math.max(maximum.X, point.X), math.max(maximum.Y, point.Y))
                        end
                    end
                end

                if visibleCount >= 40 then
                    local size = maximum - minimum
                    local area = size.X * size.Y
                    local center = centerTotal / visibleCount
                    local centerDistance = (center - viewportCenter).Magnitude
                    local score = area + visibleCount * 100 - centerDistance * 10
                    if area >= 2500 and score > bestScore then
                        bestScore = score
                        bestShape = candidate
                        bestPath = candidatePath
                    end
                end
            end
        end

        return bestShape, bestPath
    end

    local function projectedPathPoints(path)
        local camera = Workspace.CurrentCamera
        if not camera or not path then return {} end

        local points = {}
        for _, descendant in ipairs(path:GetDescendants()) do
            if descendant:IsA("BasePart") then
                local screenPoint, visible = camera:WorldToScreenPoint(descendant.Position)
                if visible and screenPoint.Z > 0 then
                    table.insert(points, {
                        Part = descendant,
                        Screen = Vector2.new(screenPoint.X, screenPoint.Y),
                    })
                end
            end
        end
        return points
    end

    local function routeScore(route)
        local total = 0
        local longest = 0
        for index = 2, #route do
            local distance = (route[index].Screen - route[index - 1].Screen).Magnitude
            total = total + distance
            longest = math.max(longest, distance)
        end
        return longest, total
    end

    local function greedyRoute(points, firstIndex)
        local route = {}
        local used = {}
        local currentIndex = firstIndex

        while currentIndex do
            used[currentIndex] = true
            table.insert(route, points[currentIndex])

            local closestIndex
            local closestDistance = math.huge
            for index, point in ipairs(points) do
                if not used[index] then
                    local distance = (point.Screen - points[currentIndex].Screen).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestIndex = index
                    end
                end
            end
            currentIndex = closestIndex
        end
        return route
    end

    local function honeycombStartIndex(shape, path, points)
        local camera = Workspace.CurrentCamera
        if camera then
            local bestMarkerDistance = math.huge
            local markerPosition
            for _, descendant in ipairs(shape:GetDescendants()) do
                if descendant:IsA("BasePart") and not descendant:IsDescendantOf(path) then
                    local color = descendant.Color
                    local looksGreen = color.G > 0.65 and color.G > color.R * 1.25 and color.G > color.B * 1.15
                    if looksGreen then
                        local projected, visible = camera:WorldToScreenPoint(descendant.Position)
                        if visible and projected.Z > 0 then
                            local position = Vector2.new(projected.X, projected.Y)
                            local distance = (position - camera.ViewportSize / 2).Magnitude
                            if distance < bestMarkerDistance then
                                bestMarkerDistance = distance
                                markerPosition = position
                            end
                        end
                    end
                end
            end

            if markerPosition then
                local closestIndex = 1
                local closestDistance = math.huge
                for index, point in ipairs(points) do
                    local distance = (point.Screen - markerPosition).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestIndex = index
                    end
                end
                return closestIndex
            end
        end

        -- The visible start arrow is on the right side in every observed
        -- Honeycomb shape. This is safer than using the menu cursor position.
        local rightmostIndex = 1
        for index = 2, #points do
            if points[index].Screen.X > points[rightmostIndex].Screen.X then
                rightmostIndex = index
            end
        end
        return rightmostIndex
    end

    local function rotateRoute(points, startIndex, reverse)
        local route = {}
        for offset = 0, #points - 1 do
            local index
            if reverse then
                index = ((startIndex - offset - 1) % #points) + 1
            else
                index = ((startIndex + offset - 1) % #points) + 1
            end
            table.insert(route, points[index])
        end
        return route
    end

    local function orderedPath(shape, path, points)
        if #points < 2 then return points end

        local startIndex = honeycombStartIndex(shape, path, points)

        local greedy = greedyRoute(points, startIndex)
        local naturalForward = rotateRoute(points, startIndex, false)
        local naturalReverse = rotateRoute(points, startIndex, true)
        local forwardLongest, forwardTotal = routeScore(naturalForward)
        local reverseLongest, reverseTotal = routeScore(naturalReverse)
        local natural = naturalForward
        local naturalLongest = forwardLongest
        local naturalTotal = forwardTotal
        if reverseLongest < forwardLongest
            or (reverseLongest == forwardLongest and reverseTotal < forwardTotal) then
            natural = naturalReverse
            naturalLongest = reverseLongest
            naturalTotal = reverseTotal
        end
        local greedyLongest, greedyTotal = routeScore(greedy)
        if naturalLongest <= greedyLongest * 1.15 and naturalTotal <= greedyTotal * 1.35 then
            return natural
        end
        return greedy
    end

    local function markHoneycombPathCompleted(path)
        for _, descendant in ipairs(path:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant:GetAttribute("Completed") ~= true then
                pcall(function() descendant:SetAttribute("Completed", true) end)
            end
        end
    end

    local function menuScreenGui()
        local parent = options and options.Parent
        local gui = parent and parent:FindFirstChild("HMenu")
        return gui and gui:IsA("ScreenGui") and gui or nil
    end

    local function traceHoneycomb(shape, path, generation)
        local points = projectedPathPoints(path)
        if #points < 8 then return false end

        local route = orderedPath(shape, path, points)
        local originalMousePosition = UserInputService:GetMouseLocation()
        local menuGui = menuScreenGui()
        local menuWasEnabled = menuGui and menuGui.Enabled
        if menuGui then menuGui.Enabled = false end

        local function stillValid()
            return not destroyed
                and settings.AutoCompleteHoneycomb
                and generation == honeycombAttemptGeneration
                and shape.Parent ~= nil
                and path.Parent == shape
        end

        local success = false
        local ok, failure = pcall(function()
            -- Completed=true is the state observed on every green segment. If
            -- the minigame checks this client-side, this finishes immediately;
            -- the real mouse trace remains as a fallback for raycast validation.
            markHoneycombPathCompleted(path)
            RunService.Heartbeat:Wait()
            if not stillValid() then
                success = true
                return
            end

            if not moveMouse(route[1].Screen) then
                error("executor sem suporte para mover o mouse")
            end
            RunService.RenderStepped:Wait()
            if not stillValid() then return end
            if not setHoneycombMousePressed(true, route[1].Screen) then
                error("executor sem suporte para pressionar o mouse")
            end

            for index = 2, #route do
                if not stillValid() then return end
                local from = route[index - 1].Screen
                local target = route[index].Screen
                local distance = (target - from).Magnitude
                local steps = math.max(1, math.ceil(distance / 2))
                for step = 1, steps do
                    if not stillValid() then return end
                    local position = from:Lerp(target, step / steps)
                    if not moveMouse(position) then
                        error("falha ao mover o mouse")
                    end
                    RunService.RenderStepped:Wait()
                end
            end
            success = stillValid()
            task.wait(0.08)
        end)

        releaseHoneycombMouse()
        moveMouse(originalMousePosition)
        if menuGui and menuGui.Parent then menuGui.Enabled = menuWasEnabled end
        if not ok then
            warn("[HMenu] Auto Complete Honeycomb falhou:", failure)
            return false
        end
        return success
    end

    local function startHoneycombMonitor()
        honeycombAttemptGeneration = honeycombAttemptGeneration + 1
        local generation = honeycombAttemptGeneration
        attemptedHoneycombModels = setmetatable({}, { __mode = "k" })

        task.spawn(function()
            local observedShape
            local observedCount = 0
            local stableSince = 0
            while not destroyed
                and settings.AutoCompleteHoneycomb
                and generation == honeycombAttemptGeneration do
                local shape, path = currentHoneycombShape()
                if shape and path and not attemptedHoneycombModels[shape] then
                    local points = projectedPathPoints(path)
                    local count = #points
                    if shape ~= observedShape or count ~= observedCount then
                        observedShape = shape
                        observedCount = count
                        stableSince = os.clock()
                    elseif count >= 40 and os.clock() - stableSince >= 0.45 then
                        attemptedHoneycombModels[shape] = true
                        traceHoneycomb(shape, path, generation)
                    end
                else
                    observedShape = nil
                    observedCount = 0
                    stableSince = 0
                end
                task.wait(0.2)
            end
            releaseHoneycombMouse()
        end)
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

    local function neutralizeKnockback()
        local rootPart = currentRootPart()
        if not rootPart then return end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
    end

    local function applyManualSit()
        local humanoid = currentHumanoid()
        if not humanoid or humanoid.Health <= 0 then return end

        if not humanoid.Sit or humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            humanoid.Sit = true
            humanoid:ChangeState(Enum.HumanoidStateType.Seated)
        end
    end

    local function standUp()
        local humanoid = currentHumanoid()
        if not humanoid or humanoid.Health <= 0 then return end

        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    local function beginImpactWindow()
        if not settings.AntiKnockback then return end
        impactUntil = math.max(impactUntil, os.clock() + 0.35)
        neutralizeKnockback()
        task.defer(function()
            if not destroyed and settings.AntiKnockback then neutralizeKnockback() end
        end)
    end

    local function isLocalCharacter(value)
        return value == currentCharacter()
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local movementRemote = remotes and remotes:FindFirstChild("PlayerMovementClientSide")
    if movementRemote and movementRemote:IsA("RemoteEvent") then
        connect(movementRemote.OnClientEvent, function(action, target, duration)
            if destroyed then return end

            if action == "toggleRagdoll" and isLocalCharacter(target) then
                if settings.AntiRagdoll then
                    applyAntiRagdoll()
                    task.defer(function()
                        if not destroyed and settings.AntiRagdoll then applyAntiRagdoll() end
                    end)
                end
                beginImpactWindow()
            end
        end)
    end

    connect(RunService.Stepped, function()
        if destroyed then return end
        if settings.WalkSpeed ~= nil or settings.JumpBoost ~= nil then applyMovement() end
        if settings.Noclip then applyNoclip() end
        if settings.FullBright then applyFullBright() end
        if settings.AntiRagdoll then applyAntiRagdoll() end
        if settings.ManualSit then applyManualSit() end
        if settings.AntiKnockback and os.clock() < impactUntil then
            neutralizeKnockback()
        end
    end)

    connect(localPlayer.CharacterAdded, function(character)
        task.defer(function()
            if destroyed or character ~= currentCharacter() then return end
            local humanoid = character:WaitForChild("Humanoid", 10)
            if humanoid then
                rememberHumanoid(humanoid)
                applyMovement()
                if settings.AntiRagdoll then applyAntiRagdoll() end
                if settings.ManualSit then applyManualSit() end
            end
        end)
    end)

    connect(Workspace.ChildAdded, function(child)
        if destroyed or not settings.AutoCollectBaby then return end
        if child.Name == "BabyPickup" and child:IsA("Model") then
            attemptBabyPickup(child, false)
        end
    end)

    connect(Workspace.ChildRemoved, function(child)
        if child.Name == "BabyPickup" then
            attemptedBabyModels[child] = nil
        end
    end)

    if settings.AutoCollectBaby then
        task.defer(function()
            if destroyed or not settings.AutoCollectBaby then return end
            local model = currentBabyModel()
            if model then attemptBabyPickup(model, false) end
        end)
    end

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
            if not settings.AntiKnockback then
                impactUntil = 0
            end
        elseif name == "ManualSit" then
            settings.ManualSit = value == true
            if settings.ManualSit then applyManualSit() else standUp() end
        elseif name == "AutoCollectBaby" then
            settings.AutoCollectBaby = value == true
            rawset(_G, AUTO_COLLECT_BABY_KEY, settings.AutoCollectBaby)
            babyAttemptGeneration = babyAttemptGeneration + 1
            if settings.AutoCollectBaby then
                local model = currentBabyModel()
                if model then attemptBabyPickup(model, false) end
            end
        end
    end

    function runtime:Destroy()
        if destroyed then return end
        destroyed = true

        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        connections = {}
        honeycombAttemptGeneration = honeycombAttemptGeneration + 1
        releaseHoneycombMouse()
        restoreCollision()
        restoreLighting()
        restoreAntiRagdoll()
        if settings.ManualSit then standUp() end

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
