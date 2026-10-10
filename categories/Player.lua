local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local character = localPlayer and localPlayer.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local defaultWalkSpeed = humanoid and tonumber(humanoid.WalkSpeed) or 16
defaultWalkSpeed = math.clamp(defaultWalkSpeed, 8, 200)

return {
    Id = "Player",
    Label = "Player",
    Icon = "player",
    Bookmarked = false,
    RuntimeModule = "runtime/Player.lua",
    Sections = {
        {
            Title = "Movimento",
            Icon = "player",
            Controls = {
                {
                    Kind = "Slider",
                    Setting = "WalkSpeed",
                    Id = "player_walk_speed",
                    Label = "Walk Speed",
                    Description = "Valor padrão detectado: " .. tostring(defaultWalkSpeed),
                    Min = 8,
                    Max = 200,
                    Default = defaultWalkSpeed,
                    Step = 1,
                },
                {
                    Kind = "Slider",
                    Setting = "JumpBoost",
                    Id = "player_jump_boost",
                    Label = "Jump Boost",
                    Description = "Multiplicador aplicado sobre o pulo original do personagem.",
                    Min = 1,
                    Max = 5,
                    Default = 1,
                    Step = 0.1,
                },
                {
                    Kind = "Toggle",
                    Setting = "Noclip",
                    Id = "player_noclip",
                    Label = "Noclip",
                    Description = "Desativa localmente a colisão do personagem para atravessar paredes.",
                    Default = false,
                },
            },
        },
        {
            Title = "Visibilidade",
            Icon = "eye",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "FullBright",
                    Id = "player_full_bright",
                    Label = "Full Bright",
                    Description = "Clareia áreas escuras e remove sombras e neblina localmente.",
                    Default = false,
                },
            },
        },
        {
            Title = "Proteção",
            Icon = "shield",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "AntiRagdoll",
                    Id = "player_anti_ragdoll",
                    Label = "Anti Ragdoll",
                    Description = "Impede localmente o estado de queda acionado por toggleRagdoll.",
                    Default = false,
                },
                {
                    Kind = "Toggle",
                    Setting = "AntiKnockback",
                    Id = "player_anti_knockback",
                    Label = "Anti Push / Knockback",
                    Description = "Anula o impulso somente quando o ragdoll é confirmado no seu personagem.",
                    Default = false,
                },
            },
        },
        {
            Title = "Auto",
            Icon = "farm",
            Controls = {
                {
                    Kind = "Toggle",
                    Setting = "ManualSit",
                    Id = "player_manual_sit",
                    Label = "Sentar manualmente",
                    Description = "Ligado força o personagem a sentar; desligado faz levantar. Controle manual para testes.",
                    Default = false,
                },
                {
                    Kind = "Toggle",
                    Setting = "AutoCollectBaby",
                    Id = "player_auto_collect_baby",
                    Label = "Auto coletar bebê",
                    Description = "Quando Workspace.BabyPickup aparecer, tenta PickupPrompt imediatamente. Nunca usa teleporte.",
                    Default = rawget(_G, "__HMENU_AUTO_COLLECT_BABY") == true,
                },
            },
        },
    },
}
