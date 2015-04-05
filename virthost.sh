#!/bin/sh

	#parametrs 1 - domain, 2 - port (default 80) 

	if [ $# -eq 0 ];   then
    	echo "No arguments supplied"
    	exit
	fi
	
	VFILE=$1.conf
	DIR=/var/www/$1/public # standart ubuntu directory www projects
	MAIL=ak@argumenti.ru
	INDEX=$DIR/index.html

		
	#correct port
	if [ -z "$2" ];  then
    	PORT=80
    else
    	PORT=$2	
	fi

	#save standart config virtualhost
	sudo sh -c " echo '<VirtualHost *:$PORT>
    	ServerAdmin $MAIL
    	ServerName $1
    	ServerAlias www.$1
    	DocumentRoot $DIR
    	ErrorLog ${APACHE_LOG_DIR}/error.log
    	CustomLog ${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>' > /etc/apache2/sites-available/$VFILE"

	echo "Updated config file $VFILE\n"


	
	# add in apache
	if ! [ -f /etc/apache2/sites-enabled/$VFILE ]; then
		sudo ln -s /etc/apache2/sites-available/$VFILE /etc/apache2/sites-enabled/$VFILE
		echo "Аdd conf to apache $VFILE\n"
	fi 

	
	#  create dir project
	if ! [ -d $DIR ]; then
		sudo mkdir -p $DIR
		sudo chown -R $USER:www-data $DIR
		chmod -R 755 $DIR
		
		
		echo "<html><body><h1>OPEN SITE:$1</h1></body></html>" > $INDEX

	fi

	#add host in localhost
	if ! grep "$1" /etc/hosts; then
		sudo echo "127.0.0.1 $1 www.$1" >> /etc/hosts
		echo "Аdd host $1\n"
	fi	

	sudo /etc/init.d/apache2 reload

	exit





