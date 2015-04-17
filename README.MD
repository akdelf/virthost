Quick add standart virtual host for apache
===

virthost.sh [domain] [port] [user]

EXAMPLE: add host website.dev

cd ~/scripts/virthost

sh virthost.sh website.dev


RESULT:

1. Аdd file /etc/apache2/sites-available/website.dev.conf
2. Аdd website.dev and www.website.dev to /etc/hosts
3. Сreate folder /var/www/website.dev in permission current user
4. Reload apache
5. Working pages http://website.dev/index.html and  http://www.website.dev/index.html


MORE EXAMPLES:

sh virthost.sh website.dev 8080 #apache port 8080

sh virthost.sh website.dev 80 webmaster # user folder webmaster 







