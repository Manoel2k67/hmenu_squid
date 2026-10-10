-- Deterministic runtime regression tests; no Roblox server or executor emulation.
local clockTime = 0
local queue = {}
os = { clock = function() return clockTime end }
task = {}
function task.spawn(callback) table.insert(queue, coroutine.create(callback)) end
task.defer = task.spawn
function task.wait() coroutine.yield() end
local function tick(count)
    for _ = 1, count or 1 do
        clockTime += 0.1
        local pending = queue
        queue = {}
        for _, thread in ipairs(pending) do
            local ok, message = coroutine.resume(thread)
            assert(ok, message)
            if coroutine.status(thread) ~= "dead" then table.insert(queue, thread) end
        end
    end
end
local function signal()
    local callbacks = {}
    return {
        Connect = function(_, callback)
            local item = { callback = callback, connected = true }
            table.insert(callbacks, item)
            return { Disconnect = function() item.connected = false end }
        end,
        Wait = function() coroutine.yield() end,
        Fire = function(_, ...)
            for _, item in ipairs(callbacks) do if item.connected then item.callback(...) end end
        end,
    }
end
local methods = {}
local function instance(name, class, parent)
    local object = setmetatable({ Name = name, ClassName = class, Parent = parent,
        children = {}, attributes = {}, CanTouch = true }, { __index = methods })
    if parent then table.insert(parent.children, object) end
    return object
end
function methods:IsA(class)
    return self.ClassName == class or class == "BasePart" and (self.ClassName == "Part" or self.ClassName == "Seat")
end
function methods:FindFirstChild(name)
    for _, child in ipairs(self.children) do if child.Name == name then return child end end
end
function methods:FindFirstChildOfClass(class)
    for _, child in ipairs(self.children) do if child:IsA(class) then return child end end
end
function methods:GetChildren() return self.children end
function methods:IsDescendantOf(parent)
    local ancestor = self.Parent
    while ancestor do
        if ancestor == parent then return true end
        ancestor = ancestor.Parent
    end
    return false
end
function methods:GetAttribute(name) return self.attributes[name] end
function methods:SetAttribute(name, value) self.attributes[name] = value end
function methods:GetAttributeChangedSignal() return signal() end
function methods:GetState() return self.State end
function methods:GetStateEnabled() return true end
function methods:SetStateEnabled() end
function methods:ChangeState(state) self.State = state end
function methods:Move() self.MoveCalls = (self.MoveCalls or 0) + 1 end
function methods:Sit() self.SitCalls = (self.SitCalls or 0) + 1 end

Vector3 = {}
local vectorMeta = {}
function Vector3.new(x, y, z)
    return setmetatable({ X = x, Y = y, Z = z, Magnitude = math.sqrt(x*x + y*y + z*z) }, vectorMeta)
end
vectorMeta.__sub = function(a, b) return Vector3.new(a.X-b.X, a.Y-b.Y, a.Z-b.Z) end
Vector3.zero = Vector3.new(0, 0, 0)
Enum = { HumanoidStateType = { Ragdoll = "Ragdoll", FallingDown = "FallingDown",
    Physics = "Physics", GettingUp = "GettingUp", Seated = "Seated" },
    RenderPriority = { Last = { Value = 2000 } } }
local services = { Players = {}, RunService = {}, Workspace = instance("Workspace", "Workspace"),
    ReplicatedStorage = instance("ReplicatedStorage", "ReplicatedStorage"), Lighting = {}, UserInputService = {} }
