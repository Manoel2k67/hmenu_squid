# HMenu Roblox v1.2.15

Base visual modular em Luau pronta para receber as funções de um novo projeto.

O layout, os componentes e os ícones foram preservados. Os temas selecionáveis agora são `Default`, `White` com Yuno e `Black` com Asta; as paletas claras e escuras mantêm textos, botões e controles legíveis sobre os wallpapers. `Teleport` permite mover o personagem local até outro jogador ou para Incinerador, Elevador do lobby, Sala do Frontman e Instalação/Ilha. `Player` oferece WalkSpeed, Jump Boost, Noclip, movimento experimental no Pentatlo, Full Bright, Anti Ragdoll, Anti Push, sentar manualmente e Auto Baby. `Combat` oferece expansão de hitbox com alcance configurável e caixa visual sincronizada com as cores do ESP. `Visuals` identifica os vidros da ponte, mostra nomes, vida, auras e tags coloridas de jogadores e marca somente as portas finais do Hide & Seek. As demais categorias permanecem vazias, prontas para receber conteúdo novo.

O **Auto Collect** monitora `Workspace.BabyPickup` enquanto o bebê permanecer no chão e tenta `Trigger.PickupPrompt` até `HasBaby=true` confirmar a coleta. O módulo nunca teleporta ou move o personagem. Internamente, amplia localmente `MaxActivationDistance` para `1000`, zera `HoldDuration`, desativa linha de visão, aguarda um frame e repete assinaturas compatíveis de `fireproximityprompt`. Ele não usa o ciclo normal de segurar `E`, portanto não depende de apontar a câmera para o bebê. Prompts ainda ausentes ou desabilitados continuam sendo observados, em vez de serem descartados depois da primeira falha. A opção opera silenciosamente e seu estado é preservado entre recarregamentos do menu na mesma sessão do executor.

**Movimento no Pentatlo** atua somente quando `PENTA_ONGOING=true` e `PlayingPentathlon=true`. Enquanto ligado, vigia e devolve imediatamente `DISABLE_MOVEMENT` e `DISABLE_WALKSPEED` para `false`, reativa os controles padrão e remove ancoragem local do personagem. Como segunda camada, WASD/setas comandam diretamente o Humanoid e a velocidade horizontal no fim de cada frame, mesmo quando o controlador da fase tenta consumir a entrada. Espaço continua enviando o salto. Ao desligar durante a fase, restaura os atributos observados antes da ativação; ao terminar a fase, remove o estado temporário para não afetar os próximos jogos.

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
runtime/Misc.lua           seletor dos temas Default, White e Black
runtime/Teleport.lua       teleporte até jogadores e áreas carregadas do mapa
runtime/Visuals.lua        Glass Vision, ESP de jogadores e saídas finais do Hide & Seek
theme/wallpapers/          wallpapers White/Yuno e Black/Asta
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
