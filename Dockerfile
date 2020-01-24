FROM ubuntu:latest

LABEL maintainer="team@element6.dev"
LABEL version="1.0"
LABEL description="Fucking working bench container"

# Install dependencies 
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
    git \
    sudo \
    locales \
    python3-dev \
    python3-setuptools \
    python3-pip \
    curl \
    apt-utils \
    redis-server \
    libmysqlclient-dev \
    cron \
    fontconfig \
    libxrender1 \
    libfontenc1 \
    xfonts-utils \
    x11-common \
    xfonts-encodings \
    xfonts-75dpi \
    xfonts-base \
    wget \
    libjpeg-turbo8 \
    mysql-client

# Install wkhtmktopdf    
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
RUN dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb && rm wkhtmltox_0.12.5-1.bionic_amd64.deb

# Set locales
RUN sed -i -e 's/# C.UTF-8 UTF-8/C.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LC_ALL=C.UTF-8 \
    LC_CTYPE=C.UTF-8 \
    LANG=C.UTF-8

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
RUN apt-get install nodejs -y
RUN npm install -g yarn

# add users without sudo password
ENV systemUser=frappe

RUN adduser --disabled-password --gecos "" $systemUser \
    && usermod -aG sudo $systemUser \
    && echo "%sudo  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/sudoers

# set user and workdir
USER $systemUser
WORKDIR /home/$systemUser

# Install Bench 
RUN git clone https://github.com/frappe/bench
RUN sudo pip3 install -e ./bench

# Install frappe
ENV frappeBranch=version-12
RUN bench init --frappe-branch $frappeBranch frappe-bench
RUN pip3 install -e ./frappe-bench/apps/frappe/

