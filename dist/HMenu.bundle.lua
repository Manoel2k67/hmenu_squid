-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Run tools/Build-Bundle.ps1 after changing a source module.
-- Release is read from VERSION at runtime.

local __modules = {}

-- BEGIN HMenuConfig.lua
__modules["HMenuConfig.lua"] = function()
local Config = {}

Config.GuiName = "HMenu"
Config.Version = "v1.2.5"
Config.ToggleKey = Enum.KeyCode.RightShift
Config.DefaultCategory = "Main"
Config.Window = { Width = 720, Height = 520, MinScale = 0.68, Margin = 24 }

Config.Theme = {
    Window = Color3.fromRGB(31, 48, 80),
    WindowHighlight = Color3.fromRGB(38, 58, 96),
    WindowDark = Color3.fromRGB(18, 29, 51),
    Sidebar = Color3.fromRGB(27, 42, 70),
    Header = Color3.fromRGB(29, 45, 76),
    Surface = Color3.fromRGB(32, 49, 82),
    SurfaceHover = Color3.fromRGB(41, 61, 99),
    Control = Color3.fromRGB(25, 40, 68),
    Accent = Color3.fromRGB(102, 151, 246),
    Bookmark = Color3.fromRGB(255, 218, 0),
    Text = Color3.fromRGB(238, 243, 255),
    Muted = Color3.fromRGB(169, 183, 211),
    Dim = Color3.fromRGB(112, 130, 165),
    Border = Color3.fromRGB(83, 112, 169),
    Success = Color3.fromRGB(96, 218, 151),
    Danger = Color3.fromRGB(255, 112, 124),
}

Config.Themes = {
    Default = {
        Colors = Config.Theme,
    },
    Purple = {
        Wallpaper = "theme/wallpapers/Purple.png",
        WallpaperTransparency = 0.42,
        ShadeTransparency = 0.5,
        Colors = {
            Window = Color3.fromRGB(37, 24, 61),
            WindowHighlight = Color3.fromRGB(69, 43, 108),
            WindowDark = Color3.fromRGB(18, 11, 33),
            Sidebar = Color3.fromRGB(29, 19, 49),
            Header = Color3.fromRGB(34, 21, 56),
            Surface = Color3.fromRGB(45, 29, 73),
            SurfaceHover = Color3.fromRGB(61, 40, 96),
            Control = Color3.fromRGB(32, 21, 54),
            Accent = Color3.fromRGB(177, 105, 255),
            Bookmark = Color3.fromRGB(255, 220, 78),
            Text = Color3.fromRGB(247, 242, 255),
            Muted = Color3.fromRGB(198, 181, 224),
            Dim = Color3.fromRGB(143, 120, 176),
            Border = Color3.fromRGB(111, 77, 151),
            Success = Color3.fromRGB(105, 224, 158),
            Danger = Color3.fromRGB(255, 119, 144),
        },
    },
    Orange = {
        Wallpaper = "theme/wallpapers/Orange.png",
        WallpaperTransparency = 0.42,
        ShadeTransparency = 0.5,
        Colors = {
            Window = Color3.fromRGB(58, 31, 18),
            WindowHighlight = Color3.fromRGB(108, 55, 24),
            WindowDark = Color3.fromRGB(31, 15, 8),
            Sidebar = Color3.fromRGB(48, 25, 14),
            Header = Color3.fromRGB(55, 28, 16),
            Surface = Color3.fromRGB(68, 35, 20),
            SurfaceHover = Color3.fromRGB(91, 48, 26),
            Control = Color3.fromRGB(49, 25, 14),
            Accent = Color3.fromRGB(255, 145, 58),
            Bookmark = Color3.fromRGB(255, 220, 78),
            Text = Color3.fromRGB(255, 246, 237),
            Muted = Color3.fromRGB(222, 190, 163),
            Dim = Color3.fromRGB(171, 128, 94),
            Border = Color3.fromRGB(158, 88, 44),
            Success = Color3.fromRGB(112, 222, 151),
            Danger = Color3.fromRGB(255, 116, 104),
        },
    },
}

