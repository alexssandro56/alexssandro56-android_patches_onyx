# onyx-extras

Extras para o AOSPA (Android 17) no POCO F7 (`onyx`), mantidos fora do device tree:

- **GameSpace**: painel de jogos do IRedDragonICY, com o suporte no framework escrito para o AOSPA.
- **AFME**: geração de quadros na GPU do IRedDragonICY (layers EGL e Vulkan), ligada por jogo pelo GameSpace.
- **mithermald**: daemon térmico open source (Rust) do IRedDragonICY, no lugar do `mi_thermald` da Xiaomi.

## Estrutura

| Caminho | O que é |
| --- | --- |
| `local_manifests/onyx_extras.xml` | Baixa este repositório em `vendor/onyx-extras`, o GameSpace em `packages/apps/GameSpace`, o AFME em `external/afme` e o mithermald em `external/mithermald` |
| `vendorsetup.sh` | Aplica os patches de `patches/` em todo `source build/envsetup.sh` |
| `patches/frameworks/base/` | Suporte ao GameSpace no `system_server` e no SystemUI (serviço `game_space`, AFME, bypass de carregamento, serviço AxPlatform) |
| `patches/frameworks/native/` | Carregadores EGL e Vulkan carregam os layers do AFME no jogo armado |
| `patches/external/mithermald/` | Ajusta o mithermald ao `librustutils` do Android 17 (`rustutils::android::system_properties`) |
| `patches/packages/apps/GameSpace/` | Remove a dependência do SDK da LineageOS, que o AOSPA não tem |
| `sdk/` | Módulos `ax_*` e as bibliotecas Compose pré-compiladas que o GameSpace usa |
| `mithermald/sepolicy/` | Política SELinux do `mi_thermal_engine` (a ROM é enforcing) |
| `gamespace/sepolicy/` | Política SELinux do GameSpace: serviço `game_space`, as props `persist.sys.afme.*`, `persist.sys.mithermal.*` e `sys.gamespace.*` e os nós do kernel que ele escreve (thermal_message, migt/metis, sched_boost, CPU, carga, disp_param) |
| `gamespace/init/` | Liga e desliga o bypass de carregamento |
| `onyx_extras.mk`, `BoardConfigExtras.mk` | O que o device tree inclui |
| `device/` | Patch para o device tree incluir tudo isso e parar o `mi_thermald` stock |

## Como usar

1. Copie o manifest e sincronize:
   ```
   mkdir -p .repo/local_manifests
   cp vendor/onyx-extras/local_manifests/onyx_extras.xml .repo/local_manifests/
   repo sync -c --no-tags vendor/onyx-extras packages/apps/GameSpace external/afme external/mithermald
   ```
   Na primeira vez, baixe o arquivo direto do GitHub, porque `vendor/onyx-extras` ainda não existe.
2. Aplique o patch do device tree:
   ```
   cd device/xiaomi/onyx
   git am ../../../vendor/onyx-extras/device/0001-onyx-Wire-up-onyx-extras.patch
   ```
3. Compile normalmente. O `source build/envsetup.sh` aplica os patches e mostra
   `onyx-extras: applied ...` para cada um.

## GameSpace

App: `IRedDragonICY/GameSpace` (main), pacote `com.ireddragonicy.gamespace`.

O IRedDragonICY não publicou os patches de framework dele, então o lado do
`system_server` foi montado a partir do suporte do crDroid 17.0
(`crdroidandroid/android_frameworks_base`):

- `5c0bee650d4` core: adding support for game space
- `2133c5519ab` services: Treat gamespace apps as games
- `cd8470b5b68` services: Add toggle for gamespace auto detect apps

mais o serviço `game_space` que o app espera (`IGameSpaceService` e
`IGameSpaceCallback`: avisos de início e fim de jogo e a lista de sockets usada
no monitor de ping).

O que foi feito para o AOSPA:

- **AFME**: quando um jogo com AFME configurado vem para a frente, o
  `GameSpaceService` aplica as configurações dele (`persist.sys.afme.*`) e
  coloca o nome do jogo em `persist.sys.afme.app`. O `libEGL` e o `libvulkan`
  só carregam os layers de `/system_ext/lib64/afme` nesse processo. Desligar
  vale na hora; ligar com o jogo já aberto só vale depois de reabrir o jogo.
- **Bypass de carregamento**: com um jogo na frente e o bypass ligado (no painel
  ou nas configurações), o init escreve `1` em
  `/sys/class/xm_power/charger/smart_charge/smart_night`, que para de carregar a
  bateria. Ao sair do jogo, escreve `0`. É o mesmo nó do limite de carga do
  AOSPA, então não use os dois juntos.
- **Painel do jogo (AxPlatform)**: o serviço do crDroid/AxionOS foi portado para o
  SystemUI do AOSPA. Funcionam os toggles rápidos, print, gravação de tela e o
  estado de bateria/mídia. A gravação "só do jogo" abre o gravador normal (dá para
  escolher o app no próprio diálogo).
- **mithermald**: os perfis térmicos e de carga do GameSpace
  (`persist.sys.mithermal.*`) agora chegam ao daemon com a ROM em enforcing.

Ainda não funciona no AOSPA:

- **Bloquear o print com três dedos**: o AOSPA não tem esse gesto, então não há o
  que bloquear.
- **Perfis do sistema, modo leitura e Smart Pixels** no painel: são da LineageOS.

## mithermald

Base: `IRedDragonICY/mithermald` (main). Lê os sensores térmicos e limita CPU, GPU e
corrente de carga. Usa os perfis que o GameSpace define durante o jogo; fora dele, roda com o perfil padrão.

Ele mexe no carregamento (`input_suspend`, `constant_charge_current_max`). Teste
carregar com o aparelho quente e frio antes de distribuir.

## Créditos

- GameSpace: [IRedDragonICY](https://github.com/IRedDragonICY/GameSpace), baseado no de [chaldeaprjkt](https://github.com/chaldeaprjkt/packages_apps_GameSpace); suporte no framework: crDroid e AxionOS
- Módulos `ax_*` (`sdk/`): AxionOS, via `crdroidandroid/android_vendor_addons` (Apache 2.0)
- AFME: [IRedDragonICY](https://github.com/IRedDragonICY/afme) (Apache 2.0)
- Serviço AxPlatform do SystemUI: AxionOS, via crDroid (Apache 2.0)
- mithermald: [IRedDragonICY](https://github.com/IRedDragonICY/mithermald) (GPL-2.0)
