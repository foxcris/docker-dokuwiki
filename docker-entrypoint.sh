#!/bin/bash

if [ `ls /etc/apache2/sites-available/ | wc -l` -eq 0 ]
then
  cp -r /etc/apache2/sites-available_default/* /etc/apache2/sites-available/
fi

if [ `ls /etc/letsencrypt/ | wc -l` -eq 0 ]
then
  cp -r /etc/letsencrypt_default/* /etc/letsencrypt/
fi

#List site and enable
ls /etc/apache2/sites-available/ -1A | a2ensite *.conf

#Copy alle dokuwiki files and delte oldfiles
cp -rf /var/www/dokuwiki/* /var/www/html
chown -R www-data:www-data /var/www/html
pushd .
cd /var/www/html 
grep -Ev '^($|#)' data/deleted.files | xargs -n 1 rm -vf
popd

#LETSECNRYPT
if [ "$LETSENCRYPTDOMAINS" != "" ]
then
  /usr/sbin/apache2ctl start
  domains=$(echo $LETSENCRYPTDOMAINS | tr "," "\n")
  for domain in $domains
  do
    certbot --apache -n -d $domain --agree-tos --email $LETSENCRYPTEMAIL
  done
  /usr/sbin/apache2ctl stop
fi

#Start Cron
/etc/init.d/anacron start
/etc/init.d/cron start

#Launch Apache on Foreground
/usr/sbin/apache2ctl -D FOREGROUND