-- Lucide line icons published as Roblox image assets.
Config.Icons = {
    home = "rbxassetid://7733960981",
    eye = "rbxassetid://7733774602",
    target = "rbxassetid://7743872758",
    player = "rbxassetid://7743871002",
    farm = "rbxassetid://8997382987",
    shield = "rbxassetid://7734056411",
    smile = "rbxassetid://7734059095",
    navigation = "rbxassetid://7734020989",
    settings = "rbxassetid://7734053495",
    atmosphere = "rbxassetid://7733746880",
    info = "rbxassetid://7733964719",
    overview = "rbxassetid://7733970318",
    sliders = "rbxassetid://7734058803",
    camera = "rbxassetid://7733708692",
    palette = "rbxassetid://7734021595",
    refresh = "rbxassetid://7734051052",
    users = "rbxassetid://7743876054",
    music = "rbxassetid://7734020554",
    map = "rbxassetid://7733992424",
    cloud = "rbxassetid://7733920519",
    bookmark = "rbxassetid://7733692043",
    search = "rbxassetid://7734052925",
    laptop = "rbxassetid://7733965386",
    fire = "rbxassetid://7733965386",
    sparkles = "rbxassetid://7734052925",
}

Config.CategoryModules = {
    "categories/Main.lua", "categories/Visuals.lua", "categories/Combat.lua",
    "categories/Player.lua", "categories/Farm.lua", "categories/Whitelist.lua",
    "categories/Emotes.lua", "categories/Teleport.lua", "categories/Misc.lua",
    "categories/Troll.lua", "categories/Atmosphere.lua", "categories/Credits.lua",
}

return Config
end
-- END HMenuConfig.lua

-- BEGIN HMenuSchema.lua
__modules["HMenuSchema.lua"] = function()
local Schema = {}

local VALID_CONTROL_KINDS = {
    Toggle = true,
    Slider = true,
    Dropdown = true,
    Button = true,
    Paragraph = true,
}

local REQUIRED_THEME_KEYS = {
    "Window", "WindowHighlight", "WindowDark", "Sidebar", "Header",
    "Surface", "SurfaceHover", "Control", "Accent", "Bookmark",
    "Text", "Muted", "Dim", "Border", "Success", "Danger",
}

local function requireNonEmptyString(value, context)
    if type(value) ~= "string" or value:match("^%s*$") then
        error(context .. " deve ser uma string não vazia", 0)
    end
end

function Schema.ValidateConfig(config)
    if type(config) ~= "table" then error("HMenuConfig.lua deve retornar uma tabela", 0) end
    requireNonEmptyString(config.GuiName, "Config.GuiName")
    requireNonEmptyString(config.Version, "Config.Version")
    requireNonEmptyString(config.DefaultCategory, "Config.DefaultCategory")
    if config.ToggleKey == nil then error("Config.ToggleKey não pode ser nil", 0) end
    if type(config.Theme) ~= "table" then error("Config.Theme deve ser uma tabela", 0) end
    for _, key in ipairs(REQUIRED_THEME_KEYS) do
        if config.Theme[key] == nil then
            error("Config.Theme não possui a cor obrigatória " .. key, 0)
        end
    end
    if type(config.Icons) ~= "table" then error("Config.Icons deve ser uma tabela", 0) end
    if type(config.Window) ~= "table" or type(config.Window.Width) ~= "number"
        or type(config.Window.Height) ~= "number" then
        error("Config.Window deve informar Width e Height numéricos", 0)
    end
    if config.Window.Width <= 0 or config.Window.Height <= 0
        or type(config.Window.MinScale) ~= "number" or config.Window.MinScale <= 0
        or type(config.Window.Margin) ~= "number" or config.Window.Margin < 0 then
        error("Config.Window possui dimensões, MinScale ou Margin inválidos", 0)
    end
    if type(config.CategoryModules) ~= "table" or #config.CategoryModules == 0 then
        error("Config.CategoryModules não pode estar vazio", 0)
    end
end

