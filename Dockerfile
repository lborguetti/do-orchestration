FROM lborguetti/docker-base-image:stable

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV TERRAFORM_VERSION 0.11.7
ENV EDITOR vim

RUN apt-get -y update && \
	apt-get -y install \
        jq \
        openssh-client \
        python \
        python-pip \
        unzip \
        vim \
        && \
	apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/*

WORKDIR /data

COPY ansible/requirements.txt ansible/requirements.txt

RUN pip install -r ansible/requirements.txt

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/

RUN unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
