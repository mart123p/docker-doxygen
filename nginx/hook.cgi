#!/bin/sh
echo "Content-type: text/plain; charset=UTF-8"
#We check if we can access the cgi script
API_KEY="key=$(cat /var/data/config/apikey)"
if [[ "$QUERY_STRING" != "$API_KEY" ]]; then
	echo "Status: 403 Forbidden"
	echo 
	echo "403 Forbidden"
	exit
fi
echo

echo "Git Hook | $(date)"
echo 
echo "Launching new task..."
if [ ! -f /var/run/hook/hook.lock ]; then
	touch /var/run/hook/hook.lock
	(gen-doxygen)&
	echo "New task launched!"
	exit
else
	echo "Error: A task is already in execution."
fi
