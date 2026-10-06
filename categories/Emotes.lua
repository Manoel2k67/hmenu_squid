return {
    Id = "Emotes", Label = "Emotes", Icon = "smile", Bookmarked = false,
    Sections = {
        { Title = "Animations", Icon = "music", Controls = {
            { Kind = "Dropdown", Id = "emote", Label = "Selected Emote", Options = { "Sit", "Zen", "Ninja Rest", "Dab", "Floss", "Zombie", "Headless" }, Default = "Sit" },
            { Kind = "Button", Id = "play_emote", Label = "Play Emote", ButtonText = "Reproduzir" },
            { Kind = "Toggle", Id = "loop_emote", Label = "Loop", Default = false },
        }},
    },
}