function Schema.ValidateCategory(category, path, categoryIds, controlIds)
    if type(category) ~= "table" then
        error(path .. " deve retornar uma tabela", 0)
    end
    requireNonEmptyString(category.Id, path .. ".Id")
    requireNonEmptyString(category.Label, path .. ".Label")
    requireNonEmptyString(category.Icon, path .. ".Icon")
    if categoryIds[category.Id] then
        error("Id de categoria duplicado '" .. category.Id .. "' em " .. path, 0)
    end
    categoryIds[category.Id] = path

    if category.RuntimeModule ~= nil then
        requireNonEmptyString(category.RuntimeModule, path .. ".RuntimeModule")
    end
    if type(category.Sections) ~= "table" then
        error(path .. ".Sections deve ser uma tabela", 0)
    end

    for sectionIndex, section in ipairs(category.Sections) do
        local sectionContext = path .. ".Sections[" .. tostring(sectionIndex) .. "]"
        if type(section) ~= "table" then error(sectionContext .. " deve ser uma tabela", 0) end
        requireNonEmptyString(section.Title, sectionContext .. ".Title")
        if section.Icon ~= nil then requireNonEmptyString(section.Icon, sectionContext .. ".Icon") end
        if type(section.Controls) ~= "table" then
            error(sectionContext .. ".Controls deve ser uma tabela", 0)
        end

        for controlIndex, control in ipairs(section.Controls) do
            local context = sectionContext .. ".Controls[" .. tostring(controlIndex) .. "]"
            if type(control) ~= "table" then error(context .. " deve ser uma tabela", 0) end
            if not VALID_CONTROL_KINDS[control.Kind] then
                error(context .. " possui Kind inválido: " .. tostring(control.Kind), 0)
            end
            requireNonEmptyString(control.Label, context .. ".Label")
            if control.Description ~= nil and type(control.Description) ~= "string" then
                error(context .. ".Description deve ser uma string", 0)
            end
            if control.Callback ~= nil and type(control.Callback) ~= "function" then
                error(context .. ".Callback deve ser uma função", 0)
            end

            if control.Kind ~= "Paragraph" then
                requireNonEmptyString(control.Id, context .. ".Id")
                if controlIds[control.Id] then
                    error("Id de controle duplicado '" .. control.Id .. "' em " .. context, 0)
                end
                controlIds[control.Id] = context
            end
            if control.Setting ~= nil then
                requireNonEmptyString(control.Setting, context .. ".Setting")
                if not category.RuntimeModule then
                    error(context .. " possui Setting, mas a categoria não possui RuntimeModule", 0)
                end
            end
            if control.OptionsSource ~= nil then
                requireNonEmptyString(control.OptionsSource, context .. ".OptionsSource")
                if not category.RuntimeModule then
                    error(context .. " possui OptionsSource, mas a categoria não possui RuntimeModule", 0)
                end
            end

            if control.Kind == "Slider" then
                if type(control.Min) ~= "number" or type(control.Max) ~= "number" or control.Max <= control.Min then
                    error(context .. " precisa de Min e Max numéricos, com Max maior que Min", 0)
                end
                if control.Step ~= nil and (type(control.Step) ~= "number" or control.Step <= 0) then
                    error(context .. ".Step deve ser um número positivo", 0)
                end
                if control.Default ~= nil and (type(control.Default) ~= "number"
                    or control.Default < control.Min or control.Default > control.Max) then
                    error(context .. ".Default deve estar entre Min e Max", 0)
                end
            elseif control.Kind == "Dropdown" then
                local optionsType = type(control.Options)
                if optionsType ~= "table" and optionsType ~= "function"
                    and type(control.OptionsSource) ~= "string" then
                    error(context .. " precisa de Options ou OptionsSource", 0)
                end
                if optionsType == "table" and #control.Options == 0 then
                    error(context .. ".Options não pode estar vazio", 0)
                end
                if optionsType == "table" and control.Default ~= nil then
                    local defaultExists = false
                    for _, option in ipairs(control.Options) do
                        if option == control.Default then defaultExists = true break end
                    end
                    if not defaultExists then
                        error(context .. ".Default não existe em Options", 0)
                    end
                end
            elseif control.Kind == "Toggle" and control.Default ~= nil
                and type(control.Default) ~= "boolean" then
                error(context .. ".Default deve ser booleano", 0)
            elseif control.Kind == "Button" and control.ButtonText ~= nil
                and type(control.ButtonText) ~= "string" then
                error(context .. ".ButtonText deve ser uma string", 0)
            end
        end
    end
