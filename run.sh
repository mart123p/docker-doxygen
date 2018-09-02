#!/bin/sh
echo "Starting Doxygen container"

echo "Checking parameters"

#GIT_REPO
if [ -z "$GIT_REPO" ]; then
	echo "Error: No git repo was specified. Please set the GIT_REPO usign the parameter -e GIT_REPO='git@github.com:mart123p/docker-doxygen.git'" > /dev/stderr
	exit 1
fi
echo "$GIT_REPO" > /var/data/config/git_repo

#API_KEY
if [ -z "$API_KEY" ]; then
	echo
	echo "No api key was specified for the git hook. Will generate one."
	API_KEY=$( < /dev/urandom tr -dc a-z0-9 | head -c${1:-32};echo)
	echo "API_KEY: $API_KEY"
fi
echo $API_KEY > /var/data/config/apikey

#OUT_DIR
if [ -z "$OUT_DIR" ]; then
	OUT_DIR=doxygen_out/html/
fi
echo $OUT_DIR > /var/data/config/out_dir

#SRC_DIR
if [ -z "$SRC_DIR" ]; then
	SRC_DIR=""	
fi
echo $SRC_DIR > /var/data/config/src_dir

#AUTH
if [ -f /etc/nginx/conf.d/default.conf ]; then
	rm /etc/nginx/conf.d/default.conf;
fi
if [ ! -z "$USERNAME" ] && [ ! -z "$PASSWORD" ]; then
	echo "Basic auth enabled"
	cp /etc/nginx/conf.d/default.conf.auth /etc/nginx/conf.d/default.conf
	htpasswd -b -c /var/data/config/.htpasswd "$USERNAME" "$PASSWORD"
else
	cp /etc/nginx/conf.d/default.conf.noauth /etc/nginx/conf.d/default.conf
fi

echo "Parameters checked"
usermod -aG tty nginx
chown -R nginx:nginx /var/data/config/
if [ ! -f /var/data/config/id_rsa.pub ] || [ ! -f /var/data/config/id_rsa ]; then
	echo
	echo "No SSH key found will generate a new ssh key"
	ssh-keygen -t rsa -P "" -q -C "DockerDoxygen generated $(date)" -f /var/data/config/id_rsa
	echo "SSH key was generated!"
fi


echo 
echo "Starting FastCGI"
chown -R nginx:nginx /var/run/fcgiwrap/
su nginx -s /bin/sh -c "/usr/bin/fcgiwrap -s unix:/var/run/fcgiwrap/fcgiwrap.sock"&
echo "FastCGI started"


mkdir -p /run/nginx/
touch /run/nginx/nginx.pid 
echo "Nginx started"
echo
echo "--Nginx Logs--"
/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
