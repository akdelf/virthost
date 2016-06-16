#!/bin/sh

	#parametrs 1 - domain 2 - ip 3 - user

	if [ $# -eq 0 ];   then
    	echo "No arguments supplied"
    	exit
	fi

	source config_default

	VFILE=$1.conf # config file
	DIR=$WWWDIR$1 # standart ubuntu directory www projects
	PUBDIR=$DIR/$SUBDIR
	INDEX="$PUBDIR/index"

    #ip
    if [ -z "$2" ]; then
        ip="127.0.0.1"
    else
        ip=$2     
    fi  

   #user host
	if [ -z "$CUSER" ];  then
    	if [ -z "$3" ]; then
            CUSER=$1
        else
            CUSER=$3        
        fi    
    fi

    ApacheThread=`ps -A|grep apache2|wc -l`
    NginxThread=`ps -A|grep nginx|wc -l`

    if [ $NginxThread > 0 ]
    	then

    	if [ -d /etc/nginx/sites-available ]; then
    		vdir=/etc/nginx/sites-available
    	elif [ -d /etc/nginx/conf.d ]; then	
    		vdir=/etc/nginx/conf.d
    	else
    	    exit;
    	fi    	
    	
    	echo -e "add file $vdir/$VFILE ..." >&2
    	sh -c " echo '
    server {
    	listen $NGINXPORT;
    	listen [::]:$NGINXPORT;
    	    	
    	root $PUBDIR;
    	index index.php index.html;

    	server_name $1;
    	charset utf8;
       	
       	error_page 404 /404.html;
    	error_page 500 502 503 504 /50x.html;
    	
    	location = /50x.html {
        	root /usr/share/nginx/html;
    	}

    	## Statics

    	location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt|pdf)$ {
        	access_log        off;
        	expires           max;
    	}

    	## PHP
    	location / {	
            try_files $uri $uri/ /index.php?q=$uri&$args;
    	}	
    	

    	location ~ \.php$ {
        	include snippets/fastcgi-php.conf;
        	fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    	}

    	## Security

    	location ~ /\.ht {
        	deny all;
    	}

       	location ~* /(.git|cache|bin|logs|backups|tests)/.*$ {
    	 	return 403; 
    	}

    	location ~* /(system|vendor)/.*\.(txt|xml|md|html|yaml|php|pl|py|cgi|twig|sh|bat)$ { 
    		return 403;
    	}

    	location ~ /(LICENSE.txt|composer.lock|composer.json) { 
    		return 403;
    	}

    	## Wordpress config
    	location ~* wp-config.php {
			deny all;
		}


	}'> $vdir/$VFILE"

		if ! [ -f /etc/nginx/sites-enabled/$VFILE ]; then
			echo -e "enabled $VFILE ..." >&2
			ln -s /etc/nginx/sites-available/$VFILE /etc/nginx/sites-enabled/$VFILE
		fi	

		if  [ -f /etc/nginx/sites-enabled/default ]; then
			echo -e "disable default config ..." >&2
			unlink /etc/nginx/sites-enabled/default
		fi	


		echo -e "reload nginx ..." >&2
		#systemctl reload nginx
        service nginx reload        


	   
    elif [ $NginxThread -eq 0 ]
    	then

    	sudo sh -c " echo '<VirtualHost *:APACHEPORT>
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

		# add in apache
		if ! [ -f /etc/apache2/sites-enabled/$VFILE ]; then
			ln -s /etc/apache2/sites-available/$VFILE /etc/apache2/sites-enabled/$VFILE
			echo "Аdd conf to apache $VFILE\n"
		fi	

		echo -e "restart apache ..." >&2
		#systemctl reload apache
        service apache reload	


    fi
   	

	echo -e "init user ..." >&2
    grep "$CUSER" /etc/passwd >/dev/null
    if [ $? -ne 0 ]; then
        useradd -d $DIR $CUSER
    fi


    #  create dir project
	if ! [ -d $PUBDIR ]; then
		echo -e "create directory $PUBDIR ..." >&2
		sudo mkdir -p $PUBDIR
		
		echo -e "create test page index.html && index.php ..." >&2
		sudo sh -c "echo '<html><body><h1>OPEN SITE:$1</h1></body></html>' > $INDEX.html"
		sudo sh -c "echo '<?php phpinfo();' > $INDEX.php"

		

        echo -e "cmod $PUBDIR ..." >&2
		sudo chown -R $CUSER:$CUSER $DIR
		sudo chgrp -R $CUSER $DIR
		sudo chmod -R g+rwx $DIR # читать редактировать создавать
	else
        echo "Folder no empty ..." >&2

    fi

	#add host in localhost
	if ! grep "$1" /etc/hosts; then
		echo "Аdd host $1 ..." >&2
		sudo sh -c "echo '$ip $1 www.$1' >>  /etc/hosts"
	fi


	exit
