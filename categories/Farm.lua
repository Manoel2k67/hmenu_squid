return {
    Id = "Farm",
    Label = "Farm",
    Icon = "farm",
    Bookmarked = false,
    Sections = {
        {
            Title = "Coin Farm",
            Icon = "farm",
            Controls = {
                { Kind = "Toggle", Id = "auto_coins", Label = "Auto Collect Coins", Description = "Continuously collects the nearest available coin.", Default = false },
                { Kind = "Button", Id = "nearest_coin", Label = "Teleport to Nearest Coin", ButtonText = "Collect" },
                { Kind = "Toggle", Id = "return_after_sweep", Label = "Return After Sweep", Description = "Returns to the starting position after one-time collection.", Default = false },
            },
        },
        {
            Title = "Event Items",
            Icon = "refresh",
            Controls = {
                { Kind = "Dropdown", Id = "event_filter", Label = "Event Item", Options = { "All", "Eggs", "Beach Balls", "Candy" }, Default = "All" },
                { Kind = "Toggle", Id = "auto_event_items", Label = "Auto Collect Event Items", Description = "Looks for eggs, beach balls, candy and event tokens.", Default = false },
                { Kind = "Button", Id = "collect_all_events", Label = "Collect All Event Items", ButtonText = "Collect" },
            },
        },
        {
            Title = "Movement Settings",
            Icon = "settings",
            Controls = {
                { Kind = "Dropdown", Id = "farm_mode", Label = "Movement Mode", Options = { "Teleport", "Smooth", "Walk" }, Default = "Teleport" },
                { Kind = "Slider", Id = "farm_delay", Label = "Action Delay", Min = 0.1, Max = 1, Default = 0.2, Step = 0.1 },
                { Kind = "Slider", Id = "smooth_speed", Label = "Smooth Speed", Min = 20, Max = 200, Default = 70, Step = 5 },
                { Kind = "Slider", Id = "farm_walk_speed", Label = "Farm Walk Speed", Min = 16, Max = 100, Default = 16, Step = 2 },
            },
        },
    },
}
