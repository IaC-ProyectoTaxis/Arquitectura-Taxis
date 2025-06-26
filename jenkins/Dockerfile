FROM jenkins/jenkins:lts

USER root


COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

RUN chmod +x /usr/local/bin/install-plugins.sh && \
    /usr/local/bin/install-plugins.sh

# Instalacion Terraform en jenkins
RUN apt-get update && apt-get install -y wget unzip && \
    wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip && \
    unzip terraform_1.6.6_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    terraform --version