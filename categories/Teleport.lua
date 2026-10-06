return {
    Id = "Teleport",
    Label = "Teleport",
    Icon = "navigation",
    Bookmarked = false,
    Sections = {
        {
            Title = "Role Teleports",
            Icon = "users",
            Controls = {
                { Kind = "Button", Id = "tp_murderer", Label = "Teleport to Murderer", Description = "Moves behind the current murderer.", ButtonText = "Teleport" },
                { Kind = "Button", Id = "tp_sheriff", Label = "Teleport to Sheriff", Description = "Also finds the Hero carrying the gun.", ButtonText = "Teleport" },
                { Kind = "Button", Id = "tp_gun", Label = "Teleport to Dropped Gun", ButtonText = "Teleport" },
            },
        },
        {
            Title = "Player Teleport",
            Icon = "player",
            Controls = {
                { Kind = "Dropdown", Options = { "Select a player" }, UseList = true, Id = "target_player", Label = "Target Player", Default = "Select a player" },
                { Kind = "Dropdown", Id = "arrival_mode", Label = "Arrival Position", Options = { "Behind", "In Front", "Above" }, Default = "Behind" },
                { Kind = "Slider", Id = "arrival_distance", Label = "Arrival Distance", Min = 2, Max = 12, Default = 4, Step = 1 },
                { Kind = "Button", Id = "tp_selected", Label = "Teleport to Selected Player", ButtonText = "Teleport" },
                { Kind = "Button", Id = "tp_nearest", Label = "Teleport to Nearest Player", ButtonText = "Teleport" },
                { Kind = "Button", Id = "tp_random", Label = "Teleport to Random Player", ButtonText = "Teleport" },
            },
        },
        {
            Title = "Saved Location",
            Icon = "map",
            Controls = {
                { Kind = "Button", Id = "save_position", Label = "Save Current Position", Description = "Stores the exact position for this session.", ButtonText = "Save" },
                { Kind = "Button", Id = "load_position", Label = "Return to Saved Position", ButtonText = "Return" },
            },
        },
    },
}
