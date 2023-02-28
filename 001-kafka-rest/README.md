# Creation of Kafka VM in GCP
- Create a regular Debian 10 VM
- Main guide: https://docs.confluent.io/platform/current/installation/installing_cp/deb-ubuntu.html#systemd-ubuntu-debian-install 
- echo "deb [arch=amd64] https://packages.confluent.io/deb/7.0 stable main" | sudo tee -a /etc/apt/sources.list
- echo "deb https://packages.confluent.io/clients/deb $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list
- sudo apt-get update && sudo apt-get install confluent-platform -y
- sudo systemctl enable confluent-zookeeper; sudo systemctl start confluent-zookeeper
- sudo systemctl enable confluent-server; sudo systemctl start confluent-server
- sudo systemctl enable confluent-kafka-rest; sudo systemctl start confluent-kafka-rest


Kafka Rest - https://docs.confluent.io/platform/current/tutorials/examples/clients/docs/rest-proxy.html

Valores - formatação de dados, validação de erros antes de envio aos tópicos (proteção dos tópicos)
        - controle de negócios (definição de tópicos destino de acordo com cliente)
        - autenticação e rate-limit antes da publicação;

História - envio de saldos a pagar (plano de saúde/reembolsos) - clientes premium pra tópico de prioridade, Carlos para o non-prioridade. (demo curta só isso)