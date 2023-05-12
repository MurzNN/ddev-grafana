#!/bin/bash

# A workaround to make mounted `/var/log` volume writable for supervisord.
sudo chmod 777 /var/log
[ -d /var/log/nginx ] || sudo mkdir /var/log/nginx
sudo chmod 777 /var/log/nginx
[ -d /var/log/apache2 ] || sudo mkdir /var/log/apache2
sudo chmod 777 /var/log/apache2