game = { GetService = function(_, name) return services[name] end }
local executor = {}
getgenv = function() return executor end
warn = function() end
local function fixture(Player, distance)
    clockTime, queue = 0, {}
    local ws, rs = services.Workspace, services.RunService
    ws.children = {}
    ws.ChildAdded, ws.ChildRemoved, ws.DescendantAdded = signal(), signal(), signal()
    rs.Stepped, rs.Heartbeat = signal(), signal()
    rs.BindToRenderStep = function(_, _, _, callback) rs.RenderCallback = callback end
    rs.UnbindFromRenderStep = function() rs.RenderCallback = nil end
    services.ReplicatedStorage.children = {}
    local remotes = instance("Remotes", "Folder", services.ReplicatedStorage)
    local movementRemote = instance("PlayerMovementClientSide", "RemoteEvent", remotes)
    movementRemote.OnClientEvent = signal()
    local player = instance("LocalPlayer", "Player")
    player.UserId, player.CharacterAdded = 1, signal()
    player.attributes.PlayingMusicalChairs = true
    local character = instance("Character", "Model", ws)
    player.Character = character
    services.Players.LocalPlayer = player
    local humanoid = instance("Humanoid", "Humanoid", character)
    humanoid.Health, humanoid.Sit, humanoid.State = 150, false, "Running"
    local root = instance("HumanoidRootPart", "Part", character)
    root.Position, root.Anchored = Vector3.zero, false
    root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
    local map = instance("Map", "Folder", ws)
    local phase = instance("MusicalChairs", "Model", map)
    local chairs = instance("Chairs", "Folder", phase)
    local function addChair(name, x)
        local model = instance(name, "Model", chairs)
        local seat = instance("Seat", "Seat", model)
        seat.Disabled = true
        local trigger = instance("Trigger", "Part", model)
        trigger.Position = Vector3.new(x, 0, 0)
        trigger.Size = Vector3.new(2, 4.13, 2.51)
        trigger.Anchored, trigger.CanCollide = true, false
        trigger.CFrame = { PointToObjectSpace = function(_, position) return position - trigger.Position end }
        trigger.Touched = signal()
        local touch = instance("TouchInterest", "TouchTransmitter", trigger)
        return seat, trigger, touch
    end
    local seat, trigger, touch = addChair("Chair", distance or 2)
    local calls = {}
    executor.firetouchinterest = function(part, target, state)
        table.insert(calls, { part = part, target = target, state = state, time = clockTime })
    end
    local copiedReport
    executor.setclipboard = function(report) copiedReport = report end
    local runtime = Player:Create()
    return { runtime = runtime, player = player, humanoid = humanoid, root = root,
        seat = seat, trigger = trigger, touch = touch, calls = calls, addChair = addChair,
        movementRemote = movementRemote,
        report = function() runtime:Set("CopyMusicalChairDiagnostics"); return copiedReport end,
        experiment = function(reach)
            if reach ~= nil then runtime:Set("MusicalChairReach", reach) end
            runtime:Set("MusicalChairMode", "Trigger ampliado")
        end,
        enable = function() runtime:Set("AutoMusicalChairs", true); tick() end }
end

