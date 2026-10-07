return {
    Id = "Teleport",
    Label = "Teleport",
    Icon = "navigation",
    Bookmarked = false,
    RuntimeModule = "runtime/Teleport.lua",
    Sections = {
        {
            Title = "Jogadores",
            Icon = "users",
            Controls = {
                {
                    Kind = "Dropdown",
                    Setting = "SelectedPlayer",
                    OptionsSource = "Players",
                    UseList = true,
                    Id = "teleport_target",
                    Label = "Selecionar jogador",
                    Default = "Selecione um jogador",
                },
                {
                    Kind = "Dropdown",
                    Setting = "ArrivalMode",
                    Id = "teleport_arrival_mode",
                    Label = "Posição de chegada",
                    Options = { "Atrás", "Na frente", "Acima" },
                    Default = "Atrás",
                },
                {
                    Kind = "Slider",
                    Setting = "ArrivalDistance",
                    Id = "teleport_arrival_distance",
                    Label = "Distância do jogador",
                    Min = 2,
                    Max = 12,
                    Default = 4,
                    Step = 1,
                },
                {
                    Kind = "Button",
                    Setting = "TeleportToSelected",
                    Id = "teleport_to_selected",
                    Label = "Ir até o jogador",
                    ButtonText = "Teleportar",
                },
            },
        },
    },
}
