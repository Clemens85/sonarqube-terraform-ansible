FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install curl unzip ssh apt-transport-https gnupg software-properties-common jq sudo
RUN apt-get -y install gcc python3 python3-pip rsync

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

RUN apt-get -y update && apt-get -y install terraform

RUN pip3 install --upgrade pip; \
    pip3 install --upgrade virtualenv; \
    pip3 install pywinrm[kerberos]; \
    pip3 install pywinrm; \
    pip3 install jmspath; \
    pip3 install requests; \
    python3 -m pip install ansible; \
    wget -q https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt; \
    pip3 install -r requirements-azure.txt; \
    rm requirements-azure.txt; \
    ansible-galaxy collection install azure.azcollection

RUN useradd --shell /bin/bash --groups sudo --create-home provisioning
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN touch /home/provisioning/.sudo_as_admin_successful

RUN mkdir /home/provisioning/.ssh && chown provisioning:provisioning /home/provisioning/.ssh && chmod 700 /home/provisioning/.ssh

COPY entrypoint.sh /home/provisioning/entrypoint.sh
RUN chown provisioning:provisioning /home/provisioning/entrypoint.sh
RUN chmod +x /home/provisioning/entrypoint.sh

USER provisioning
CMD /home/provisioning/entrypoint.sh


