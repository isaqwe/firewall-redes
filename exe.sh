docker network rm minha_rede_firewall

docker network create minha_rede_firewall

docker rm -f $(docker ps -a -q)

docker build -t meu_servidor_firewall -f dockerfile.firewall .

docker run -d --name meu_servidor_firewall --network minha_rede meu_servidor_firewall