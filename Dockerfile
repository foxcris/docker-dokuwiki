FROM debian:stretch

MAINTAINER foxcris

#repositories richtig einrichten
RUN echo 'deb http://deb.debian.org/debian stretch main' > /etc/apt/sources.list
RUN echo 'deb http://deb.debian.org/debian stretch-updates main' >> /etc/apt/sources.list
RUN echo 'deb http://security.debian.org stretch/updates main' >> /etc/apt/sources.list
#backports fuer certbot
RUN echo 'deb http://ftp.debian.org/debian stretch-backports main' >> /etc/apt/sources.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales && apt-get clean
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF8
#automatische aktualiserung installieren + basic tools
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y nano less wget anacron unattended-upgrades apt-transport-https htop curl unzip&& apt-get clean

#apache
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 libapache2-mod-php7.0 php-xml && apt-get clean

#certbot
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y python-certbot-apache -t stretch-backports && apt-get clean

ARG DOKUWIKI_VERSION=2018-04-22b
ARG DOKUWIKI_SHA256=9d1437cdc7e98e471ff32079f7ca224ccf52dbbaafed39ec9746b0405b3a29ce
ARG DOKUWIKI_URL=https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz

RUN curl -L -o dokuwiki.tgz ${DOKUWIKI_URL}\
  && echo "${DOKUWIKI_SHA256} dokuwiki.tgz" | sha256sum -c \
  && mkdir -p /var/www/dokuwiki \
  && tar xfz dokuwiki.tgz --directory /var/www/dokuwiki/ \
  && chown -R www-data:www-data /var/www/dokuwiki/ \
  && mv /var/www/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}/* /var/www/dokuwiki/ \
  && rm -r /var/www/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}\
  && rm *.tgz

RUN a2enmod rewrite
RUN a2dissite 000-default
RUN a2dissite default-ssl
RUN mkdir /etc/apache2/sites-available_default
COPY dokuwiki-apache2.conf /etc/apache2/sites-available_default
RUN rm -rf /etc/apache2/sites-available/*

RUN mv /etc/letsencrypt/ /etc/letsencrypt_default
RUN mkdir /etc/letsencrypt/

RUN rm /var/www/html/index.html

VOLUME /var/log/apache2
VOLUME /etc/letsencrypt
VOLUME /var/log/letsencrypt
VOLUME /var/www/html

EXPOSE 80 443
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