function runMusicalChairTests(Player)
    local passed = 0
    local function test(name, callback)
        callback()
        passed += 1
        print("PASS " .. name)
    end
    test("distant chairs never touch or reposition the character", function()
        local f = fixture(Player, 60)
        f.enable(); tick(30)
        assert(#f.calls == 0 and f.root.Position == Vector3.zero and not f.root.Anchored)
        f.root.Position = Vector3.new(58, 0, 0)
        tick()
        assert(#f.calls == 2, "approaching a chair should permit an attempt")
    end)
    test("one pair in the same frame; no retries or toggle spam", function()
        local f = fixture(Player, 4)
        f.enable()
        assert(#f.calls == 2 and f.calls[1].state == 0 and f.calls[2].state == 1)
        assert(f.calls[1].time == f.calls[2].time)
        f.runtime:Set("AutoMusicalChairs", false)
        f.runtime:Set("AutoMusicalChairs", true)
        f.runtime:Set("AutoMusicalChairs", true)
        services.Workspace.DescendantAdded:Fire(f.touch)
        tick(35)
        assert(#f.calls == 2)
        f.touch.Parent = nil
        f.trigger.children = {}
        instance("TouchInterest", "TouchTransmitter", f.trigger)
        tick()
        assert(#f.calls == 4, "new round must permit a new attempt")
    end)
    test("occupied, closed and untouchable chairs are skipped", function()
        local f = fixture(Player)
        f.seat.Occupant = instance("Other", "Humanoid")
        f.enable(); assert(#f.calls == 0)
        f.seat.Occupant = nil
        f.trigger.CanTouch = false
        tick(); assert(#f.calls == 0)
        f.trigger.CanTouch = true
        f.trigger.children = {}
        tick(); assert(#f.calls == 0)
    end)
    test("partial Occupant or SeatWeld binding blocks a second chair", function()
        for _, binding in ipairs({ "occupant", "weld", "seatpart" }) do
            local f = fixture(Player)
            f.addChair("OtherChair", 3)
            if binding == "occupant" then f.seat.Occupant = f.humanoid
            elseif binding == "seatpart" then f.humanoid.SeatPart = f.seat
            else
                local weld = instance("SeatWeld", "Weld", f.seat)
                weld.Enabled, weld.Part0, weld.Part1 = true, f.seat, f.root
            end
            f.enable(); tick(20)
            assert(#f.calls == 0, binding)
            f.humanoid.State = "Physics"
            f.runtime:Set("AntiRagdoll", true)
            assert(f.humanoid.State == "Physics", "protection must respect partial binding")
            local velocity = Vector3.new(7, 8, 9)
            f.root.AssemblyLinearVelocity = velocity
            f.root.AssemblyAngularVelocity = velocity
            f.runtime:Set("AntiKnockback", true)
            f.movementRemote.OnClientEvent:Fire("toggleRagdoll", f.player.Character, 2.25)
            assert(f.root.AssemblyLinearVelocity == velocity and f.root.AssemblyAngularVelocity == velocity)
            f.runtime:Set("ForceMovement", true)
            local moves = f.humanoid.MoveCalls
            services.RunService.RenderCallback()
            assert(f.humanoid.MoveCalls == moves, "forced movement must respect partial binding")
        end
    end)
    test("missing helper never fabricates a local seat", function()
        local f = fixture(Player)
        executor.firetouchinterest = nil
        f.enable(); tick(20)
        assert(#f.calls == 0 and not f.humanoid.Sit and f.humanoid.SeatPart == nil and f.seat.SitCalls == nil)
    end)
    test("disable, death, phase end, respawn and destroy cancel pending work", function()
        for _, action in ipairs({ "disable", "death", "phase", "respawn", "destroy" }) do
            local f = fixture(Player)
            f.addChair("OtherChair", 3)
            f.enable()
            if action == "disable" then f.runtime:Set("AutoMusicalChairs", false)
            elseif action == "death" then f.humanoid.Health = 0
            elseif action == "phase" then f.player.attributes.PlayingMusicalChairs = nil
            elseif action == "respawn" then f.player.Character = nil
            else f.runtime:Destroy() end
            tick(30)
            assert(#f.calls == 2, action)
        end
    end)
    test("pending request serializes competing descendant notifications", function()
        local f = fixture(Player)
        local _, _, otherTouch = f.addChair("OtherChair", 3)
        f.enable()
        for _ = 1, 10 do services.Workspace.DescendantAdded:Fire(otherTouch) end
        tick(5)
        assert(#f.calls == 2, "must await first request")
        f.seat.Occupant = f.humanoid
        tick(20)
        assert(#f.calls == 2, "late binding must block next chair")
    end)
    test("touch errors still end the pair and do not repeat", function()
        local f = fixture(Player)
        local original = executor.firetouchinterest
        executor.firetouchinterest = function(part, target, state)
            original(part, target, state)
            error("executor failure")
        end
        f.enable(); tick(30)
        assert(#f.calls == 2 and f.calls[2].state == 1)
    end)
    local function attempts(f)
        local _, count = string.gsub(f.report(), "Tentativa:", "")
        return count
    end
    test("expanded trigger covers a distant root and restores without synthetic touch", function()
        for _, distance in ipairs({ 60, 160, 161 }) do
            local f = fixture(Player, distance)
            local originalSize, originalFrame = f.trigger.Size, f.trigger.CFrame
            f.experiment(160)
            f.enable()
            assert(#f.calls == 0)
            if distance <= 160 then
                assert(f.trigger.Size.X / 2 >= distance + 2)
                assert(f.trigger.Size.Y >= originalSize.Y and f.trigger.Size.Z >= originalSize.Z)
                assert(attempts(f) == 1)
            else
                assert(f.trigger.Size == originalSize and attempts(f) == 0)
            end
            tick(30)
            assert(f.trigger.Size == originalSize and f.trigger.CFrame == originalFrame)
            assert(f.root.Position == Vector3.zero and not f.root.Anchored)
            assert(f.root.AssemblyLinearVelocity == Vector3.zero and f.seat.SitCalls == nil)
        end
    end)
    test("expanded geometry accounts for trigger rotation", function()
        local f = fixture(Player, 30)
        local offset = Vector3.new(-20, 3, 25)
        f.trigger.CFrame = { PointToObjectSpace = function() return offset end }
        local originalFrame = f.trigger.CFrame
        f.experiment(40); f.enable()
        assert(f.trigger.Size.X >= 44 and f.trigger.Size.Y >= 10 and f.trigger.Size.Z >= 54)
        assert(f.trigger.CFrame == originalFrame and #f.calls == 0)
    end)
    test("expanded mode permits one total pulse until old window markers retire", function()
        local f = fixture(Player, 60)
        local _, _, secondTouch = f.addChair("Second", 65)
        f.experiment(160); f.enable(); tick(30)
        assert(attempts(f) == 1)
        f.runtime:Set("AutoMusicalChairs", false)
        f.runtime:Set("AutoMusicalChairs", true)
        f.runtime:Set("MusicalChairMode", "Perto (4 studs)")
        f.experiment(80); tick(30)
        assert(attempts(f) == 1)
        f.touch.Parent = nil
        f.trigger.children = {}
        local newTouch = instance("TouchInterest", "TouchTransmitter", f.trigger)
        services.Workspace.DescendantAdded:Fire(newTouch)
        tick(30)
        assert(attempts(f) == 1)
        secondTouch.Parent = nil
        tick(30)
        assert(attempts(f) == 2 and #f.calls == 0)
    end)
    test("range slider does not rearm a pulse or flood the diagnostic", function()
        local f = fixture(Player, 12)
        f.experiment(8); f.enable(); tick(5)
        assert(attempts(f) == 0)
        f.runtime:Set("MusicalChairReach", 12); tick()
        assert(attempts(f) == 1)
        for index = 4, 160 do f.runtime:Set("MusicalChairReach", index) end
        tick(30)
        assert(attempts(f) == 1)
        assert(string.find(f.report(), "distancia=12.0 studs | alcance=12 studs", 1, true))
        assert(not string.find(f.report(), "Alcance experimental ajustado:", 1, true))
        f = fixture(Player, 5)
        f.runtime:Set("MusicalChairReach", 160); f.enable(); tick(5)
        assert(attempts(f) == 0 and #f.calls == 0)
    end)
    test("range bounds and invalid values are handled", function()
        local f = fixture(Player, 9)
        f.experiment(0/0); f.enable(); tick(5)
        assert(attempts(f) == 0 and string.find(f.report(), "efetivo: 8 studs", 1, true))
        f.runtime:Set("MusicalChairReach", 9999)
        assert(string.find(f.report(), "efetivo: 160 studs", 1, true))
        f.runtime:Set("MusicalChairReach", -99)
        assert(string.find(f.report(), "efetivo: 4 studs", 1, true))
        f.runtime:Set("MusicalChairReach", "invalid")
        assert(string.find(f.report(), "efetivo: 8 studs", 1, true))
    end)
    test("expanded pulse restores at one second and disconnects local contacts", function()
        local f = fixture(Player, 30)
        local originalSize = f.trigger.Size
        f.experiment(40); f.enable()
        f.trigger.Touched:Fire(instance("Other", "Part"))
        f.trigger.Touched:Fire(f.root)
        tick(12)
        assert(f.trigger.Size == originalSize)
        f.trigger.Touched:Fire(f.root)
        tick(20)
        assert(string.find(f.report(), "contatosLocais=1", 1, true))
        assert(string.find(f.report(), "sem confirmacao local", 1, true))
    end)
    test("nearby touch maintains normal argument order", function()
        local f = fixture(Player, 3)
        local originalSize = f.trigger.Size
        f.enable()
        assert(#f.calls == 2 and f.calls[1].part == f.root and f.calls[1].target == f.trigger)
        assert(f.calls[1].state == 0 and f.calls[2].state == 1 and f.calls[1].time == f.calls[2].time)
        assert(f.trigger.Size == originalSize)
    end)
    test("expanded mode works without firetouchinterest and restores on partial binding", function()
        local f = fixture(Player, 30)
        local originalSize = f.trigger.Size
        executor.firetouchinterest = nil
        f.experiment(40); f.enable()
        assert(f.trigger.Size ~= originalSize)
        f.seat.Occupant = f.humanoid
        tick()
        assert(f.trigger.Size == originalSize)
        tick(30)
        assert(#f.calls == 0 and string.find(f.report(), "vinculo local parcial", 1, true))
    end)
    test("expanded mode waits for continuous full binding", function()
        local f = fixture(Player, 30)
        f.experiment(40); f.enable()
        f.humanoid.SeatPart, f.seat.Occupant = f.seat, f.humanoid
        local weld = instance("SeatWeld", "Weld", f.seat)
        weld.Enabled, weld.Part0, weld.Part1 = true, f.seat, f.root
        tick(3)
        assert(not string.find(f.report(), "vinculo local estavel", 1, true))
        f.humanoid.SeatPart, f.seat.Occupant = nil, nil
        tick()
        f.humanoid.SeatPart, f.seat.Occupant = f.seat, f.humanoid
        tick(3)
        assert(not string.find(f.report(), "vinculo local estavel", 1, true))
        tick(5)
        assert(string.find(f.report(), "vinculo local estavel por 0.5s", 1, true))
    end)
    test("cancel, death, phase end, mode change, respawn and destroy restore the pulse", function()
        for _, action in ipairs({ "disable", "death", "phase", "mode", "respawn", "destroy", "touchremoved" }) do
            local f = fixture(Player, 30)
            local originalSize = f.trigger.Size
            f.experiment(40); f.enable()
            assert(f.trigger.Size ~= originalSize)
            if action == "disable" then f.runtime:Set("AutoMusicalChairs", false)
            elseif action == "death" then f.humanoid.Health = 0
            elseif action == "phase" then f.player.attributes.PlayingMusicalChairs = nil
            elseif action == "mode" then f.runtime:Set("MusicalChairMode", "Perto (4 studs)")
            elseif action == "respawn" then f.player.Character = nil
            elseif action == "touchremoved" then f.touch.Parent = nil
            else f.runtime:Destroy() end
            if action == "disable" or action == "mode" or action == "destroy" then
                assert(f.trigger.Size == originalSize, "explicit cancellation must restore immediately")
            end
            tick(30)
            assert(f.trigger.Size == originalSize and #f.calls == 0, action)
        end
    end)
    test("game size update is preserved instead of restoring an old value", function()
        local f = fixture(Player, 30)
        f.experiment(40); f.enable()
        local serverSize = Vector3.new(3, 4, 5)
        f.trigger.Size = serverSize
        tick(30)
        assert(f.trigger.Size == serverSize)
    end)
    test("collidable or unanchored triggers cannot be expanded", function()
        for _, property in ipairs({ "CanCollide", "Anchored" }) do
            local f = fixture(Player, 30)
            local originalSize = f.trigger.Size
            f.trigger[property] = property == "CanCollide"
            f.experiment(40); f.enable(); tick(30)
            assert(attempts(f) == 0 and f.trigger.Size == originalSize and #f.calls == 0)
        end
    end)
    test("unexpected observation errors still restore the pulse and release the worker", function()
        local f = fixture(Player, 30)
        local originalSize = f.trigger.Size
        f.experiment(40); f.enable()
        f.root.AssemblyLinearVelocity = nil
        tick()
        assert(f.trigger.Size == originalSize)
        assert(string.find(f.report(), "erro no teste", 1, true))
        f.root.AssemblyLinearVelocity = Vector3.zero
        f.runtime:Set("MusicalChairMode", "Perto (4 studs)")
        f.root.Position = Vector3.new(28, 0, 0)
        f.addChair("NewChair", 29)
        tick(20)
        assert(#f.calls == 2, "failed worker must not retain the lock")
    end)
    print(string.format("Musical chairs: %d regression scenarios passed", passed))
end