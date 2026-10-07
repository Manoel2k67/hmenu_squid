local Config = {}

Config.GuiName = "HMenu"
Config.Version = "v1.1.4"
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
