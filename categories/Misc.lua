return {
    Id = "Misc", Label = "Misc", Icon = "settings", Bookmarked = false,
    Sections = {
        { Title = "Themes", Icon = "palette", Controls = {
            {
                Kind = "Dropdown", Id = "menu_theme", Label = "Menu Theme",
                Description = "Changes the menu palette and background while keeping controls easy to read.",
                Options = { "Default", "Purple", "Orange" }, Default = "Default", UseList = true,
                Callback = function(value)
                    local setTheme = rawget(_G, "__HMENU_SET_THEME")
                    if type(setTheme) == "function" then setTheme(value) end
                end,
            },
        }},
        { Title = "Utilities", Icon = "sliders", Controls = {
            { Kind = "Toggle", Id = "show_fps", Label = "Show FPS", Description = "Displays live FPS and network ping.", Default = false },
            { Kind = "Toggle", Id = "performance_mode", Label = "Performance Mode", Description = "Temporarily reduces local visual effects to improve performance.", Default = false },
        }},
    },
}
