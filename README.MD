Quick add virtual host for apache
===

EXAMPLE: add host website.dev

cd ~/utilites/virthost
sh virthost.sh website.dev


RESULT:

1. Аdd file /etc/apache2/sites-available/website.dev.conf
2. Аdd website.dev www.website.dev -> /etc/hosts
3. Сreate folder /var/www/website.dev -> permission curruser
4. Reload apache
5. Work pages http://website.dev/index.html and  http://www.website.dev/index.html




