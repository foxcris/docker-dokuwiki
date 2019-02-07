# docker-dokuwiki

A simple apache installation with all required modules to run dokuwki. Main Features:
 * automatic creation and renew of letsencrypt certificates
 * automatic activation of all available site configuration
 
## Apache Modules
The following apache modules are activated:
 * rewrite
 
## Configuration
 
### Configuration files, log files, buisness data
The following directories can be loaded from the host to keep the data and configuration files out of the container:

 | PATH in container | Description | 
 | ---------------------- | ----------- |
 | /etc/letsencrypt | Storage of the created let's encrypt certificates |
 | /var/www/html | Dokuwiki installation with alls its data | 
 
### Environment variables
The following environment variables are available to configure the container on startup.

 | Environment Variable | Description |
 | ---------------------- | ----------- |
 | LETSENCRYPTDOMAINS | Comma seperated list of all domainnames to request/renew a let's encrypt certificate | 
 | LETSENCRYPTEMAIL | E-Mail to be used for notifications from let's encrypt |

## Container Tags
 | Tag name | Description |
 | ---------------------- | ----------- |
 | latest | Latest stable version of the container |
 | stable | Latest stable version of the container |
 | dev | latest development version  of the container. Do not use in production environments! |

## Usage
To run the container and store the data and configuration on the local host run the following commands: 

1. Create storage directroy for the configuration files, log files and data. Also create a directroy to store the necessary script to create the docker container and replace it (if not using eg. watchtower) 
``` 
mkdir /srv/docker/dokuwiki
mkdir /srv/docker-config/dokuwiki 
``` 

3. Create an file to store the configuration of the environment variables 
``` 
touch /srv/docker-config/apacheproxy/env_file 
``` 

```
#Comma seperated list of domainnames
LETSENCRYPTDOMAINS=dokuwiki.example.com
LETSENCRYPTEMAIL=example@example.com 
``` 

3. Create the docker container and configure the docker networks for the container. I always create a script for that and store it under 
``` 
touch /srv/docker-config/dokuwiki/create.sh 
``` 

Content of create.sh: 
```
#!/bin/bash

#docker pull foxcris/docker-dokuwiki
docker create --restart always\
  --env-file ./env_file\
  --name dokuwiki \
  -v /srv/docker/dokuwiki/var/www/html:/var/www/html\
  -v /srv/docker/dokuwiki/var/log/letsencrpyt:/var/log/letsencrypt\
  -v /srv/docker/dokuwiki/var/log/apache2:/var/log/apache2\
  -v /srv/docker/dokuwiki/etc/letsencrypt:/etc/letsencrypt\
  -p 80:80\
  -p 443:443\
  foxcris/docker-dokuwiki
```
`
4. Create replace.sh to install/update the container. Store it in 
``` 
touch /srv/docker-config/apacheproxy/replace.sh 
``` 

```
#/bin/bash
docker stop dokuwwiki 
docker rm dokuwiki 
./create.sh 
docker start dokuwiki
``` 

During startup you old dokuwiki installation ist updated with the new version.
