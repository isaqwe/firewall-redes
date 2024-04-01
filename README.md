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

## Testes

- FIREWALL:
