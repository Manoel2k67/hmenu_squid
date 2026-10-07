return {
    Id = "Visuals",
    Label = "Visuals",
    Icon = "eye",
    Bookmarked = false,
    RuntimeModule = "runtime/Visuals.lua",
    Sections = {
        {
            Title = "Ponte de Vidro",
            Icon = "eye",
            Controls = {
                {
                    Kind = "Paragraph",
                    Label = "Glass Vision",
                    Description = "Verde = vidro real/seguro | Vermelho = vidro falso/quebrável.",
                },
                {
                    Kind = "Toggle",
                    Setting = "GlassESP",
                    Id = "visuals_glass_esp",
                    Label = "Ver vidros reais e falsos",
                    Description = "Usa profundidade normal para não cobrir os jogadores próximos.",
                    Default = false,
                },
                {
                    Kind = "Slider",
                    Setting = "GlassTransparency",
                    Id = "visuals_glass_transparency",
                    Label = "Transparência do destaque",
                    Min = 55,
                    Max = 95,
                    Default = 82,
                    Step = 1,
                },
            },
        },
    },
}
