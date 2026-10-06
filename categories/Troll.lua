return {
    Id = "Troll",
    Label = "Troll",
    Icon = "fire",
    Bookmarked = false,
    Sections = {
        {
            Title = "Fling",
            Icon = "fire",
            Controls = {
                {
                    Kind = "Dropdown",
                    Options = { "Select a player" },
                    UseList = true,
                    Id = "troll_target_player",
                    Label = "Target Player",
                    Default = "Select a player",
                },
                {
                    Kind = "Button",
                    Id = "fling_selected",
                    Label = "Fling Target",
                    Description = "Arremessa o jogador selecionado para fora do mapa e retorna você à posição inicial.",
                    ButtonText = "Fling",
                },
                {
                    Kind = "Toggle",
                    Id = "touch_fling",
                    Label = "Fling ao Encostar",
                    Description = "Arremessa para fora do mapa qualquer jogador em quem você encostar.",
                    Default = false,
                },
            },
        },
    },
}
