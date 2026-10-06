return {
    Id = "Visuals",
    Label = "Visuals",
    Icon = "eye",
    Bookmarked = false,
    Sections = {
        {
            Title = "Player ESP",
            Icon = "eye",
            Controls = {
                { Kind = "Toggle", Id = "esp_enabled", Label = "Enable ESP", Description = "Innocent: green | Murderer: red | Sheriff: blue", Default = false },
                { Kind = "Toggle", Id = "player_names", Label = "Player Names", Default = false },
                { Kind = "Toggle", Id = "show_roles", Label = "Show Roles", Default = false },
                { Kind = "Toggle", Id = "show_distance", Label = "Show Distance", Default = false },
                { Kind = "Toggle", Id = "show_health", Label = "Show Health", Default = false },
                { Kind = "Toggle", Id = "xray", Label = "X-Ray ESP", Description = "Keep role highlights visible through walls.", Default = false },
                { Kind = "Slider", Id = "esp_fill", Label = "Fill Transparency", Min = 0, Max = 100, Default = 68, Step = 1 },
            },
        },
        {
            Title = "Items ESP",
            Icon = "map",
            Controls = {
                { Kind = "Toggle", Id = "show_coins", Label = "Show Coins", Description = "Highlights coins. X-Ray ESP controls visibility through walls.", Default = false },
                { Kind = "Toggle", Id = "dropped_items", Label = "Show Dropped Gun", Description = "Highlights GunDrop in gold and adds a world label.", Default = false },
            },
        },
        {
            Title = "Camera",
            Icon = "camera",
            Controls = {
                { Kind = "Slider", Id = "fov", Label = "Field of View", Min = 50, Max = 120, Default = 70, Step = 1 },
                { Kind = "Dropdown", Id = "crosshair", Label = "Crosshair", Options = { "Off", "Dot", "Classic" }, Default = "Off" },
            },
        },
        {
            Title = "World Visibility",
            Icon = "atmosphere",
            Controls = {
                { Kind = "Toggle", Id = "full_bright", Label = "Full Bright", Description = "Brightens dark maps while preserving the original settings.", Default = false },
                { Kind = "Toggle", Id = "no_fog", Label = "Remove Fog", Default = false },
            },
        },
    },
}
