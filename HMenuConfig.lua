local Config = {}

Config.GuiName = "HMenu"
Config.Version = "v1.2.12"
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
    White = {
        Wallpaper = "theme/wallpapers/White.png",
        WallpaperTransparency = 0.18,
        ShadeTransparency = 0.58,
        Colors = {
            Window = Color3.fromRGB(235, 239, 244),
            WindowHighlight = Color3.fromRGB(255, 255, 255),
            WindowDark = Color3.fromRGB(218, 224, 232),
            Sidebar = Color3.fromRGB(244, 247, 250),
            Header = Color3.fromRGB(248, 250, 252),
            Surface = Color3.fromRGB(248, 250, 252),
            SurfaceHover = Color3.fromRGB(228, 234, 241),
            Control = Color3.fromRGB(235, 239, 244),
            Accent = Color3.fromRGB(24, 30, 38),
            Bookmark = Color3.fromRGB(91, 113, 84),
            Text = Color3.fromRGB(18, 23, 30),
            Muted = Color3.fromRGB(55, 65, 77),
            Dim = Color3.fromRGB(99, 111, 125),
            Border = Color3.fromRGB(157, 169, 182),
            Success = Color3.fromRGB(37, 137, 83),
            Danger = Color3.fromRGB(193, 54, 66),
        },
    },
    Black = {
        Wallpaper = "theme/wallpapers/Black.png",
        WallpaperTransparency = 0.14,
        ShadeTransparency = 0.62,
        Colors = {
            Window = Color3.fromRGB(11, 12, 15),
            WindowHighlight = Color3.fromRGB(28, 30, 35),
            WindowDark = Color3.fromRGB(5, 6, 8),
            Sidebar = Color3.fromRGB(9, 10, 13),
            Header = Color3.fromRGB(12, 13, 16),
            Surface = Color3.fromRGB(23, 24, 29),
            SurfaceHover = Color3.fromRGB(35, 37, 43),
            Control = Color3.fromRGB(16, 17, 21),
            Accent = Color3.fromRGB(245, 247, 250),
            Bookmark = Color3.fromRGB(255, 215, 75),
            Text = Color3.fromRGB(248, 249, 252),
            Muted = Color3.fromRGB(199, 203, 211),
            Dim = Color3.fromRGB(128, 134, 145),
            Border = Color3.fromRGB(88, 93, 104),
            Success = Color3.fromRGB(100, 222, 150),
            Danger = Color3.fromRGB(255, 82, 96),
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
