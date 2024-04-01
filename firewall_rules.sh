#!/bin/bash

# Este script contém um conjunto de regras iptables para configurar um firewall.

# Permitir tráfego de loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Definir políticas padrão para descartar pacotes de entrada e encaminhados
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Permitir tráfego HTTP e HTTPS da sub-rede 10.1.1.0/24 para a interface eth2
iptables -A FORWARD -i eth0 -o eth2 -s 10.1.1.0/24 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -s 10.1.1.0/24 -p tcp --dport 443 -j ACCEPT

# Habilitar NAT para a sub-rede 10.1.1.0/24 na interface eth2
iptables -t nat -A POSTROUTING -o eth2 -s 10.1.1.0/24 -j MASQUERADE

# Registrar e descartar qualquer tráfego contendo a string "games"
iptables -A FORWARD -m string --algo bm --string "games" -j LOG --log-prefix "Blocked Games: "
iptables -A FORWARD -m string --algo bm --string "games" -j DROP

# Bloquear tráfego para www.jogosonline.com.br
iptables -A FORWARD -d www.jogosonline.com.br -j DROP

# Permitir tráfego de 10.1.1.100 para www.jogosonline.com.br
iptables -A FORWARD -s 10.1.1.100 -d www.jogosonline.com.br -j ACCEPT

# Limitar solicitações de eco ICMP para 5 por segundo
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s -j ACCEPT

# Permitir tráfego DNS das interfaces eth0 e eth1 para a interface eth2
iptables -A FORWARD -i eth0 -o eth2 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -p udp --dport 53 -j ACCEPT

# Permitir tráfego HTTP de entrada para 192.168.1.100
iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 80 -j ACCEPT

# Redirecionar tráfego HTTP de entrada na interface eth2 para 192.168.1.100
iptables -t nat -A PREROUTING -i eth2 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.100

# Permitir tráfego HTTP de saída de 192.168.1.100
iptables -A FORWARD -p tcp -s 192.168.1.100 --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT
