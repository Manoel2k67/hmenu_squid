# HMenu Roblox v1.0

Base visual modular em Luau pronta para receber as funções de um novo projeto.

O layout, os componentes, os ícones e os temas `Default`, `Purple` e `Orange` foram preservados. Os controles exibidos nas categorias são apenas uma demonstração visual: eles não alteram o jogador, o mapa ou outros jogadores. A única ação ativa é a troca do tema do próprio menu.

## Carregamento

Depois de publicar esta pasta no repositório configurado em `KeySystem.lua`, execute:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Manoel2k67/hmenu_roblox/main/KeySystem.lua", true))()
```

O arquivo `KeySystem.lua` manteve o nome apenas para não quebrar o link público antigo. Ele não possui sistema de chave, senha, licença, site ou backend: baixa o bundle e abre o menu imediatamente.

O carregador tenta o GitHub Raw e o jsDelivr, valida a resposta antes de executar e repete o download em caso de falha temporária.

## Controles do menu

- Use **RightShift** para ocultar e mostrar o menu.
- Arraste a barra superior para mover a janela.
- Os botões `-` e `X` ocultam o menu; RightShift o mostra novamente.
- Clique na bandeira de uma categoria para fixá-la no topo.
- Em `Misc > Themes`, selecione `Default`, `Purple` ou `Orange`.

## Estrutura

```text
KeySystem.lua              entrada pública sem autenticação
HMenu.lua                  janela, componentes, temas e ciclo de vida da interface
HMenuConfig.lua            versão visual, tamanho, atalhos, cores e categorias
HMenuSchema.lua            contratos das definições declarativas
categories/                páginas e controles visuais sem funções do jogo
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
