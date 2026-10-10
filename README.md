# HMenu Roblox v1.2.24

Base visual modular em Luau pronta para receber as funções de um novo projeto.

O layout, os componentes e os ícones foram preservados. Os temas selecionáveis agora são `Default`, `White` com Yuno e `Black` com Asta; as paletas claras e escuras mantêm textos, botões e controles legíveis sobre os wallpapers. `Teleport` permite mover o personagem local até outro jogador ou para Incinerador, Elevador do lobby, Sala do Frontman e Instalação/Ilha. `Player` oferece WalkSpeed, Jump Boost, Noclip, movimento experimental no Pentatlo, Full Bright, Anti Ragdoll, Anti Push, Auto Cadeira Musical e Auto Baby. `Combat` oferece expansão de hitbox com alcance configurável e caixa visual sincronizada com as cores do ESP. `Visuals` identifica os vidros da ponte, mostra nomes, vida, auras e tags coloridas de jogadores e marca somente as portas finais do Hide & Seek. As demais categorias permanecem vazias, prontas para receber conteúdo novo.

O **Auto Collect** monitora `Workspace.BabyPickup` enquanto o bebê permanecer no chão e tenta `Trigger.PickupPrompt` até `HasBaby=true` confirmar a coleta. O módulo nunca teleporta ou move o personagem. Internamente, amplia localmente `MaxActivationDistance` para `1000`, zera `HoldDuration`, desativa linha de visão, aguarda um frame e repete assinaturas compatíveis de `fireproximityprompt`. Ele não usa o ciclo normal de segurar `E`, portanto não depende de apontar a câmera para o bebê. Prompts ainda ausentes ou desabilitados continuam sendo observados, em vez de serem descartados depois da primeira falha. A opção opera silenciosamente e seu estado é preservado entre recarregamentos do menu na mesma sessão do executor.

**Auto Cadeira Musical** espera `Trigger.TouchInterest` nas cadeiras, sinal observado junto de `TAKE A SEAT!`. No modo padrão **Perto (4 studs)**, aproxime-se normalmente: o menu só tenta uma cadeira livre cujo Trigger esteja a até **4 studs** do personagem. Cada ativação do Trigger recebe no máximo uma tentativa, inclusive ao desligar e religar a opção; uma nova rodada, com novo TouchInterest, permite tentar novamente. O início e o fim do toque são enviados sem aguardar um frame entre eles. Depois, o menu espera até 1 segundo pela confirmação local de `SeatPart`, `Occupant` e um `SeatWeld` ligado ao próprio personagem. Qualquer vínculo parcial já impede novas tentativas e interferência de Anti Ragdoll, Anti Push e movimento forçado no assento. Sem `firetouchinterest`, é necessário encostar normalmente no Trigger; o menu não chama `Seat:Sit()` como alternativa.

A correção de `1.2.21` limita o modo Perto e elimina a repetição contínua que podia contribuir para os puxões relatados. No teste enviado pelo usuário, uma tentativa perto, a `2,9 studs`, registrou vínculo local em `0,16s`; o usuário também relatou permanecer sentado após o deslocamento pela lava e vencer a rodada. Isso reforça a aceitação daquele assento, sem isolar o efeito da automação do contato físico normal. O teste invertido da `1.2.22`, a `35,3 studs`, não confirmou vínculo e registrou deslocamento máximo de `51,5 studs`. Esse resultado não identifica sozinho a causa do deslocamento, mas a ordem invertida foi retirada das opções.

**Retorno da 1.2.23:** os diagnósticos enviados registram falha de confirmação a `74,3 studs` (deslocamento máximo `124,4 studs`) e `29,1 studs` (deslocamento `33,6 studs`). Na tentativa a `16,8 studs`, outra pessoa ocupou o alvo, com deslocamento observado de `32,7 studs`. Os relatórios com cabeçalho Perto terminam após a troca de modo e não registram uma nova tentativa perto. Esses dados descartam sucesso dessas tentativas distantes, mas não identificam qual componente causou cada deslocamento. O método de toque simulado com alcance ampliado foi retirado das opções.

**Trigger ampliado — 1.2.24:** em `Player > Auto`, selecione **Trigger ampliado**, ajuste **Alcance da cadeira (studs)** para incluir a distância até as cadeiras e ligue **Auto cadeira musical**. O slider permite **4–160 studs** e começa em **8**. Quando `TAKE A SEAT!` aparecer, dê um passo durante a tentativa. A opção seleciona uma cadeira livre com Trigger ancorado e sem colisão, amplia somente o `Size` desse Trigger para alcançar a posição atual do personagem e mantém a ampliação por até **1 segundo**. Preserva posição e rotação da cadeira e não chama `firetouchinterest` neste modo. A hipótese é que o contato físico com o volume ampliado possa produzir uma interação aceita; ainda não houve teste em partida dessa variação.

A documentação do Roblox informa que `Touched` depende da simulação física e pode ocorrer mesmo com `CanCollide=false`. Por isso o teste observa contatos locais enquanto o jogador se movimenta normalmente; a geometria ampliada sozinha não comprova interação nem aceitação pelo servidor. [Documentação de colisões](https://create.roblox.com/docs/workspace/collisions).

O experimental faz **uma tentativa total por janela observada**, aguarda até 2 segundos e exige 0,5 segundo de vínculo local contínuo para registrar estabilidade. Desligar/religar, trocar de modo ou alterar o slider não libera outra tentativa experimental enquanto algum dos TouchInterests da janela usada continuar na pasta das cadeiras. O tamanho original é restaurado ao terminar o pulso, aparecer vínculo parcial, desligar a opção, trocar o modo ou destruir o menu; mudança de personagem, fase ou remoção do alvo encerra a observação e restaura na retomada do frame. Uma atualização de tamanho feita pelo jogo durante o teste é preservada. Erros também executam a restauração. O modo **Perto (4 studs)** continua com o toque normal e limite fixo.

**Copiar diagnóstico** registra as últimas 60 linhas com método, alcance, alvo, distância, **contatosLocais**, resultado, deslocamento máximo e velocidade máxima observada. Ajustes intermediários do slider não ocupam o histórico; o valor usado aparece na tentativa e o valor atual no cabeçalho. `contatosLocais=0` indica que não foi observado contato com o personagem durante o teste; contato positivo com ausência de vínculo indica contato local sem assento confirmado. Se o clipboard estiver indisponível, o relatório aparece no console. Copie depois do teste e informe também se sobreviveu à rodada. Testes automatizados validam geometria, restauração, cancelamento e diagnóstico; não emulam a física nem a validação do servidor.

**Movimento no Pentatlo** atua quando `PENTA_ONGOING=true` e `PlayingPentathlon=true`. Enquanto ligado, vigia e devolve imediatamente `DISABLE_MOVEMENT` e `DISABLE_WALKSPEED` para `false`, reativa os controles padrão e remove ancoragem local do personagem. Como segunda camada, WASD/setas comandam diretamente o Humanoid e a velocidade horizontal no fim de cada frame, mesmo quando o controlador da fase tenta consumir a entrada. Ao detectar o fim da fase, o módulo limpa os bloqueios e reativa repetidamente o `PlayerModule` durante a transição. Se o script da fase continuar desativando os controles, **Manter movimento destravado** aplica a liberação continuamente até o usuário desligar a opção, sem interferir quando o Humanoid estiver realmente sentado.

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
