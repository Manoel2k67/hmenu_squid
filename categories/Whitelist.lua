return {
    Id = "Whitelist", Label = "Whitelist", Icon = "shield", Bookmarked = false,
    Sections = {
        { Title = "Access list", Icon = "users", Controls = {
            { Kind = "Toggle", Id = "friends_allowed", Label = "Allow Friends", Default = false },
            { Kind = "Dropdown", Id = "list_policy", Label = "Default Policy", Options = { "Ignore", "Allow", "Block" }, Default = "Ignore" },
            { Kind = "Button", Id = "refresh_list", Label = "Refresh List", ButtonText = "Atualizar" },
        }},
    },
}
