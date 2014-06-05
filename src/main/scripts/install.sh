
if [ "$#" -le 0 ]; then
    echo "Usage: $0 hostname1 [hostname2]"
    exit 1
fi


# Base Dir
SERVER_DIR=/data/servers
CMI_BASE_DIR=$SERVER_DIR/cmi
API_TOMCAT_DIR=$CMI_BASE_DIR/cmi_eligibility_tomcat
RUN_USER=quantum
RUN_GROUP=gopher
LOGGED_USER=root

for ARG in "$@"
do
	## Create all dirs
	ssh -t -t $LOGGED_USER@$ARG mkdir $API_TOMCAT_DIR

	## Tomcat
	ssh -t -t $LOGGED_USER@$ARG mkdir $API_TOMCAT_DIR/logs $API_TOMCAT_DIR/tmp $API_TOMCAT_DIR/webapps $API_TOMCAT_DIR/work
	ssh -t -t $LOGGED_USER@$ARG ln -fs /opt/bcs/packages/tomcat7 $API_TOMCAT_DIR/tomcat
	ssh -t -t $LOGGED_USER@$ARG ln -fs /opt/bcs/packages/jdk7 $API_TOMCAT_DIR/java
	
	# init.sh
	scp src/main/scripts/tomcat/init.sh $LOGGED_USER@$ARG:$API_TOMCAT_DIR
	ssh -t -t $LOGGED_USER@$ARG chmod +x $API_TOMCAT_DIR/init.sh
	
	# conf files
	scp -r src/main/scripts/tomcat/conf $LOGGED_USER@$ARG:$API_TOMCAT_DIR

	# _ns_ files
	scp -r src/main/scripts/tomcat/_ns_ $LOGGED_USER@$ARG:$API_TOMCAT_DIR/webapps

	# Change owner & user
	ssh -t -t $LOGGED_USER@$ARG chown -R $RUN_USER $CMI_BASE_DIR
	ssh -t -t $LOGGED_USER@$ARG chgrp -R $RUN_GROUP $CMI_BASE_DIR
	
done
