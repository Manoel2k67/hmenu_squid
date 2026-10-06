return {
    Id = "Main", Label = "Main", Icon = "home", Bookmarked = false,
    Sections = {
        { Title = "Overview", Icon = "overview", Controls = {
            { Kind = "Paragraph", Label = "HMenu está pronto", Description = "Interface modular carregada com dados de demonstração." },
            { Kind = "Dropdown", Id = "profile", Label = "Perfil ativo", Options = { "Default", "Performance", "Custom" }, Default = "Default" },
            { Kind = "Button", Id = "save_profile", Label = "Salvar preferências", ButtonText = "Salvar" },
        }},
        { Title = "Quick settings", Icon = "settings", Controls = {
            { Kind = "Toggle", Id = "notifications", Label = "Notificações", Default = false },
            { Kind = "Toggle", Id = "auto_save", Label = "Salvar automaticamente", Default = false },
        }},
    },
}