end

function Schema.RequireModulePath(path, context)
    requireNonEmptyString(path, context or "caminho do módulo")
end

return Schema
end
-- END HMenuSchema.lua

-- BEGIN HMenu.lua
__modules["HMenu.lua"] = function()
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
end
-- END HMenu.lua

-- BEGIN categories/Atmosphere.lua
__modules["categories/Atmosphere.lua"] = function()
return {
    Id = "Atmosphere",
    Label = "Atmosphere",
    Icon = "atmosphere",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Atmosphere.lua

-- BEGIN categories/Combat.lua
__modules["categories/Combat.lua"] = function()
return {
    Id = "Combat",
    Label = "Combat",
    Icon = "target",
    Bookmarked = false,
    RuntimeModule = "runtime/Combat.lua",
    Sections = {
        {
            Title = "Hitbox",
            Icon = "target",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "HitboxEnabled",
                    Id = "combat_hitbox_enabled",
                    Label = "Hitbox Expander",
                    Description = "Amplia localmente a hitbox dos outros jogadores sem alterar sua posição.",
                    Default = false,
                },
                {
                    Kind = "Slider",
                    Setting = "HitboxRange",
                    Id = "combat_hitbox_range",
                    Label = "Alcance da hitbox",
                    Description = "Raio em studs. A caixa usa o dobro deste valor em cada eixo.",
                    Min = 5,
                    Max = 500,
                    Default = 15,
                    Step = 1,
                },
                {
                    Kind = "Toggle",
                    Setting = "HitboxVisible",
                    Id = "combat_hitbox_visible",
                    Label = "Mostrar área da hitbox",
                    Description = "Exibe a caixa com a mesma cor de time usada pelo ESP.",
                    Default = true,
                },
                {
                    Kind = "Slider",
                    Setting = "HitboxTransparency",
                    Id = "combat_hitbox_transparency",
                    Label = "Transparência da hitbox",
                    Min = 20,
                    Max = 95,
                    Default = 78,
                    Step = 1,
                },
            },
        },
    },
}
end
-- END categories/Combat.lua

