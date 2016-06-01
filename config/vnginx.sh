$vconfig="

server {
    	listen $NGINXPORT default_server;
    	listen [::]:$NGINXPORT default_server;

    	root $PUBDIR;
    	index index.php index.html;

    	server_name $1;

    	location / {
        	try_files $uri $uri/ =404;
    	}

    	location ~ \.php$ {
        	include snippets/fastcgi-php.conf;
        	fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    	}

    	location ~ /\.ht {
        	deny all;
    	}
	}"