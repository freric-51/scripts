# Network

## Scripts simples para vasculhar o que tenho na rede e corrigir falhas nas conexões.

### O que espero

- Meus computadores ficam sem conexão com a internet do nada, então forço uma reconexão;
- Minha impressora entra em estado de baixa energia e fica dias sem trabalhar;
- Normalmente os celulares ganham um IP diferente a cada conexão pois estão configurados para usar um MAC address aleatório.

### porque colocar em script

- Organização
- Vai que a memória falha :smile:

|Script|Função inicial|
|:-|:-|
|wifi_sets.sh|Reanima minha conexão WIFI que para sozinha. Tenho rodando em todos os meus computadores. Abaixo foi rodado o script em modo teste de funções com e sem o adaptador WIFI habilitado. ![Test Option](https://github.com/freric-51/scripts/blob/main/Network/wifi_sets.png)|
|reinicia_impressoras.sh|reinicio o CUPS|
|find_devices_in_my_net.sh|Um scan pela minha rede do meu laptop|
|vpn.sh|Sequência de comandos para o protonvpn|
|rede.sh|Reinicia o serviço de rede. Ficou sem uso após **wifi_sets.sh** atualizado|