-- BEGIN categories/Credits.lua
__modules["categories/Credits.lua"] = function()
return {
    Id = "Credits",
    Label = "Credits",
    Icon = "info",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Credits.lua

-- BEGIN categories/Emotes.lua
__modules["categories/Emotes.lua"] = function()
return {
    Id = "Emotes",
    Label = "Emotes",
    Icon = "smile",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Emotes.lua

-- BEGIN categories/Farm.lua
__modules["categories/Farm.lua"] = function()
return {
    Id = "Farm",
    Label = "Farm",
    Icon = "farm",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Farm.lua

-- BEGIN categories/Main.lua
__modules["categories/Main.lua"] = function()
return {
    Id = "Main",
    Label = "Main",
    Icon = "home",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Main.lua

-- BEGIN categories/Misc.lua
__modules["categories/Misc.lua"] = function()
return {
    Id = "Misc",
    Label = "Misc",
    Icon = "settings",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Misc.lua

-- BEGIN categories/Player.lua
__modules["categories/Player.lua"] = function()
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local character = localPlayer and localPlayer.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local defaultWalkSpeed = humanoid and tonumber(humanoid.WalkSpeed) or 16
defaultWalkSpeed = math.clamp(defaultWalkSpeed, 8, 200)

return {
    Id = "Player",
    Label = "Player",
    Icon = "player",
    Bookmarked = false,
    RuntimeModule = "runtime/Player.lua",
    Sections = {
        {
            Title = "Movimento",
            Icon = "player",
            Controls = {
                {
                    Kind = "Slider",
                    Setting = "WalkSpeed",
                    Id = "player_walk_speed",
                    Label = "Walk Speed",
                    Description = "Valor padrão detectado: " .. tostring(defaultWalkSpeed),
                    Min = 8,
                    Max = 200,
                    Default = defaultWalkSpeed,
                    Step = 1,
                },
                {
                    Kind = "Slider",
                    Setting = "JumpBoost",
                    Id = "player_jump_boost",
                    Label = "Jump Boost",
                    Description = "Multiplicador aplicado sobre o pulo original do personagem.",
                    Min = 1,
                    Max = 5,
                    Default = 1,
                    Step = 0.1,
                },
                {
                    Kind = "Toggle",
                    Setting = "Noclip",
                    Id = "player_noclip",
                    Label = "Noclip",
                    Description = "Desativa localmente a colisão do personagem para atravessar paredes.",
                    Default = false,
                },
            },
        },
        {
            Title = "Visibilidade",
            Icon = "eye",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "FullBright",
                    Id = "player_full_bright",
                    Label = "Full Bright",
                    Description = "Clareia áreas escuras e remove sombras e neblina localmente.",
                    Default = false,
                },
            },
        },
        {
            Title = "Proteção",
            Icon = "shield",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "AntiRagdoll",
                    Id = "player_anti_ragdoll",
                    Label = "Anti Ragdoll",
                    Description = "Impede localmente o estado de queda acionado por toggleRagdoll.",
                    Default = false,
                },
                {
                    Kind = "Toggle",
                    Setting = "AntiKnockback",
                    Id = "player_anti_knockback",
                    Label = "Anti Push / Knockback",
                    Description = "Anula o impulso somente quando o ragdoll é confirmado no seu personagem.",
                    Default = false,
                },
            },
        },
        {
            Title = "Auto",
            Icon = "farm",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "AutoCollectBaby",
                    Id = "player_auto_collect_baby",
                    Label = "Auto coletar bebê",
                    Description = "Quando Workspace.BabyPickup aparecer, tenta PickupPrompt imediatamente. Nunca usa teleporte.",
                    Default = rawget(_G, "__HMENU_AUTO_COLLECT_BABY") == true,
                },
                {
                    Kind = "Toggle",
                    Setting = "AutoCompleteHoneycomb",
                    Id = "player_auto_complete_honeycomb",
                    Label = "Auto Complete Honeycomb",
                    Description = "Arrasta o mouse automaticamente pelo caminho seguro do seu biscoito, independente da forma.",
                    Default = rawget(_G, "__HMENU_AUTO_COMPLETE_HONEYCOMB") == true,
                },
            },
        },
    },
}
end
-- END categories/Player.lua

-- BEGIN categories/Teleport.lua
__modules["categories/Teleport.lua"] = function()
return {
    Id = "Teleport",
    Label = "Teleport",
    Icon = "navigation",
    Bookmarked = false,
    RuntimeModule = "runtime/Teleport.lua",
    Sections = {
        {
            Title = "Jogadores",
            Icon = "users",
            Controls = {
                {
                    Kind = "Dropdown",
                    Setting = "SelectedPlayer",
                    OptionsSource = "Players",
                    UseList = true,
                    Id = "teleport_target",
                    Label = "Selecionar jogador",
                    Default = "Selecione um jogador",
                },
                {
                    Kind = "Dropdown",
                    Setting = "ArrivalMode",
                    Id = "teleport_arrival_mode",
                    Label = "Posição de chegada",
                    Options = { "Atrás", "Na frente", "Acima" },
                    Default = "Atrás",
                },
                {
                    Kind = "Slider",
                    Setting = "ArrivalDistance",
                    Id = "teleport_arrival_distance",
                    Label = "Distância do jogador",
                    Min = 2,
                    Max = 12,
                    Default = 4,
                    Step = 1,
                },
                {
                    Kind = "Button",
                    Setting = "TeleportToSelected",
                    Id = "teleport_to_selected",
                    Label = "Ir até o jogador",
                    ButtonText = "Teleportar",
                },
            },
        },
    },
}
end
-- END categories/Teleport.lua

