#!/bin/bash
# chkconfig: 345 99 01
# description: Tomcat service rest_template_tomcat
# Deployment procedure:
# 1. Copy
# 2. Unpack
# 3. Restart Tomcat

if [ "$#" -le 0 ]; then
    echo "Usage: $0 hostname1 [hostname2 ...]"
    exit 1
fi

# Base Dir
SERVER_DIR=/data/servers
CMI_BASE_DIR=$SERVER_DIR/cmi
API_TOMCAT_DIR=$CMI_BASE_DIR/cmi_eligibility_tomcat
API_APACHE_DIR=$CMI_BASE_DIR/cmi_api_apache
RUN_USER=quantum
LOGGED_USER=root
WEB_CONTEXT=ROOT

for ARG in "$@"
do
	ssh -t -t $LOGGED_USER@$ARG $API_APACHE_DIR/init.sh stop
	ssh -t -t $LOGGED_USER@$ARG $API_TOMCAT_DIR/init.sh stop
	scp build/libs/*.war $LOGGED_USER@$ARG:$API_TOMCAT_DIR/webapps/$WEB_CONTEXT.war
	ssh -t -t $LOGGED_USER@$ARG rm -rf $API_TOMCAT_DIR/webapps/$WEB_CONTEXT
	ssh -t -t $LOGGED_USER@$ARG sudo -u $RUN_USER unzip -oq $API_TOMCAT_DIR/webapps/$WEB_CONTEXT.war -d $API_TOMCAT_DIR/webapps/$WEB_CONTEXT
	ssh -t -t $LOGGED_USER@$ARG $API_TOMCAT_DIR/init.sh start
	ssh -t -t $LOGGED_USER@$ARG $API_APACHE_DIR/init.sh start
done

