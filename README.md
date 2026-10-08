# HMenu Roblox v1.2.6

Base visual modular em Luau pronta para receber as funções de um novo projeto.

O layout, os componentes, os ícones e os temas `Default`, `Purple` e `Orange` foram preservados. `Teleport` permite mover o personagem local até outro jogador. `Player` oferece WalkSpeed, Jump Boost, Noclip, Full Bright, Anti Ragdoll, Anti Push, Auto Baby e Auto Complete Honeycomb. `Combat` oferece expansão de hitbox com alcance configurável e caixa visual sincronizada com as cores do ESP. `Visuals` identifica os vidros da ponte, mostra nomes, vida, auras e tags coloridas de jogadores e marca somente as portas finais do Hide & Seek. As demais categorias permanecem vazias, prontas para receber conteúdo novo.

O **Auto Collect** observa `Workspace.BabyPickup` e tenta `Trigger.PickupPrompt` assim que o bebê é derrubado. O módulo nunca teleporta ou move o personagem. Internamente, amplia localmente `MaxActivationDistance` para `1000`, zera `HoldDuration`, desativa linha de visão, aguarda um frame para aplicar as propriedades e chama `fireproximityprompt` em dois modos compatíveis. Como o funcionamento distante já foi confirmado, a opção opera silenciosamente, sem notificações ou logs. O estado ligado/desligado é preservado entre recarregamentos do menu na mesma sessão do executor.

O **Auto Complete Honeycomb** aguarda a quantidade de segmentos de `Workspace.Map.Honeycomb.Shapes.<jogador>.Path` estabilizar, projeta o caminho para a tela e arrasta o mouse a partir do marcador verde observado. Ele também aplica o atributo `Completed=true` encontrado nos segmentos concluídos, deixando o traçado real como fallback para validações por raycast. Se o modelo não estiver nomeado com o jogador local, o módulo seleciona somente a forma que ocupa o centro da câmera. O menu é ocultado durante o traçado e restaurado ao final. São aceitas as APIs `mousemoveabs`, `mousemoverel`, `mouse1press` e `mouse1release`, com fallback para `VirtualInputManager`.

## Carregamento

Depois de publicar esta pasta no repositório configurado em `KeySystem.lua`, execute:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Manoel2k67/hmenu_squid/main/KeySystem.lua", true))()
```

O arquivo `KeySystem.lua` manteve o nome apenas para não quebrar o link público antigo. Ele não possui sistema de chave, senha, licença, site ou backend: baixa o bundle e abre o menu imediatamente.

O carregador tenta o GitHub Raw e o jsDelivr, valida a resposta antes de executar e repete o download em caso de falha temporária.

## Controles do menu

- Use **RightShift** para ocultar e mostrar o menu.
- Arraste a barra superior para mover a janela.
- Os botões `-` e `X` ocultam o menu; RightShift o mostra novamente.
- Clique na bandeira de uma categoria para fixá-la no topo.

## Estrutura

```text
KeySystem.lua              entrada pública sem autenticação
HMenu.lua                  janela, componentes, temas e ciclo de vida da interface
HMenuConfig.lua            versão visual, tamanho, atalhos, cores e categorias
HMenuSchema.lua            contratos das definições declarativas
categories/                páginas do menu; Player, Teleport e Visuals possuem conteúdo
runtime/Player.lua         movimento, proteções e Auto Collect do bebê
runtime/Combat.lua         hitbox expansível e visual por cor de time
runtime/Teleport.lua       teleporte do personagem local até um jogador selecionado
runtime/Visuals.lua        Glass Vision, ESP de jogadores e saídas finais do Hide & Seek
theme/wallpapers/          wallpapers preservados dos temas
dist/HMenu.bundle.lua      arquivo gerado usado no executor
tools/Build-Bundle.ps1     gerador determinístico do bundle
tools/Test-Project.ps1     verificações de release, estrutura e sintaxe
tests/                     suporte aos testes de contrato do bundle
```

## Adicionando funções depois

Os controles disponíveis são `Toggle`, `Slider`, `Dropdown`, `Button` e `Paragraph`. Para ligar um controle a uma função simples, adicione um `Callback` na definição da categoria:

```lua
{
    Kind = "Toggle",
    Id = "my_option",
    Label = "Minha opção",
    Default = false,
    Callback = function(enabled)
        -- implementação futura
    end,
}
```

Para funcionalidades maiores, a infraestrutura de `RuntimeModule`, `Create`, `Set` e `Destroy` continua suportada pelo motor do menu. Crie um módulo em `runtime/`, associe-o à categoria e regenere o bundle.

## Build e validação

Depois de qualquer alteração nos fontes:

```powershell
.\tools\Build-Bundle.ps1
.\tools\Test-Project.ps1
```

Se `luau-compile` estiver disponível, o script também valida a sintaxe Luau. O arquivo `dist/HMenu.bundle.lua` é gerado automaticamente e não deve ser editado à mão.

Para uma nova release, atualize `VERSION`, a constante `RELEASE_VERSION` em `KeySystem.lua`, a versão visual em `HMenuConfig.lua` e gere novamente o bundle.
