#!/bin/bash

echo "fix-log-directory-permissions.sh start";

# A workaround to make mounted `/var/log` volume writable for supervisord.
sudo chmod 777 /var/log
[ -d /var/log/nginx ] || sudo mkdir /var/log/nginx
sudo chmod 777 /var/log/nginx
[ -d /var/log/apache2 ] || sudo mkdir /var/log/apache2
sudo chmod 777 /var/log/apache2

ls -la /var
ls -la /var/log

echo "fix-log-directory-permissions.sh end";
