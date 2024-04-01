# Este script é usado para configurar um servidor de firewall usando o Docker.

# Remove a rede Docker existente chamada "minha_rede_firewall"
docker network rm minha_rede_firewall

# Cria uma nova rede Docker chamada "minha_rede_firewall"
docker network create minha_rede_firewall

# Para e remove todos os containers Docker em execução
docker rm -f $(docker ps -a -q)

# Build a Docker image named "meu_servidor_firewall" using the "firewall.dockerfile" file
docker build -t meu_servidor_firewall -f firewall.dockerfile .

# Run a Docker container named "meu_servidor_firewall" in detached mode, connected to the "minha_rede_firewall" network
docker run -d --name meu_servidor_firewall --network minha_rede meu_servidor_firewall