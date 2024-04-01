## Firewall IPTABLES - Lista de Exercícios

Elabore as regras necessárias para implementar os seguintes controles. Utilize para isso as
regras do firewall Linux (netfilter/iptables).

1. Libere qualquer tráfego para interface de loopback no firewall.

2. Estabeleça a política DROP (restritiva) para as chains INPUT e FORWARD da tabela filter.

3. Possibilite que usuários da rede interna possam acessar o serviço WWW, tanto na porta (TCP) 80 como na 443. Não esqueça de realizar NAT já que os usuários internos não possuem um endereço IP válido.

4. Faça LOG e bloqueie o acesso a qualquer site que contenha a palavra “games”.

5. Bloqueie acesso para qualquer usuário ao site www.jogosonline.com.br, exceto para seu chefe, que possui o endereço IP 10.1.1.100.

6. Permita que o firewall receba pacotes do tipo ICMP echo-request (ping), porém, limite a 5 pacotes por segundo.

7. Permita que tanto a rede interna como a DMZ possam realizar consultas ao DNS externo, bem como, receber os resultados das mesmas.

8. Permita o tráfego TCP destinado à máquina 192.168.1.100 (DMZ) na porta 80, vindo de qualquer rede (Interna ou Externa).

9. Redirecione pacotes TCP destinados ao IP 200.20.5.1 porta 80, para a máquina 192.168.1.100 que está localizado na DMZ.

10. Faça com que a máquina 192.168.1.100 consiga responder os pacotes TCP recebidos na porta 80 corretamente.

Preste atenção, os serviços do tipo cliente x servidor, dependem de pacotes de respostas, sendo assim,
é necessário criar regras que aceitem os pacotes de respostas. Você pode também utilizar o módulo
state para realizar esta tarefa.

## Descrição dos Arquivos

### exe.sh

Este script Bash é usado para configurar um servidor de firewall usando o Docker.

#### Descrição das linhas

- `docker network rm minha_rede_firewall`: Esta linha remove a rede Docker existente chamada "minha_rede_firewall".

- `docker network create minha_rede_firewall`: Esta linha cria uma nova rede Docker chamada "minha_rede_firewall".

- `docker rm -f $(docker ps -a -q)`: Esta linha para e remove todos os containers Docker em execução.

- `docker build -t meu_servidor_firewall -f firewall.dockerfile .`: Esta linha constrói uma imagem Docker chamada "meu_servidor_firewall" usando o arquivo "firewall.dockerfile".

- `docker run -d --name meu_servidor_firewall --network minha_rede_firewall meu_servidor_firewall`: Esta linha executa um container Docker chamado "meu_servidor_firewall" em modo desanexado, conectado à rede "minha_rede_firewall".

### firewall.dockerfile

Este Dockerfile configura um contêiner Ubuntu básico com capacidades de firewall. Aqui está uma descrição do que cada linha faz:

- `FROM ubuntu:latest`: Esta linha puxa a versão mais recente da imagem Ubuntu do Docker Hub.

- `RUN apt-get update && apt-get install -y iptables && apt-get install -y dnsutils && apt-get install -y net-tools && apt install -y telnet`: Este comando atualiza as listas de pacotes para upgrades e novas instalações de pacotes. Em seguida, instala `iptables` (um programa utilitário do espaço do usuário que permite a um administrador de sistema configurar as regras de filtro de pacotes IP do firewall do kernel Linux), `dnsutils` (para consultas DNS), `net-tools` (para configuração de rede e protocolo de internet) e `telnet` (para comunicação interativa com outro host usando o protocolo TELNET).

- `COPY ./firewall_rules.sh /root/firewall_rules.sh`: Esta linha copia o script `firewall_rules.sh` do seu contexto Docker e o coloca no diretório `/root` do contêiner.

- `RUN chmod 755 /root/firewall_rules.sh`: Este comando altera as permissões do script `firewall_rules.sh` para torná-lo executável.

- `CMD ["/bin/bash", "-c", "/root/firewall_rules.sh; sleep infinity"]`: Esta linha é o comando que o Docker executa quando o contêiner é iniciado. Ele executa o script `firewall_rules.sh` e, em seguida, coloca o contêiner para dormir indefinidamente. Isso é feito para que o contêiner não pare após a execução do script.

### firewall_rules.sh

Este script Bash configura um conjunto de regras de firewall usando o `iptables`.

#### Descrição das regras

- `iptables -A INPUT -i lo -j ACCEPT` e `iptables -A OUTPUT -o lo -j ACCEPT`: Estas linhas permitem todo o tráfego na interface de loopback.

- `iptables -P INPUT DROP` e `iptables -P FORWARD DROP`: Estas linhas definem as políticas padrão para descartar pacotes de entrada e encaminhados.

- `iptables -A FORWARD -i eth0 -o eth2 -s 10.1.1.0/24 -p tcp --dport 80 -j ACCEPT` e `iptables -A FORWARD -i eth0 -o eth2 -s 10.1.1.0/24 -p tcp --dport 443 -j ACCEPT`: Estas linhas permitem o tráfego HTTP e HTTPS da sub-rede 10.1.1.0/24 para a interface eth2.

- `iptables -t nat -A POSTROUTING -o eth2 -s 10.1.1.0/24 -j MASQUERADE`: Esta linha habilita NAT para a sub-rede 10.1.1.0/24 na interface eth2.

- `iptables -A FORWARD -m string --algo bm --string "games" -j LOG --log-prefix "Blocked Games: "` e `iptables -A FORWARD -m string --algo bm --string "games" -j DROP`: Estas linhas registram e descartam qualquer tráfego contendo a string "games".

- `iptables -A FORWARD -d www.jogosonline.com.br -j DROP` e `iptables -A FORWARD -s 10.1.1.100 -d www.jogosonline.com.br -j ACCEPT`: Estas linhas bloqueiam o tráfego para www.jogosonline.com.br, exceto o tráfego originado de 10.1.1.100.

- `iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s -j ACCEPT`: Esta linha limita as solicitações de eco ICMP para 5 por segundo.

- `iptables -A FORWARD -i eth0 -o eth2 -p udp --dport 53 -j ACCEPT` e `iptables -A FORWARD -i eth1 -o eth2 -p udp --dport 53 -j ACCEPT`: Estas linhas permitem o tráfego DNS das interfaces eth0 e eth1 para a interface eth2.

- `iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 80 -j ACCEPT`: Esta linha permite o tráfego HTTP de entrada para 192.168.1.100.

## Testes

Esta seção descreve como testar as regras de firewall configuradas pelo script `firewall_rules.sh`.

- `docker exec -it --privileged meu_servidor_firewall /bin/bash`: Este comando permite que você acesse o container Docker chamado "meu_servidor_firewall" com privilégios de superusuário.

- `iptables -L`: Este comando lista todas as regras de firewall atuais.

- `iptables -t nat -L`: Este comando lista todas as regras de NAT atuais.

- `iptables -t mangle -L`: Este comando lista todas as regras de mangle atuais. As regras de mangle são usadas para alterar os cabeçalhos dos pacotes IP.

- `iptables -t raw -L`: Este comando lista todas as regras raw atuais. As regras raw são usadas para configurar exceções às regras de rastreamento de conexões.

- `iptables -t security -L`: Este comando lista todas as regras de segurança atuais. As regras de segurança são usadas para configurar políticas de segurança para o tráfego de rede.

#
**Isaque Pontes Romualdo, 5º Sistemas de Informação - Serviços de Redes de Computadores**