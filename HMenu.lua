local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local HMenu = {}

local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function round(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, transparency)
    return make("UIStroke", { Color = color, Thickness = 1, Transparency = transparency or 0 }, parent)
end

local function pad(parent, left, right, top, bottom)
    return make("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0), PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0), PaddingBottom = UDim.new(0, bottom or top or 0),
    }, parent)
end

local function text(parent, value, properties)
    properties = properties or {}
    properties.BackgroundTransparency = properties.BackgroundTransparency == nil and 1 or properties.BackgroundTransparency
    properties.Text = value
    properties.BorderSizePixel = 0
    local object = make("TextLabel", properties, parent)
    return object
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

function HMenu:Create(options)
    assert(options and type(options.Import) == "function", "HMenu requires an Import function")
    local Schema = options.Import("HMenuSchema.lua")
    local Config = options.Import("HMenuConfig.lua")
    Schema.ValidateConfig(Config)
    local Theme = {}
    for key, value in pairs(Config.Theme) do Theme[key] = value end
    local Parent = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    local function icon(parent, iconName, properties)
        properties = properties or {}
        properties.BackgroundTransparency = 1
        properties.BorderSizePixel = 0
        properties.Image = Config.Icons[iconName] or iconName or ""
        properties.ImageColor3 = properties.ImageColor3 or Theme.Muted
        return make("ImageLabel", properties, parent)
    end
    local categories = {}
    local categoryIds = {}
    local controlIds = {}
    local runtimeModules = {}
    for _, path in ipairs(Config.CategoryModules) do
        Schema.RequireModulePath(path, "Config.CategoryModules[]")
        local ok, category = pcall(options.Import, path)
        if not ok then
            error("Falha ao importar categoria " .. tostring(path) .. ": " .. tostring(category), 0)
        end
        Schema.ValidateCategory(category, path, categoryIds, controlIds)
        table.insert(categories, category)
    end
    if not categoryIds[Config.DefaultCategory] then
        error("Config.DefaultCategory aponta para uma categoria inexistente: "
            .. tostring(Config.DefaultCategory), 0)
    end

    for _, category in ipairs(categories) do
        local path = category.RuntimeModule
        if path and not runtimeModules[path] then
            local ok, runtimeModule = pcall(options.Import, path)
            if not ok then
                error("Falha ao importar runtime " .. path .. ": " .. tostring(runtimeModule), 0)
            end
            if type(runtimeModule) ~= "table" or type(runtimeModule.Create) ~= "function" then
                error(path .. " deve retornar uma tabela com função Create", 0)
            end
            runtimeModules[path] = runtimeModule
        end
    end

    if type(_G.__HMENU_CLEANUP) == "function" then pcall(_G.__HMENU_CLEANUP) end
    local connections = {}
    local pageConnections = {}
    local popupConnections = {}
    local runtimes = {}
    local activeDropdownPopup
    local wallpaperRequest = 0
    local themeSetter
    local cameraViewportConnection
    local destroyed = false
    local cleanupFunction

    local function connectTracked(bucket, signal, callback)
        local connection = signal:Connect(callback)
        table.insert(bucket, connection)
        return connection
    end

    local function connect(signal, callback)
        return connectTracked(connections, signal, callback)
    end

    local function connectPage(signal, callback)
        return connectTracked(pageConnections, signal, callback)
    end

    local function connectPopup(signal, callback)
        return connectTracked(popupConnections, signal, callback)
    end

    local function disconnectAll(bucket)
        for index = #bucket, 1, -1 do
            pcall(function() bucket[index]:Disconnect() end)
            table.remove(bucket, index)
        end
    end

    local previous = Parent:FindFirstChild(Config.GuiName)
    if previous then previous:Destroy() end
    local gui = make("ScreenGui", {
        Name = Config.GuiName, ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 998,
    }, Parent)
    if type(protect_gui) == "function" then pcall(protect_gui, gui) end

    cleanupFunction = function()
        if destroyed then return end
        destroyed = true
        wallpaperRequest = wallpaperRequest + 1
        disconnectAll(popupConnections)
        disconnectAll(pageConnections)
        disconnectAll(connections)
        if cameraViewportConnection then
            pcall(function() cameraViewportConnection:Disconnect() end)
            cameraViewportConnection = nil
        end
        if activeDropdownPopup then
            activeDropdownPopup:Destroy()
            activeDropdownPopup = nil
        end
        for index = #runtimes, 1, -1 do
            local runtime = runtimes[index]
            if type(runtime.Destroy) == "function" then
                pcall(function() runtime:Destroy() end)
            end
            table.remove(runtimes, index)
        end
        if gui and gui.Parent then gui:Destroy() end
        if _G.__HMENU_SET_THEME == themeSetter then _G.__HMENU_SET_THEME = nil end
        if _G.__HMENU_CLEANUP == cleanupFunction then _G.__HMENU_CLEANUP = nil end
    end
    _G.__HMENU_CLEANUP = cleanupFunction

    for _, category in ipairs(categories) do
        if category.RuntimeModule then
            local runtimeModule = runtimeModules[category.RuntimeModule]
            local runtimeOk, runtime = pcall(function()
                return runtimeModule:Create({ Parent = Parent })
            end)
            if not runtimeOk or type(runtime) ~= "table" or type(runtime.Set) ~= "function"
                or type(runtime.Destroy) ~= "function" then
                cleanupFunction()
                error("Falha ao iniciar runtime " .. category.RuntimeModule .. ": "
                    .. tostring(runtime), 0)
            end

            table.insert(runtimes, runtime)
            for _, section in ipairs(category.Sections) do
                for _, control in ipairs(section.Controls) do
                    if control.OptionsSource then
                        if type(runtime.GetOptions) ~= "function" then
                            cleanupFunction()
                            error(category.RuntimeModule .. " precisa implementar GetOptions para "
                                .. control.Id, 0)
                        end
                        local optionsSource = control.OptionsSource
                        control.Options = function()
                            return runtime:GetOptions(optionsSource)
                        end
                    end
                    if control.Setting then
                        local settingName = control.Setting
                        local settingRuntime = runtime
                        local previousCallback = control.Callback
                        control.Callback = function(value, state)
                            settingRuntime:Set(settingName, value)
                            if type(previousCallback) == "function" then
                                previousCallback(value, state)
                            end
                        end
                    end
                end
            end
        end
    end

    local root = make("Frame", {
        Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Config.Window.Width, Config.Window.Height),
        BackgroundColor3 = Theme.Window, BackgroundTransparency = 0.13,
        BorderSizePixel = 0, ClipsDescendants = true,
    }, gui)
    round(root, 12)
    stroke(root, Theme.Border, 0.3)
    local rootGradient = make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.WindowHighlight),
            ColorSequenceKeypoint.new(1, Theme.WindowDark),
        }), Rotation = 135,
    }, root)
    local wallpaper = make("ImageLabel", {
        Name = "ThemeWallpaper",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "",
        ImageColor3 = Color3.fromRGB(225, 225, 235),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
        Visible = false,
    }, root)
    local wallpaperShade = make("Frame", {
        Name = "ThemeWallpaperShade",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.WindowDark,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
    }, root)
    local scale = make("UIScale", { Scale = 1 }, root)
    local accentLine = make("Frame", {
        Name = "AccentLine", Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0, ZIndex = 8,
    }, root)
    make("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.22, 0.15),
            NumberSequenceKeypoint.new(0.78, 0.15), NumberSequenceKeypoint.new(1, 1),
        }),
    }, accentLine)

    local header = make("Frame", {
        Name = "Header", Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = Theme.Header,
        BackgroundTransparency = 0.22, BorderSizePixel = 0, Active = true, ZIndex = 2,
    }, root)
    text(header, "HMenu " .. Config.Version, {
        Size = UDim2.fromOffset(230, 54), Position = UDim2.fromOffset(20, 0),
        TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    icon(header, "laptop", {
        Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -193, 0.5, -7),
        ImageColor3 = Theme.Dim,
    })
    text(header, "Desktop PC", {
        Size = UDim2.fromOffset(95, 54), Position = UDim2.new(1, -175, 0, 0),
        TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local minimize = make("TextButton", {
        Name = "Minimize", Size = UDim2.fromOffset(36, 54), Position = UDim2.new(1, -80, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, Text = "-", TextColor3 = Theme.Muted,
        Font = Enum.Font.Gotham, TextSize = 15, AutoButtonColor = false,
    }, header)
    local close = make("TextButton", {
        Name = "Close", Size = UDim2.fromOffset(38, 54), Position = UDim2.new(1, -42, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, Text = "X", TextColor3 = Theme.Muted,
        Font = Enum.Font.Gotham, TextSize = 14, AutoButtonColor = false,
    }, header)
    make("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border, BackgroundTransparency = 0.7, BorderSizePixel = 0,
    }, header)

    local sidebar = make("Frame", {
        Name = "Sidebar", Size = UDim2.new(0, 178, 1, -54), Position = UDim2.fromOffset(0, 54),
        BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.24, BorderSizePixel = 0, ZIndex = 2,
    }, root)
    make("Frame", {
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border, BackgroundTransparency = 0.73, BorderSizePixel = 0,
    }, sidebar)

    local search = make("TextBox", {
        Name = "Search", Size = UDim2.new(1, -26, 0, 34), Position = UDim2.fromOffset(13, 12),
        BackgroundColor3 = Theme.Control, BackgroundTransparency = 0.25, BorderSizePixel = 0,
        Text = "", PlaceholderText = "Pesquisar...", ClearTextOnFocus = false,
        PlaceholderColor3 = Theme.Dim, TextColor3 = Theme.Text, Font = Enum.Font.Gotham,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    }, sidebar)
    round(search, 7)
    stroke(search, Theme.Border, 0.48)
    pad(search, 32, 11)
    icon(sidebar, "search", {
        Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(23, 22),
        ImageColor3 = Theme.Dim, ZIndex = 3,
    })

    local nav = make("ScrollingFrame", {
        Name = "Navigation", Size = UDim2.new(1, -14, 1, -89), Position = UDim2.fromOffset(7, 58),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    local navLayout = make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, nav)
    pad(nav, 0, 3, 0, 8)
    text(sidebar, "RIGHTSHIFT  |  MOSTRAR / OCULTAR", {
        Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 12, 1, -27),
        TextColor3 = Theme.Dim, Font = Enum.Font.GothamMedium, TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local content = make("Frame", {
        Name = "Content", Size = UDim2.new(1, -178, 1, -54), Position = UDim2.fromOffset(178, 54),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2,
    }, root)
    local titleIcon = icon(content, "home", {
        Size = UDim2.fromOffset(21, 21), Position = UDim2.fromOffset(25, 26),
        ImageColor3 = Theme.Accent,
    })
    local title = text(content, "", {
        Size = UDim2.new(1, -70, 0, 42), Position = UDim2.fromOffset(55, 16),
        TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local titleAccent = make("Frame", {
        Size = UDim2.fromOffset(34, 2), Position = UDim2.fromOffset(56, 57),
        BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
    }, content)
    round(titleAccent, 1)
    local page = make("ScrollingFrame", {
        Name = "Page", Size = UDim2.new(1, -39, 1, -76), Position = UDim2.fromOffset(24, 66),
        BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Border, ScrollingDirection = Enum.ScrollingDirection.Y,
    }, content)
    local pageLayout = make("UIListLayout", {
        Padding = UDim.new(0, 13), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, page)
    pad(page, 0, 8, 0, 14)

    local state = {}
    local activeButton, activeCategory
    local navButtons = {}

    local function closeDropdown()
        disconnectAll(popupConnections)
        if activeDropdownPopup then
            activeDropdownPopup:Destroy()
            activeDropdownPopup = nil
        end
    end

    local function fire(control, value)
        state[control.Id or control.Label] = value
        if type(control.Callback) == "function" then
            local ok, err = pcall(control.Callback, value, state)
            if not ok then warn("[HMenu] Callback error:", err) end
        end
    end

    local function createToggle(parent, control, row)
        local saved = state[control.Id or control.Label]
        local enabled = saved == nil and control.Default == true or saved == true
        local track = make("Frame", {
            Size = UDim2.fromOffset(36, 19), Position = UDim2.new(1, -50, 0.5, -10),
            BackgroundColor3 = enabled and Theme.Accent or Theme.Control, BorderSizePixel = 0,
        }, row)
        round(track, 10)
        stroke(track, enabled and Theme.Accent or Theme.Border, 0.28)
        local knob = make("Frame", {
            Size = UDim2.fromOffset(13, 13), Position = enabled and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.Text, BorderSizePixel = 0,
        }, track)
        round(knob, 7)
        local hit = make("TextButton", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        }, row)
        state[control.Id or control.Label] = enabled
        connectPage(hit.MouseButton1Click, function()
            enabled = not enabled
            TweenService:Create(track, TweenInfo.new(0.14), { BackgroundColor3 = enabled and Theme.Accent or Theme.Control }):Play()
            TweenService:Create(knob, TweenInfo.new(0.14), { Position = enabled and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3) }):Play()
            fire(control, enabled)
        end)
    end

    local function createSlider(parent, control, row)
        local minimum, maximum = control.Min or 0, control.Max or 100
        local saved = state[control.Id or control.Label]
        local value = math.clamp(saved == nil and (control.Default or minimum) or saved, minimum, maximum)
        local valueText = text(row, tostring(value), {
            Size = UDim2.fromOffset(42, 18), Position = UDim2.new(1, -166, 0.5, -9),
            TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        local bar = make("Frame", {
            Size = UDim2.fromOffset(104, 4), Position = UDim2.new(1, -116, 0.5, -2),
            BackgroundColor3 = Theme.Control, BorderSizePixel = 0,
        }, row)
        round(bar, 3)
        local fill = make("Frame", {
            Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1),
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
        }, bar)
        round(fill, 3)
        local knob = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(15, 15), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
        }, fill)
        round(knob, 8)
        local dragging = false
        local function update(x)
            local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            value = math.floor((minimum + (maximum - minimum) * alpha) / (control.Step or 1) + 0.5) * (control.Step or 1)
            value = math.clamp(value, minimum, maximum)
            fill.Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1)
            valueText.Text = tostring(value)
            fire(control, value)
        end
        local hit = make("TextButton", {
            Size = UDim2.new(1, 12, 0, 22), Position = UDim2.fromOffset(-6, -9),
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        }, bar)
        connectPage(hit.InputBegan, function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(inputObject.Position.X)
            end
        end)
        connectPage(UserInputService.InputChanged, function(inputObject)
            if dragging and (inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch) then
                update(inputObject.Position.X)
            end
        end)
        connectPage(UserInputService.InputEnded, function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        state[control.Id or control.Label] = value
    end

    local function createChoice(control, row)
        local function readChoices()
            local choices = control.Options
            if type(choices) == "function" then
                local ok, result = pcall(choices)
                choices = ok and result or nil
            end
            if type(choices) ~= "table" or #choices == 0 then
                return { "None" }
            end
            return choices
        end
        local choices = readChoices()
        local saved = state[control.Id or control.Label]
        local index = table.find(choices, saved == nil and control.Default or saved) or 1
        local button = make("TextButton", {
            Size = UDim2.fromOffset(152, 27), Position = UDim2.new(1, -165, 0.5, -14),
            BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = tostring(choices[index]) .. "  v",
            TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 10, AutoButtonColor = false,
        }, row)
        round(button, 5)
        stroke(button, Theme.Border, 0.55)
        state[control.Id or control.Label] = choices[index]
        connectPage(button.MouseButton1Click, function()
            local current = choices[index]
            choices = readChoices()
            if not control.UseList then
                index = table.find(choices, current) or 0
                index = index % #choices + 1
                button.Text = tostring(choices[index]) .. "  v"
                fire(control, choices[index])
                return
            end
            index = table.find(choices, current) or 1

            if activeDropdownPopup then
                closeDropdown()
                button.Text = tostring(choices[index]) .. "  v"
                return
            end

            button.Text = tostring(choices[index]) .. "  ^"
            local optionCount = math.max(#choices, 1)
            local popup = make("Frame", {
                Name = "DropdownPopup",
                Position = UDim2.fromOffset(button.AbsolutePosition.X, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 4),
                Size = UDim2.fromOffset(button.AbsoluteSize.X, math.min(optionCount * 29 + 8, 182)),
                BackgroundColor3 = Theme.WindowDark,
                BackgroundTransparency = 0.03,
                BorderSizePixel = 0,
                ZIndex = 80,
            }, gui)
            activeDropdownPopup = popup
            round(popup, 7)
            stroke(popup, Theme.Border, 0.2)

            local list = make("ScrollingFrame", {
                Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Border,
                ZIndex = 81,
            }, popup)
            make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)

            for optionIndex, option in ipairs(choices) do
                local optionButton = make("TextButton", {
                    Size = UDim2.new(1, -3, 0, 27), BackgroundColor3 = Theme.Surface,
                    BackgroundTransparency = option == current and 0.25 or 1,
                    BorderSizePixel = 0, Text = tostring(option), TextColor3 = option == current and Theme.Text or Theme.Muted,
                    Font = Enum.Font.Gotham, TextSize = 10, AutoButtonColor = false,
                    ZIndex = 82, LayoutOrder = optionIndex,
                }, list)
                round(optionButton, 5)
                connectPopup(optionButton.MouseButton1Click, function()
                    index = optionIndex
                    button.Text = tostring(option) .. "  v"
                    fire(control, option)
                    closeDropdown()
                end)
                connectPopup(optionButton.MouseEnter, function()
                    optionButton.BackgroundTransparency = 0.35
                    optionButton.TextColor3 = Theme.Text
                end)
                connectPopup(optionButton.MouseLeave, function()
                    optionButton.BackgroundTransparency = optionIndex == index and 0.25 or 1
                    optionButton.TextColor3 = optionIndex == index and Theme.Text or Theme.Muted
                end)
            end
        end)
    end

    local function createAction(control, row)
        local button = make("TextButton", {
            Size = UDim2.fromOffset(102, 27), Position = UDim2.new(1, -115, 0.5, -14),
            BackgroundColor3 = Theme.Control, BorderSizePixel = 0, Text = control.ButtonText or "Executar",
            TextColor3 = Theme.Accent, Font = Enum.Font.GothamMedium, TextSize = 10, AutoButtonColor = false,
        }, row)
        round(button, 5)
        stroke(button, Theme.Border, 0.45)
        connectPage(button.MouseButton1Click, function()
            fire(control, true)
            button.Text = "Concluído"
            task.delay(1, function() if button.Parent then button.Text = control.ButtonText or "Executar" end end)
        end)
    end

    local function createControl(sectionFrame, control)
        local height = control.Kind == "Paragraph" and 56 or 42
        local row = make("Frame", {
            Name = control.Id or control.Label, Size = UDim2.new(1, 0, 0, height),
            BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.17,
            BorderSizePixel = 0, Active = true,
        }, sectionFrame)
        round(row, 5)
        stroke(row, Theme.Border, 0.6)
        local labelWidth = (control.Kind == "Paragraph") and -26 or -185
        text(row, control.Label, {
            Size = UDim2.new(1, labelWidth, 0, control.Description and 18 or height), Position = UDim2.fromOffset(12, control.Description and 6 or 0),
            TextColor3 = Theme.Text, Font = control.Kind == "Paragraph" and Enum.Font.GothamMedium or Enum.Font.Gotham,
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        })
        if control.Description then
            text(row, control.Description, {
                Size = UDim2.new(1, -26, 0, 18), Position = UDim2.fromOffset(12, 27),
                TextColor3 = Theme.Dim, Font = Enum.Font.Gotham, TextSize = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
        end
        if control.Kind == "Toggle" then createToggle(sectionFrame, control, row)
        elseif control.Kind == "Slider" then createSlider(sectionFrame, control, row)
        elseif control.Kind == "Dropdown" then createChoice(control, row)
        elseif control.Kind == "Button" then createAction(control, row)
        end
        connectPage(row.MouseEnter, function()
            TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.08 }):Play()
        end)
        connectPage(row.MouseLeave, function()
            TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.17 }):Play()
        end)
        return row
    end

    local function clearPage()
        closeDropdown()
        disconnectAll(pageConnections)
        for _, child in ipairs(page:GetChildren()) do
            if child ~= pageLayout and not child:IsA("UIPadding") then child:Destroy() end
        end
    end

    local function render(category)
        activeCategory = category
        title.Text = category.Label
        titleIcon.Image = Config.Icons[category.Icon] or category.Icon or ""
        clearPage()
        for sectionIndex, section in ipairs(category.Sections or {}) do
            local sectionFrame = make("Frame", {
                Name = section.Title, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, LayoutOrder = sectionIndex,
            }, page)
            local layout = make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, sectionFrame)
            local sectionHeader = make("Frame", {
                Name = "SectionHeader", Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0,
            }, sectionFrame)
            icon(sectionHeader, section.Icon or category.Icon, {
                Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(1, 4),
                ImageColor3 = Theme.Muted,
            })
            text(sectionHeader, section.Title, {
                Size = UDim2.new(1, -25, 1, 0), Position = UDim2.fromOffset(24, 0), TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            })
            for controlIndex, control in ipairs(section.Controls or {}) do
                local row = createControl(sectionFrame, control)
                row.LayoutOrder = controlIndex
            end
        end
        page.CanvasPosition = Vector2.new(0, 0)
    end

    local function selectCategory(category, button)
        if activeButton then
            activeButton.BackgroundTransparency = 1
            local marker = activeButton:FindFirstChild("ActiveMarker")
            if marker then marker.Visible = false end
            local oldIcon = activeButton:FindFirstChild("CategoryIcon")
            local oldLabel = activeButton:FindFirstChild("CategoryLabel")
            if oldIcon then oldIcon.ImageColor3 = Theme.Muted end
            if oldLabel then oldLabel.TextColor3 = Theme.Muted end
        end
        activeButton, activeCategory = button, category
        button.BackgroundTransparency = 0.72
        button.ActiveMarker.Visible = true
        button.CategoryIcon.ImageColor3 = Theme.Accent
        button.CategoryLabel.TextColor3 = Theme.Text
        render(category)
    end

    local function refreshFavoriteOrder()
        for _, item in pairs(navButtons) do
            item.Button.LayoutOrder = item.Favorite and item.OriginalIndex or (1000 + item.OriginalIndex)
            item.FavoriteButton.ImageColor3 = item.Favorite and Theme.Bookmark or Theme.Dim
            item.FavoriteButton.ImageTransparency = item.Favorite and 0 or 0.12
        end
    end

    for index, category in ipairs(categories) do
        category.Bookmarked = false
        local button = make("TextButton", {
            Name = category.Id, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false, LayoutOrder = index,
        }, nav)
        round(button, 5)
        local marker = make("Frame", {
            Name = "ActiveMarker", Size = UDim2.fromOffset(3, 18), Position = UDim2.new(0, 0, 0.5, -9),
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false,
        }, button)
        round(marker, 2)
        icon(button, category.Icon, {
            Name = "CategoryIcon",
            Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(12, 10),
            ImageColor3 = Theme.Muted, ZIndex = 2,
        })
        text(button, category.Label, {
            Name = "CategoryLabel",
            Size = UDim2.new(1, -68, 1, 0), Position = UDim2.fromOffset(36, 0),
            TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
        })
        local favorite = make("ImageButton", {
            Name = "Favorite", AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -17, 0.5, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, Image = Config.Icons.bookmark,
            ImageColor3 = Theme.Dim,
            AutoButtonColor = false, ZIndex = 5,
        }, button)
        navButtons[category.Id] = {
            Button = button, Category = category, FavoriteButton = favorite,
            Favorite = false, OriginalIndex = index,
        }
        connect(button.MouseButton1Click, function() selectCategory(category, button) end)
        connect(button.MouseEnter, function()
            if activeButton ~= button then TweenService:Create(button, TweenInfo.new(0.12), { BackgroundTransparency = 0.88 }):Play() end
        end)
        connect(button.MouseLeave, function()
            if activeButton ~= button then TweenService:Create(button, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play() end
        end)
        connect(favorite.MouseButton1Click, function()
            local item = navButtons[category.Id]
            item.Favorite = not item.Favorite
            category.Bookmarked = item.Favorite
            refreshFavoriteOrder()
            favorite.Size = UDim2.fromOffset(13, 13)
            TweenService:Create(favorite, TweenInfo.new(0.14, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(16, 16) }):Play()
        end)
        if category.Id == Config.DefaultCategory then selectCategory(category, button) end
    end
    refreshFavoriteOrder()
    if not activeButton then
        local first = navButtons[categories[1].Id]
        selectCategory(first.Category, first.Button)
    end

    connect(search:GetPropertyChangedSignal("Text"), function()
        local query = lower(search.Text):gsub("^%s+", ""):gsub("%s+$", "")
        for _, item in pairs(navButtons) do
            item.Button.Visible = query == "" or string.find(lower(item.Category.Label), query, 1, true) ~= nil
        end
    end)

    local hidden = false
    local function setVisible(visible)
        if destroyed or not root.Parent then return end
        if not visible then closeDropdown() end
        hidden = not visible
        root.Visible = visible
    end
    connect(minimize.MouseButton1Click, function() setVisible(false) end)
    connect(close.MouseButton1Click, function() setVisible(false) end)
    connect(UserInputService.InputBegan, function(inputObject, processed)
        if not processed and inputObject.KeyCode == Config.ToggleKey then setVisible(hidden) end
    end)

    local dragging, dragStart, startPosition = false, nil, nil
    connect(header.InputBegan, function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
            closeDropdown()
            dragging, dragStart, startPosition = true, inputObject.Position, root.Position
        end
    end)
    connect(UserInputService.InputChanged, function(inputObject)
        if dragging and (inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch) then
            local delta = inputObject.Position - dragStart
            root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
    connect(UserInputService.InputEnded, function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local function updateScale()
        local camera = Workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local fit = math.min((viewport.X - Config.Window.Margin) / Config.Window.Width, (viewport.Y - Config.Window.Margin) / Config.Window.Height, 1)
        scale.Scale = math.max(fit, Config.Window.MinScale)
    end
    local function bindCamera()
        if cameraViewportConnection then
            pcall(function() cameraViewportConnection:Disconnect() end)
            cameraViewportConnection = nil
        end
        if Workspace.CurrentCamera then
            cameraViewportConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        end
        updateScale()
    end
    connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), bindCamera)
    bindCamera()

    local currentThemeName = "Default"
    local wallpaperAssets = {}
    local themeKeys = {
        "Window", "WindowHighlight", "WindowDark", "Sidebar", "Header",
        "Surface", "SurfaceHover", "Control", "Accent", "Bookmark",
        "Text", "Muted", "Dim", "Border", "Success", "Danger",
    }
    local colorProperties = {
        "BackgroundColor3", "TextColor3", "PlaceholderColor3",
        "ImageColor3", "ScrollBarImageColor3", "Color",
    }

    local function copyColors(source)
        local result = {}
        for _, key in ipairs(themeKeys) do result[key] = source[key] end
        return result
    end

    local function colorThemeKey(color, palette)
        if typeof(color) ~= "Color3" then return nil end
        for _, key in ipairs(themeKeys) do
            if palette[key] == color then return key end
        end
        return nil
    end

    local function recolorMenu(oldColors, newColors)
        local objects = { root }
        for _, object in ipairs(root:GetDescendants()) do table.insert(objects, object) end
        for _, object in ipairs(objects) do
            for _, property in ipairs(colorProperties) do
                local ok, current = pcall(function() return object[property] end)
                if ok then
                    local key = colorThemeKey(current, oldColors)
                    if key and newColors[key] then
                        pcall(function() object[property] = newColors[key] end)
                    end
                end
            end
        end
    end

    local function assetBaseUrls()
        if type(options.AssetBaseUrls) == "table" and #options.AssetBaseUrls > 0 then
            return options.AssetBaseUrls
        end
        if type(options.BaseUrl) == "string" and options.BaseUrl ~= "" then
            return { options.BaseUrl }
        end
        return {}
    end

    local function downloadWallpaper(path)
        local lastError = "nenhuma fonte de assets foi configurada"
        local version = tostring(options.AssetVersion or Config.Version or "stable")
        for attempt = 1, 3 do
            for _, configuredBaseUrl in ipairs(assetBaseUrls()) do
                local baseUrl = configuredBaseUrl
                if string.sub(baseUrl, -1) ~= "/" then baseUrl = baseUrl .. "/" end
                local ok, data = pcall(function()
                    return game:HttpGet(baseUrl .. path .. "?v=" .. version, true)
                end)
                if ok and type(data) == "string" and string.sub(data, 1, 8) == "\137PNG\r\n\26\n" then
                    return data
                end
                if ok then
                    lastError = "a resposta não é uma imagem PNG válida"
                else
                    lastError = tostring(data)
                end
            end
            if attempt < 3 then task.wait(0.75 * (2 ^ (attempt - 1))) end
        end
        return nil, lastError
    end

    local function wallpaperAsset(themeName, definition)
        if wallpaperAssets[themeName] then return wallpaperAssets[themeName] end
        local assetLoader = type(getcustomasset) == "function" and getcustomasset
            or (type(getsynasset) == "function" and getsynasset or nil)
        if not assetLoader or type(writefile) ~= "function" then return nil end

        local ok, asset = pcall(function()
            local directory = "HMenuThemes"
            local version = tostring(options.AssetVersion or Config.Version or "stable")
                :gsub("[^%w%-_%.]", "_")
            local localPath = "HMenuTheme-" .. themeName .. "-" .. version .. ".png"
            if type(makefolder) == "function" then
                pcall(function() makefolder(directory) end)
                localPath = directory .. "/" .. themeName .. "-" .. version .. ".png"
            end
            if type(isfile) == "function" and isfile(localPath) then
                local cachedOk, cachedAsset = pcall(assetLoader, localPath)
                if cachedOk and cachedAsset then return cachedAsset end
            end
            local data, downloadError = downloadWallpaper(definition.Wallpaper)
            if not data then error(downloadError, 0) end
            writefile(localPath, data)
            return assetLoader(localPath)
        end)
        if not ok or not asset then
            warn("[HMenu] Wallpaper could not be loaded:", themeName, asset)
            return nil
        end
        wallpaperAssets[themeName] = asset
        return asset
    end

    local function updateWallpaper(themeName, definition)
        wallpaperRequest = wallpaperRequest + 1
        local request = wallpaperRequest
        wallpaper.Visible = false
        wallpaperShade.Visible = false
        if not definition.Wallpaper then
            wallpaper.Image = ""
            wallpaper.ImageTransparency = 1
            wallpaperShade.BackgroundTransparency = 1
            return
        end

        task.spawn(function()
            local asset = wallpaperAsset(themeName, definition)
            if request ~= wallpaperRequest or currentThemeName ~= themeName or not asset then return end
            wallpaper.Image = asset
            wallpaper.ImageTransparency = 1
            wallpaperShade.BackgroundTransparency = 1
            wallpaper.Visible = true
            wallpaperShade.Visible = true
            TweenService:Create(wallpaper, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
                ImageTransparency = definition.WallpaperTransparency or 0.42,
            }):Play()
            TweenService:Create(wallpaperShade, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
                BackgroundTransparency = definition.ShadeTransparency or 0.5,
            }):Play()
        end)
    end

    local function applyTheme(themeName)
        local definition = Config.Themes and Config.Themes[themeName]
        if not definition or not definition.Colors or themeName == currentThemeName then return end
        closeDropdown()

        local oldColors = copyColors(Theme)
        local newColors = definition.Colors
        recolorMenu(oldColors, newColors)
        for _, key in ipairs(themeKeys) do
            if newColors[key] then Theme[key] = newColors[key] end
        end
        currentThemeName = themeName
        rootGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.WindowHighlight),
            ColorSequenceKeypoint.new(1, Theme.WindowDark),
        })
        wallpaperShade.BackgroundColor3 = Theme.WindowDark
        updateWallpaper(themeName, definition)

        if activeCategory then render(activeCategory) end
        refreshFavoriteOrder()
    end

    themeSetter = function(themeName)
        applyTheme(tostring(themeName or "Default"))
    end
    _G.__HMENU_SET_THEME = themeSetter

    print("[HMenu] Aberto. Use RightShift para ocultar ou mostrar.")
    return { Gui = gui, State = state, Destroy = cleanupFunction, SetVisible = setVisible }
end

return HMenu