-- BEGIN categories/Troll.lua
__modules["categories/Troll.lua"] = function()
return {
    Id = "Troll",
    Label = "Troll",
    Icon = "fire",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Troll.lua

-- BEGIN categories/Visuals.lua
__modules["categories/Visuals.lua"] = function()
return {
    Id = "Visuals",
    Label = "Visuals",
    Icon = "eye",
    Bookmarked = false,
    RuntimeModule = "runtime/Visuals.lua",
    Sections = {
        {
            Title = "Jogadores",
            Icon = "users",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "PlayerESP",
                    Id = "visuals_player_esp",
                    Label = "ESP de jogadores",
                    Description = "Mostra nome, vida e tags confirmadas abaixo de cada jogador.",
                    Default = false,
                },
                {
                    Kind = "Toggle",
                    Setting = "PlayerESPHealth",
                    Id = "visuals_player_health",
                    Label = "Vida dos jogadores",
                    Description = "Exibe vida atual, vida máxima, porcentagem e estado de morte.",
                    Default = true,
                },
                {
                    Kind = "Toggle",
                    Setting = "PlayerESPTeams",
                    Id = "visuals_player_teams",
                    Label = "Tags de time",
                    Description = "Usa a cor do Team ou do atributo HideNSeek_Team.",
                    Default = true,
                },
                {
                    Kind = "Toggle",
                    Setting = "PlayerESPAura",
                    Id = "visuals_player_aura",
                    Label = "Aura dos jogadores",
                    Description = "Destaca o personagem através das paredes usando a cor do time.",
                    Default = true,
                },
                {
                    Kind = "Slider",
                    Setting = "PlayerESPAuraIntensity",
                    Id = "visuals_player_aura_intensity",
                    Label = "Intensidade da aura",
                    Min = 10,
                    Max = 100,
                    Default = 45,
                    Step = 5,
                },
                {
                    Kind = "Toggle",
                    Setting = "PlayerESPGlassMaker",
                    Id = "visuals_player_glassmaker",
                    Label = "Tag de Glass Maker",
                    Description = "Exibe uma tag dourada para quem possui GlassMaker=true.",
                    Default = true,
                },
                {
                    Kind = "Toggle",
                    Setting = "PlayerESPBaby",
                    Id = "visuals_player_baby",
                    Label = "Tag de portador do bebê",
                    Description = "Exibe uma tag rosa para quem possui HasBaby=true ou BabyBack.",
                    Default = true,
                },
            },
        },
        {
            Title = "Ponte de Vidro",
            Icon = "eye",
            Controls = {
                {
                    Kind = "Paragraph",
                    Label = "Glass Vision",
                    Description = "Verde = vidro real/seguro | Vermelho = vidro falso/quebrável.",
                },
                {
                    Kind = "Toggle",
                    Setting = "GlassESP",
                    Id = "visuals_glass_esp",
                    Label = "Ver vidros reais e falsos",
                    Description = "Usa profundidade normal para não cobrir os jogadores próximos.",
                    Default = false,
                },
                {
                    Kind = "Slider",
                    Setting = "GlassTransparency",
                    Id = "visuals_glass_transparency",
                    Label = "Transparência do destaque",
                    Min = 55,
                    Max = 95,
                    Default = 82,
                    Step = 1,
                },
            },
        },
    },
}
end
-- END categories/Visuals.lua

-- BEGIN categories/Whitelist.lua
__modules["categories/Whitelist.lua"] = function()
return {
    Id = "Whitelist",
    Label = "Whitelist",
    Icon = "shield",
    Bookmarked = false,
    Sections = {},
}
end
-- END categories/Whitelist.lua

-- BEGIN runtime/Combat.lua
__modules["runtime/Combat.lua"] = function()
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
        clearHitboxes()
    end

    return runtime
end

return Combat
end
-- END runtime/Combat.lua

-- BEGIN runtime/Player.lua
__modules["runtime/Player.lua"] = function()
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
        AutoCollectBaby = rawget(_G, AUTO_COLLECT_BABY_KEY) == true,
        AutoCompleteHoneycomb = rawget(_G, AUTO_COMPLETE_HONEYCOMB_KEY) == true,
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

    if settings.AutoCompleteHoneycomb then
        startHoneycombMonitor()
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
        elseif name == "AutoCollectBaby" then
            settings.AutoCollectBaby = value == true
            rawset(_G, AUTO_COLLECT_BABY_KEY, settings.AutoCollectBaby)
            babyAttemptGeneration = babyAttemptGeneration + 1
            if settings.AutoCollectBaby then
                local model = currentBabyModel()
                if model then attemptBabyPickup(model, false) end
            end
        elseif name == "AutoCompleteHoneycomb" then
            settings.AutoCompleteHoneycomb = value == true
            rawset(_G, AUTO_COMPLETE_HONEYCOMB_KEY, settings.AutoCompleteHoneycomb)
            honeycombAttemptGeneration = honeycombAttemptGeneration + 1
            releaseHoneycombMouse()
            if settings.AutoCompleteHoneycomb then startHoneycombMonitor() end
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
end
-- END runtime/Player.lua

