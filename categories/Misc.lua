return {
    Id = "Misc",
    Label = "Misc",
    Icon = "settings",
    Bookmarked = false,
    RuntimeModule = "runtime/Misc.lua",
    Sections = {
        {
            Title = "Temas",
            Icon = "palette",
            Controls = {
                {
                    Kind = "Dropdown",
                    Setting = "MenuTheme",
                    Id = "menu_theme",
                    Label = "Tema do menu",
                    Description = "Altera a paleta e o wallpaper sem prejudicar a leitura dos controles.",
                    Options = { "Default", "White", "Black" },
                    Default = "Default",
                    UseList = true,
                },
            },
        },
    },
}
