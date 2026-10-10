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
            table.insert(callbacks, callback)
            return { Disconnect = function() end }
        end,
        Wait = function() coroutine.yield() end,
        Fire = function(_, ...)
            for _, callback in ipairs(callbacks) do callback(...) end
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
            runtime:Set("MusicalChairMode", "Alcance experimental")
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
    test("experimental keeps normal touch order at distance and respects the configured cap", function()
        for _, distance in ipairs({ 60, 160, 161 }) do
            local f = fixture(Player, distance)
            f.experiment(160)
            f.enable(); tick(30)
            if distance <= 160 then
                assert(#f.calls == 2)
                for _, call in ipairs(f.calls) do
                    assert(call.part == f.root and call.target == f.trigger)
                end
                assert(f.calls[1].state == 0 and f.calls[2].state == 1)
                assert(f.calls[1].time == f.calls[2].time)
            else assert(#f.calls == 0) end
            assert(f.root.Position == Vector3.zero and not f.root.Anchored)
            assert(f.root.AssemblyLinearVelocity == Vector3.zero)
            assert(f.trigger.Position.X == distance and f.seat.SitCalls == nil)
        end
    end)
    test("experimental allows one total attempt until all observed window markers retire", function()
        local f = fixture(Player, 60)
        local _, _, secondTouch = f.addChair("Second", 65)
        f.experiment(160)
        f.enable(); tick(30)
        assert(#f.calls == 2, "must not iterate through the other distant chairs")
        f.runtime:Set("AutoMusicalChairs", false)
        f.runtime:Set("AutoMusicalChairs", true)
        f.runtime:Set("MusicalChairMode", "Perto (4 studs)")
        f.experiment(80)
        tick(30)
        assert(#f.calls == 2)
        f.touch.Parent = nil
        f.trigger.children = {}
        local newTouch = instance("TouchInterest", "TouchTransmitter", f.trigger)
        services.Workspace.DescendantAdded:Fire(newTouch)
        tick(30)
        assert(#f.calls == 2, "one old window marker remains")
        secondTouch.Parent = nil
        tick(30)
        assert(#f.calls == 4, "a new observed window allows another attempt")
    end)
    test("adjustable reach defaults to 8 and leaves near mode at 4", function()
        local f = fixture(Player, 8)
        f.enable(); tick(5)
        assert(#f.calls == 0)
        f.experiment()
        tick()
        assert(#f.calls == 2)
        assert(string.find(f.report(), "alcance=8 studs", 1, true))

        f = fixture(Player, 12)
        f.experiment(8)
        f.enable(); tick(5)
        assert(#f.calls == 0)
        f.runtime:Set("MusicalChairReach", 12)
        tick()
        assert(#f.calls == 2)
        assert(string.find(f.report(), "alcance=12 studs", 1, true))
        f.addChair("Second", 20)
        f.runtime:Set("MusicalChairReach", 20)
        tick(30)
        assert(#f.calls == 2, "slider changes must not rearm an attempted window")

        f = fixture(Player, 5)
        f.runtime:Set("MusicalChairReach", 160)
        f.enable(); tick(5)
        assert(#f.calls == 0, "near mode ignores experimental slider")
    end)
    test("reach values are bounded and invalid input uses the default", function()
        local f = fixture(Player, 9)
        f.experiment(0/0)
        f.enable(); tick(5)
        assert(#f.calls == 0)
        assert(string.find(f.report(), "efetivo: 8 studs", 1, true))
        f.runtime:Set("MusicalChairReach", 9999)
        assert(string.find(f.report(), "efetivo: 160 studs", 1, true))
        f.runtime:Set("MusicalChairReach", -99)
        assert(string.find(f.report(), "efetivo: 4 studs", 1, true))
        f.runtime:Set("MusicalChairReach", "invalid")
        assert(string.find(f.report(), "efetivo: 8 studs", 1, true))
        f.runtime:Set("MusicalChairReach", 12.9)
        assert(string.find(f.report(), "efetivo: 12 studs", 1, true))
    end)
    test("experimental records stable local seating only after continuous confirmation", function()
        local f = fixture(Player, 60)
        f.experiment(160)
        f.enable()
        f.humanoid.SeatPart, f.seat.Occupant = f.seat, f.humanoid
        local weld = instance("SeatWeld", "Weld", f.seat)
        weld.Enabled, weld.Part0, weld.Part1 = true, f.seat, f.root
        tick(3)
        assert(not string.find(f.report(), "vinculo local estavel", 1, true))
        f.humanoid.SeatPart, f.seat.Occupant = nil, nil
        tick()
        f.humanoid.SeatPart, f.seat.Occupant = f.seat, f.humanoid
        tick(3)
        assert(not string.find(f.report(), "vinculo local estavel", 1, true), "confirmation timer must reset")
        tick(5)
        local report = f.report()
        assert(string.find(report, "vinculo local estavel por 0.5s", 1, true))
        assert(string.find(report, "nao comprova aprovacao do servidor", 1, true))
    end)
    test("experimental diagnostic captures transient motion from the executor", function()
        local f = fixture(Player, 60)
        f.experiment(160)
        local original = executor.firetouchinterest
        executor.firetouchinterest = function(part, target, state)
            original(part, target, state)
            f.root.Position = state == 0 and Vector3.new(15, 0, 0) or Vector3.zero
            f.root.AssemblyLinearVelocity = state == 0 and Vector3.new(50, 0, 0) or Vector3.zero
        end
        f.enable(); tick(30)
        local report = f.report()
        assert(string.find(report, "distancia=60.0", 1, true))
        assert(string.find(report, "deslocamentoMax=15.0", 1, true))
        assert(string.find(report, "velocidadeMax=50.0", 1, true))
        assert(string.find(report, "sem confirmacao local", 1, true))
        assert(#f.calls == 2)
    end)
    test("changing mode cancels experimental observation without a new distant request", function()
        local f = fixture(Player, 60)
        f.experiment(160)
        f.enable()
        f.runtime:Set("MusicalChairMode", "Perto (4 studs)")
        tick(30)
        assert(#f.calls == 2)
        assert(string.find(f.report(), "observacao cancelada", 1, true))
    end)
    test("experimental still ends the pair on executor errors and records the failure", function()
        local f = fixture(Player, 60)
        f.addChair("Second", 65)
        f.experiment(160)
        local original = executor.firetouchinterest
        executor.firetouchinterest = function(part, target, state)
            original(part, target, state)
            error("test executor error")
        end
        f.enable(); tick(40)
        assert(#f.calls == 2 and f.calls[2].state == 1)
        assert(string.find(f.report(), "Erro do executor:", 1, true))
    end)
    print(string.format("Musical chairs: %d regression scenarios passed", passed))
end