-- BEGIN runtime/Teleport.lua
__modules["runtime/Teleport.lua"] = function()
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
end
-- END runtime/Teleport.lua

-- BEGIN runtime/Visuals.lua
__modules["runtime/Visuals.lua"] = function()
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
    local humanoidDisplayOriginals = setmetatable({}, { __mode = "k" })
    local activeFolder
    local glassScanElapsed = 0
    local playerScanElapsed = 0
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
        if settings.GlassESP and glassScanElapsed >= 0.5 then
            glassScanElapsed = 0
            refreshFolder()
        end
        if settings.PlayerESP and playerScanElapsed >= 0.35 then
            playerScanElapsed = 0
            updatePlayerEsp()
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
        end
    end

    function runtime:Destroy()
        if destroyed then return end
        destroyed = true
        disconnectAll(folderConnections)
        clearPanels()
        clearPlayerEsp()
        disconnectAll(connections)
        activeFolder = nil
    end

    return runtime
end

return Visuals
end
-- END runtime/Visuals.lua

local Bundle = {
    Version = tostring(rawget(_G, "__HMENU_RELEASE_VERSION") or "unknown"),
    ModuleCount = 19,
}

local function createImporter()
    local cache = {}
    local loaded = {}
    local loading = {}

    return function(path)
        if loaded[path] then return cache[path] end
        local factory = __modules[path]
        if type(factory) ~= "function" then
            error("Modulo nao incluido no bundle: " .. tostring(path), 0)
        end
        if loading[path] then
            error("Dependencia circular ao importar: " .. tostring(path), 0)
        end

        loading[path] = true
        local ok, result = pcall(factory)
        loading[path] = nil
        if not ok then
            error("Falha no modulo " .. tostring(path) .. ": " .. tostring(result), 0)
        end
        if result == nil then
            error("O modulo " .. tostring(path) .. " nao retornou um valor", 0)
        end

        cache[path] = result
        loaded[path] = true
        return result
    end
end

function Bundle:Validate()
    local import = createImporter()
    local schema = import("HMenuSchema.lua")
    local config = import("HMenuConfig.lua")
    schema.ValidateConfig(config)
    local categoryIds = {}
    local controlIds = {}
    local runtimePaths = {}
    for _, path in ipairs(config.CategoryModules) do
        schema.RequireModulePath(path, "Config.CategoryModules[]")
        local category = import(path)
        schema.ValidateCategory(category, path, categoryIds, controlIds)
        if category.RuntimeModule then runtimePaths[category.RuntimeModule] = true end
    end
    if not categoryIds[config.DefaultCategory] then
        error("DefaultCategory nao esta registrada: " .. tostring(config.DefaultCategory), 0)
    end
    local runtimeCount = 0
    for path in pairs(runtimePaths) do
        local runtimeModule = import(path)
        if type(runtimeModule) ~= "table" or type(runtimeModule.Create) ~= "function" then
            error(path .. " deve expor Create", 0)
        end
        runtimeCount = runtimeCount + 1
    end
    local controlCount = 0
    for _ in pairs(controlIds) do controlCount = controlCount + 1 end
    return { Categories = #config.CategoryModules, Controls = controlCount, Runtimes = runtimeCount }
end

function Bundle:Create(options)
    options = options or {}
    local resolvedOptions = {}
    for key, value in pairs(options) do resolvedOptions[key] = value end
    resolvedOptions.Import = createImporter()
    local menu = resolvedOptions.Import("HMenu.lua")
    if type(menu) ~= "table" or type(menu.Create) ~= "function" then
        error("HMenu.lua nao expoe uma funcao Create", 0)
    end
    return menu:Create(resolvedOptions)
end

return Bundle
