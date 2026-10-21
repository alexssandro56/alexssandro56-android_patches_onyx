# onyx-extras

Extras para o AOSPA (Android 17) no POCO F7 (`onyx`), mantidos fora do device tree:

- **GameSpace**: painel de jogos do crDroid 17.0, com o suporte no framework portado para o AOSPA.
- **mithermald**: daemon térmico open source (Rust) do IRedDragonICY, no lugar do `mi_thermald` da Xiaomi.

## Estrutura

| Caminho | O que é |
| --- | --- |
| `local_manifests/onyx_extras.xml` | Baixa este repositório em `vendor/onyx-extras`, o GameSpace em `packages/apps/GameSpace` e o mithermald em `external/mithermald` |
| `vendorsetup.sh` | Aplica os patches de `patches/` em todo `source build/envsetup.sh` |
| `patches/frameworks/base/` | Suporte ao GameSpace no `system_server` e no SystemUI |
| `patches/packages/apps/GameSpace/` | Remove a dependência do SDK da LineageOS, que o AOSPA não tem |
| `sdk/` | Módulos `ax_*` e as bibliotecas Compose pré-compiladas que o GameSpace usa |
| `mithermald/sepolicy/` | Política SELinux do `mi_thermal_engine` (a ROM é enforcing) |
| `onyx_extras.mk`, `BoardConfigExtras.mk` | O que o device tree inclui |
| `device/` | Patch para o device tree incluir tudo isso e parar o `mi_thermald` stock |

## Como usar

1. Copie o manifest e sincronize:
   ```
   mkdir -p .repo/local_manifests
   cp vendor/onyx-extras/local_manifests/onyx_extras.xml .repo/local_manifests/
   repo sync -c --no-tags vendor/onyx-extras packages/apps/GameSpace external/mithermald
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

Base: `crdroidandroid/android_packages_apps_GameSpace` (17.0) e três commits do
`crdroidandroid/android_frameworks_base` (17.0):

- `5c0bee650d4` core: adding support for game space
- `2133c5519ab` services: Treat gamespace apps as games
- `cd8470b5b68` services: Add toggle for gamespace auto detect apps

Diferenças em relação ao crDroid:

- **Bypass de carregamento** removido: depende do `HealthInterface` do SDK da LineageOS.
- **Desativar o print com três dedos durante o jogo** não faz nada: é uma configuração da LineageOS.
- **Atalhos da barra lateral** que usam o `AxPlatformClient` (gravação de tela e alguns
  toggles rápidos) ficam indisponíveis: dependem de um serviço que só existe no SystemUI do crDroid.

## mithermald

Base: `IRedDragonICY/mithermald` (main). Lê os sensores térmicos e limita CPU, GPU e
corrente de carga. Sem o GameSpace do IRedDragonICY, roda com o perfil padrão.

Ele mexe no carregamento (`input_suspend`, `constant_charge_current_max`). Teste
carregar com o aparelho quente e frio antes de distribuir.

## Créditos

- GameSpace: [chaldeaprjkt](https://github.com/chaldeaprjkt/packages_apps_GameSpace), crDroid, AxionOS
- Módulos `ax_*` (`sdk/`): AxionOS, via `crdroidandroid/android_vendor_addons` (Apache 2.0)
- mithermald: [IRedDragonICY](https://github.com/IRedDragonICY/mithermald) (GPL-2.0)
