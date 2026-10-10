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
    local manualSitRootOriginals = setmetatable({}, { __mode = "k" })
    local pentathlonRootOriginals = setmetatable({}, { __mode = "k" })
    local pentathlonAttributeOriginals
    local pentathlonAttributeGuard = false
    local pentathlonRenderStepName = "HMenuPentathlonMovement_" .. tostring(localPlayer.UserId)
    local pentathlonRenderStepBound = false
    local pentathlonWasActive = false
    local pentathlonRecoveryUntil = 0
    local pentathlonRecoveryGeneration = 0
    local playerControls
    local lastControlsEnable = 0
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
        PentathlonMovement = false,
        ForceMovement = false,
        ManualSit = false,
        AutoMusicalChairs = false,
        AutoCollectBaby = rawget(_G, AUTO_COLLECT_BABY_KEY) == true,
    }
    local babyPickupWorkers = setmetatable({}, { __mode = "k" })
    local babyAttemptGeneration = 0
    local attemptedHoneycombModels = setmetatable({}, { __mode = "k" })
    local honeycombAttemptGeneration = 0
    local honeycombMousePressed = false
    local musicalChairGeneration = 0
    local musicalChairWarningShown = false
    local musicalChairAttempting = false

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
        if not prompt then prompt = model:FindFirstChild("PickupPrompt", true) end
        if prompt and prompt:IsA("ProximityPrompt") then return prompt end
        return nil
    end

    local function attemptBabyPickup(model, force)
        if destroyed or not model or not model.Parent then return end
        if not force and not settings.AutoCollectBaby then return end
        if localPlayer:GetAttribute("HasBaby") == true then return end
        if babyPickupWorkers[model] then return end

        babyPickupWorkers[model] = true
        local generation = babyAttemptGeneration

        task.spawn(function()
            local function stillValid()
                return not destroyed
                    and generation == babyAttemptGeneration
                    and model.Parent ~= nil
                    and localPlayer:GetAttribute("HasBaby") ~= true
                    and (force or settings.AutoCollectBaby)
            end

            while stillValid() do
                local prompt = findBabyPrompt(model)
                if prompt and prompt.Enabled then
                    local originalDistance = prompt.MaxActivationDistance
                    local originalHoldDuration = prompt.HoldDuration
                    local originalLineOfSight = prompt.RequiresLineOfSight

                    pcall(function()
                        prompt.MaxActivationDistance = 1000
                        prompt.HoldDuration = 0
                        prompt.RequiresLineOfSight = false
                    end)
                    RunService.Heartbeat:Wait()

                    if stillValid() and prompt.Parent and prompt.Enabled then
                        if type(fireproximityprompt) == "function" then
                            pcall(fireproximityprompt, prompt, 0, true)
                            task.wait(0.08)
                            if stillValid() then pcall(fireproximityprompt, prompt, 0) end
                            if stillValid() then pcall(fireproximityprompt, prompt) end
                        end
                    end

                    pcall(function()
                        prompt.MaxActivationDistance = originalDistance
                        prompt.HoldDuration = originalHoldDuration
                        prompt.RequiresLineOfSight = originalLineOfSight
                    end)
                end

                if stillValid() then task.wait(0.25) end
            end

            babyPickupWorkers[model] = nil
        end)
    end

    local function currentBabyModel()
        local model = Workspace:FindFirstChild("BabyPickup")
        return model and model:IsA("Model") and model or nil
    end

    local function startBabyMonitor()
        babyAttemptGeneration = babyAttemptGeneration + 1
        local generation = babyAttemptGeneration
        babyPickupWorkers = setmetatable({}, { __mode = "k" })

        task.spawn(function()
            while not destroyed and settings.AutoCollectBaby and generation == babyAttemptGeneration do
                if localPlayer:GetAttribute("HasBaby") ~= true then
                    local model = currentBabyModel()
                    if model then attemptBabyPickup(model, false) end
                end
                task.wait(0.35)
            end
        end)
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

    local function musicalChairsFolder()
        local map = Workspace:FindFirstChild("Map")
        local musicalChairs = map and map:FindFirstChild("MusicalChairs")
        local chairs = musicalChairs and musicalChairs:FindFirstChild("Chairs")
        return chairs
    end

    local function chairParts(model)
        if not model or not model:IsA("Model") then return nil, nil end
        local seat = model:FindFirstChild("Seat")
        local trigger = model:FindFirstChild("Trigger")
        if not seat or not seat:IsA("Seat") or not trigger or not trigger:IsA("BasePart") then
            return nil, nil
        end
        if not trigger:FindFirstChildOfClass("TouchTransmitter") then return nil, nil end
        return seat, trigger
    end

    local function isReallySeated(humanoid, chairs)
        local seat = humanoid and humanoid.SeatPart
        if not seat or not chairs or not seat:IsDescendantOf(chairs) then return false end
        if seat.Occupant ~= humanoid then return false end
        local weld = seat:FindFirstChild("SeatWeld")
        return weld ~= nil and weld:IsA("Weld")
    end

    local function nearestAvailableChair(chairs, rootPart)
        local bestSeat
        local bestTrigger
        local bestDistance = math.huge
        for _, model in ipairs(chairs:GetChildren()) do
            local seat, trigger = chairParts(model)
            if seat and seat.Occupant == nil then
                local distance = (trigger.Position - rootPart.Position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestSeat = seat
                    bestTrigger = trigger
                end
            end
        end
        return bestSeat, bestTrigger, bestDistance
    end

    local function attemptMusicalChair()
        if destroyed or not settings.AutoMusicalChairs then return false end
        if localPlayer:GetAttribute("PlayingMusicalChairs") ~= true then return false end
        if musicalChairAttempting then return false end

        local humanoid = currentHumanoid()
        local rootPart = currentRootPart()
        local chairs = musicalChairsFolder()
        if not humanoid or humanoid.Health <= 0 or not rootPart or not chairs then return false end
        if isReallySeated(humanoid, chairs) then return true end

        local seat, trigger, distance = nearestAvailableChair(chairs, rootPart)
        if not seat or not trigger then return false end

        musicalChairAttempting = true
        local fireTouch = executorFunction("firetouchinterest")
        if fireTouch then
            pcall(fireTouch, rootPart, trigger, 0)
            RunService.Heartbeat:Wait()
            pcall(fireTouch, rootPart, trigger, 1)
        elseif distance <= 8 then
            -- Without a touch helper, only request a real seat that the
            -- character has physically reached.
            pcall(seat.Sit, seat, humanoid)
        elseif not musicalChairWarningShown then
            musicalChairWarningShown = true
            warn("[HMenu] Auto cadeira precisa de firetouchinterest neste executor.")
        end

        local seated = isReallySeated(humanoid, chairs)
        musicalChairAttempting = false
        return seated
    end

    local function startMusicalChairMonitor()
        musicalChairGeneration = musicalChairGeneration + 1
        local generation = musicalChairGeneration
        musicalChairWarningShown = false
        task.spawn(function()
            while not destroyed and settings.AutoMusicalChairs and generation == musicalChairGeneration do
                attemptMusicalChair()
                task.wait(0.08)
            end
        end)
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
        local rootPart = currentRootPart()
        if not humanoid or humanoid.Health <= 0 or not rootPart then return end

        if manualSitRootOriginals[rootPart] == nil then
            manualSitRootOriginals[rootPart] = {
                Anchored = rootPart.Anchored,
            }
        end
        rootPart.Anchored = true

        if not humanoid.Sit or humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            humanoid.Sit = true
            humanoid:ChangeState(Enum.HumanoidStateType.Seated)
        end
    end

    local function standUp()
        local humanoid = currentHumanoid()
        if humanoid and humanoid.Health > 0 then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        for rootPart, originals in pairs(manualSitRootOriginals) do
            if rootPart and rootPart.Parent then
                rootPart.Anchored = originals.Anchored
            end
            manualSitRootOriginals[rootPart] = nil
        end
    end

    local function pentathlonIsActive()
        return localPlayer:GetAttribute("PENTA_ONGOING") == true
            and localPlayer:GetAttribute("PlayingPentathlon") == true
    end

    local function currentPlayerControls()
        if playerControls then return playerControls end
        local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
        local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
        if not playerModule or not playerModule:IsA("ModuleScript") then return nil end

        local ok, module = pcall(require, playerModule)
        if not ok or type(module) ~= "table" or type(module.GetControls) ~= "function" then return nil end
        local controlsOk, controls = pcall(module.GetControls, module)
        if controlsOk and controls then playerControls = controls end
        return playerControls
    end

    local function rememberPentathlonAttributes()
        if pentathlonAttributeOriginals then return end
        pentathlonAttributeOriginals = {}
        for _, name in ipairs({ "DISABLE_MOVEMENT", "DISABLE_WALKSPEED" }) do
            local value = localPlayer:GetAttribute(name)
            pentathlonAttributeOriginals[name] = {
                HadValue = value ~= nil,
                Value = value,
            }
        end
    end

    local function forcePentathlonAttributes()
        if pentathlonAttributeGuard or not settings.PentathlonMovement or not pentathlonIsActive() then return end
        pentathlonAttributeGuard = true
        if localPlayer:GetAttribute("DISABLE_MOVEMENT") ~= false then
            localPlayer:SetAttribute("DISABLE_MOVEMENT", false)
        end
        if localPlayer:GetAttribute("DISABLE_WALKSPEED") ~= false then
            localPlayer:SetAttribute("DISABLE_WALKSPEED", false)
        end
        pentathlonAttributeGuard = false
    end

    local function applyPentathlonMovement()
        if not pentathlonIsActive() then return end
        rememberPentathlonAttributes()

        forcePentathlonAttributes()

        local humanoid = currentHumanoid()
        if humanoid and humanoid.Health > 0 then
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            if settings.WalkSpeed ~= nil then humanoid.WalkSpeed = settings.WalkSpeed end
        end

        local rootPart = currentRootPart()
        if rootPart and not settings.ManualSit then
            if pentathlonRootOriginals[rootPart] == nil then
                pentathlonRootOriginals[rootPart] = { Anchored = rootPart.Anchored }
            end
            rootPart.Anchored = false
        end

        if os.clock() - lastControlsEnable >= 0.25 then
            lastControlsEnable = os.clock()
            local controls = currentPlayerControls()
            if controls and type(controls.Enable) == "function" then
                pcall(controls.Enable, controls)
            end
        end
    end

    local function keyboardPentathlonDirection()
        if UserInputService:GetFocusedTextBox() then return Vector3.zero end

        local horizontal = 0
        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
            horizontal = horizontal + 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
            horizontal = horizontal - 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
            vertical = vertical + 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
            vertical = vertical - 1
        end
        if horizontal == 0 and vertical == 0 then return Vector3.zero end

        local camera = Workspace.CurrentCamera
        local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
        local right = camera and camera.CFrame.RightVector or Vector3.new(1, 0, 0)
        look = Vector3.new(look.X, 0, look.Z)
        right = Vector3.new(right.X, 0, right.Z)
        if look.Magnitude < 0.001 then look = Vector3.new(0, 0, -1) else look = look.Unit end
        if right.Magnitude < 0.001 then right = Vector3.new(1, 0, 0) else right = right.Unit end

        local direction = right * horizontal + look * vertical
        return direction.Magnitude > 1 and direction.Unit or direction
    end

    local function drivePentathlonMovement()
        if settings.ManualSit then return end
        local phaseActive = pentathlonIsActive()
        local recovering = os.clock() < pentathlonRecoveryUntil
        if not settings.PentathlonMovement and not settings.ForceMovement and not recovering then return end
        if not phaseActive and not settings.ForceMovement and not recovering then return end
        if phaseActive and settings.PentathlonMovement then applyPentathlonMovement() end

        local humanoid = currentHumanoid()
        local rootPart = currentRootPart()
        if not humanoid or humanoid.Health <= 0 or not rootPart then return end
        if humanoid.SeatPart then return end

        if settings.ForceMovement then
            rootPart.Anchored = false
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            if os.clock() - lastControlsEnable >= 0.1 then
                lastControlsEnable = os.clock()
                local controls = currentPlayerControls()
                if controls and type(controls.Enable) == "function" then
                    pcall(controls.Enable, controls)
                end
            end
        end

        local direction = keyboardPentathlonDirection()
        humanoid:Move(direction, false)

        if direction.Magnitude > 0 then
            local speed = settings.WalkSpeed or humanoid.WalkSpeed
            speed = math.clamp(tonumber(speed) or 16, 8, 200)
            local velocity = rootPart.AssemblyLinearVelocity
            rootPart.AssemblyLinearVelocity = Vector3.new(direction.X * speed, velocity.Y, direction.Z * speed)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid.Jump = true
        end
    end

    local function bindPentathlonRenderStep()
        if pentathlonRenderStepBound then return end
        pentathlonRenderStepBound = true
        RunService:BindToRenderStep(pentathlonRenderStepName, Enum.RenderPriority.Last.Value + 10, function()
            if destroyed then return end
            drivePentathlonMovement()
        end)
    end

    local function unbindPentathlonRenderStep()
        if not pentathlonRenderStepBound then return end
        pentathlonRenderStepBound = false
        pcall(RunService.UnbindFromRenderStep, RunService, pentathlonRenderStepName)
    end

    local function restorePentathlonMovement()
        if not settings.PentathlonMovement and not settings.ForceMovement then
            unbindPentathlonRenderStep()
        end
        if pentathlonAttributeOriginals then
            for name in pairs(pentathlonAttributeOriginals) do
                -- Never restore a captured `true`: if the server has already
                -- ended the round, no later replication may arrive to unlock it.
                localPlayer:SetAttribute(name, nil)
            end
            pentathlonAttributeOriginals = nil
        end

        for rootPart in pairs(pentathlonRootOriginals) do
            if rootPart and rootPart.Parent and not settings.ManualSit then
                rootPart.Anchored = false
            end
            pentathlonRootOriginals[rootPart] = nil
        end

        local rootPart = currentRootPart()
        local humanoid = currentHumanoid()
        if rootPart and not settings.ManualSit then rootPart.Anchored = false end
        if humanoid and humanoid.Health > 0 and not settings.ManualSit then
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:Move(Vector3.zero, false)
        end

        local controls = currentPlayerControls()
        if controls and type(controls.Enable) == "function" then
            pcall(controls.Enable, controls)
        end
    end

    local function startPentathlonRecovery(duration)
        pentathlonRecoveryGeneration = pentathlonRecoveryGeneration + 1
        local generation = pentathlonRecoveryGeneration
        pentathlonRecoveryUntil = os.clock() + (duration or 8)
        restorePentathlonMovement()
        bindPentathlonRenderStep()

        task.spawn(function()
            while not destroyed and generation == pentathlonRecoveryGeneration
                and os.clock() < pentathlonRecoveryUntil and not pentathlonIsActive() do
                local rootPart = currentRootPart()
                local humanoid = currentHumanoid()
                if rootPart and not settings.ManualSit then rootPart.Anchored = false end
                if humanoid and humanoid.Health > 0 and not settings.ManualSit then
                    humanoid.PlatformStand = false
                    humanoid.AutoRotate = true
                end
                local controls = currentPlayerControls()
                if controls and type(controls.Enable) == "function" then
                    pcall(controls.Enable, controls)
                end
                task.wait(0.1)
            end
            if not destroyed and generation == pentathlonRecoveryGeneration
                and not settings.PentathlonMovement and not settings.ForceMovement then
                unbindPentathlonRenderStep()
            end
        end)
    end

    for _, attributeName in ipairs({ "DISABLE_MOVEMENT", "DISABLE_WALKSPEED" }) do
        connect(localPlayer:GetAttributeChangedSignal(attributeName), function()
            if destroyed or pentathlonAttributeGuard then return end
            if settings.PentathlonMovement and pentathlonIsActive()
                and localPlayer:GetAttribute(attributeName) ~= false then
                task.defer(forcePentathlonAttributes)
            end
        end)
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
        if settings.PentathlonMovement then
            if pentathlonIsActive() then
                if not pentathlonWasActive then
                    pentathlonRecoveryGeneration = pentathlonRecoveryGeneration + 1
                    pentathlonRecoveryUntil = 0
                end
                pentathlonWasActive = true
                bindPentathlonRenderStep()
                applyPentathlonMovement()
            elseif pentathlonWasActive or pentathlonAttributeOriginals then
                pentathlonWasActive = false
                startPentathlonRecovery(8)
            end
        end
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
                if settings.PentathlonMovement then applyPentathlonMovement() end
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
            babyPickupWorkers[child] = nil
        end
    end)

    connect(Workspace.DescendantAdded, function(descendant)
        if destroyed or not settings.AutoMusicalChairs then return end
        if descendant:IsA("TouchTransmitter") then
            local trigger = descendant.Parent
            local chair = trigger and trigger.Parent
            local chairs = musicalChairsFolder()
            if trigger and trigger.Name == "Trigger" and chairs and chair and chair.Parent == chairs then
                task.defer(attemptMusicalChair)
            end
        end
    end)

    if settings.AutoCollectBaby then
        startBabyMonitor()
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
        elseif name == "PentathlonMovement" then
            settings.PentathlonMovement = value == true
            if settings.PentathlonMovement then
                bindPentathlonRenderStep()
                if pentathlonIsActive() then
                    pentathlonWasActive = true
                    applyPentathlonMovement()
                else
                    pentathlonWasActive = false
                    startPentathlonRecovery(8)
                end
            else
                pentathlonWasActive = false
                startPentathlonRecovery(3)
            end
        elseif name == "ForceMovement" then
            settings.ForceMovement = value == true
            if settings.ForceMovement then
                pentathlonRecoveryGeneration = pentathlonRecoveryGeneration + 1
                pentathlonRecoveryUntil = 0
                restorePentathlonMovement()
                bindPentathlonRenderStep()
            elseif not settings.PentathlonMovement then
                pentathlonRecoveryGeneration = pentathlonRecoveryGeneration + 1
                pentathlonRecoveryUntil = 0
                unbindPentathlonRenderStep()
                restorePentathlonMovement()
            end
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
        elseif name == "AutoMusicalChairs" then
            settings.AutoMusicalChairs = value == true
            if settings.AutoMusicalChairs then
                startMusicalChairMonitor()
            else
                musicalChairGeneration = musicalChairGeneration + 1
                musicalChairAttempting = false
            end
        elseif name == "AutoCollectBaby" then
            settings.AutoCollectBaby = value == true
            rawset(_G, AUTO_COLLECT_BABY_KEY, settings.AutoCollectBaby)
            if settings.AutoCollectBaby then
                startBabyMonitor()
            else
                babyAttemptGeneration = babyAttemptGeneration + 1
                babyPickupWorkers = setmetatable({}, { __mode = "k" })
            end
        end
    end

    function runtime:Destroy()
        if destroyed then return end
        destroyed = true
        pentathlonRecoveryGeneration = pentathlonRecoveryGeneration + 1
        pentathlonRecoveryUntil = 0
        unbindPentathlonRenderStep()

        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        connections = {}
        honeycombAttemptGeneration = honeycombAttemptGeneration + 1
        musicalChairGeneration = musicalChairGeneration + 1
        releaseHoneycombMouse()
        restoreCollision()
        restoreLighting()
        restoreAntiRagdoll()
        restorePentathlonMovement()
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
