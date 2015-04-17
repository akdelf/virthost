#!/bin/sh

	#parametrs 1 - domain, 2 - port (default 80), 3 - user 

	if [ $# -eq 0 ];   then
    	echo "No arguments supplied"
    	exit
	fi
	
	VFILE=$1.conf
	DIR=/var/www/$1 # standart ubuntu directory www projects
	PUBDIR=$DIR/public
	INDEX=$PUBDIR/index.html

		
	#correct port
	if [ -z "$2" ];  then
    	PORT=80
    else
    	PORT=$2	
	fi

	
	#user host
	if [ -z "$3" ];  then
    	CUSER=www-data
    else
    	CUSER=$3
    fi

    #save standart apache virtualhost
	sudo sh -c " echo '<VirtualHost *:$PORT>
    	ServerName $1
    	ServerAlias www.$1
    	DocumentRoot $PUBDIR
    	ErrorLog ${APACHE_LOG_DIR}/error.log
    	CustomLog ${APACHE_LOG_DIR}/access.log combined
    	 <Directory \"$PUBDIR\">
            AllowOverride All
            Options +Indexes
            DirectoryIndex index.php index.html
        </Directory>
	</VirtualHost>' > /etc/apache2/sites-available/$VFILE"

	echo "Updated config file $VFILE\n"


	
	# add in apache
	if ! [ -f /etc/apache2/sites-enabled/$VFILE ]; then
		sudo ln -s /etc/apache2/sites-available/$VFILE /etc/apache2/sites-enabled/$VFILE
		echo "Аdd conf to apache $VFILE\n"
	fi 

	
	#  create dir project
	if ! [ -d $DIR ]; then
		sudo mkdir -p $PUBDIR
		sudo chmod -R 755 $DIR
		sudo chown -R $CUSER:www-data $DIR
		
		echo "<html><body><h1>OPEN SITE:$1</h1></body></html>" > $INDEX

	fi

	#add host in localhost
	if ! grep "$1" /etc/hosts; then
		sudo echo "127.0.0.1 $1 www.$1" >> /etc/hosts
		echo "Аdd host $1\n"
	fi	

	sudo /etc/init.d/apache2 reload

	exit





