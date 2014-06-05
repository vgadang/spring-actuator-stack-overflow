#!/bin/bash
# chkconfig: 345 99 01
# description: Tomcat service

# Source function library.
. /etc/init.d/functions

# Prevent writing core files
ulimit -c 0

# JMX configuration values are in ${CATALINA_BASE}/conf/management.properties

export SERVICE=cmi_eligibility_tomcat
export BASE_DIR=cmi
export CATALINA_BASE=/data/servers/${BASE_DIR}/${SERVICE}
export CATALINA_HOME=${CATALINA_BASE}/tomcat
export JAVA_HOME=${CATALINA_BASE}/java
export CATALINA_PID=${CATALINA_BASE}/conf/${SERVICE}.pid
export CATALINA_GCLOG=${CATALINA_BASE}/logs/${SERVICE}_gc.log
export  CATALINA_OUTLOG=${CATALINA_BASE}/logs/${SERVICE}_out.log
export  CATALINA_LOG=${CATALINA_BASE}/logs/${SERVICE}_catalina.log

export TZ=America/New_York

# Define the Tomcat user.
RUN_USER=quantum
WHO=`whoami`

# Use sudo if we're not $RUN_USER
if [ "$WHO" = "$RUN_USER" ]; then
  SUDO=""
else
  SUDO="sudo -u $RUN_USER"
fi

export JAVA_OPTS="-Dfile.encoding=UTF-8 \
  -Duser.timezone=America/New_York \
  -Dsun.net.inetaddr.ttl=60 \
  -Dsun.net.inetaddr.negative.ttl=60 \
  -Xms512m \
  -Xmx1536m \
  -Xss512k \
  -XX:+UseConcMarkSweepGC \
  -XX:GCTimeRatio=99 \
  -verbose:gc  \
  -Xloggc:$CATALINA_GCLOG \
  -XX:+PrintGCDetails \
  -XX:+PrintGCTimeStamps \
  -XX:MaxGCPauseMillis=20 \
  -XX:MaxNewSize=256m \
  -XX:MaxPermSize=256m \
  -XX:NewSize=256m \
  -XX:PermSize=256m \
  -XX:SurvivorRatio=6 \
  -XX:+HeapDumpOnOutOfMemoryError
"

# Add extra JARs to CLASSPATH.
# These will be loaded with the System class loader.
# http://jakarta.apache-korea.org/tomcat/tomcat-5.0-doc/class-loader-howto.html

# Core Tomcat Classes

CLASSPATH="${CLASSPATH}:${CATALINA_HOME}/bin/bootstrap.jar"
CLASSPATH="${CLASSPATH}:${JAVA_HOME}/lib/tools.jar"
CLASSPATH="${CLASSPATH}:${CATALINA_HOME}/bin/commons-logging-api.jar"
CLASSPATH="${CLASSPATH}:${CATALINA_HOME}/bin/commons-daemon.jar"

time_stamp() {
        TIMESTAMP=`date +"%D %r"`
        echo -n "$TIMESTAMP :- "
        }

start() {

  time_stamp;echo -n "Starting $SERVICE: "

   if [ -e ${CATALINA_OUTLOG} ]; then
        /bin/mv $CATALINA_OUTLOG $CATALINA_OUTLOG.`date +"%s"`
   fi


   if [ -e ${CATALINA_GCLOG} ]; then
        /bin/mv $CATALINA_GCLOG $CATALINA_GCLOG.`date +"%s"`
    fi

   if [ -e ${CATALINA_LOG} ]; then
        /bin/mv $CATALINA_LOG $CATALINA_LOG.`date +"%s"`
    fi

# Set juli LogManager if it is present
  if [ -r "$CATALINA_HOME"/bin/tomcat-juli.jar ]; then
    JAVA_OPTS="$JAVA_OPTS -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
    LOGGING_CONFIG="-Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties"
    CLASSPATH="${CLASSPATH}:${CATALINA_HOME}/bin/tomcat-juli.jar"
  else
    # Bugzilla 45585
    LOGGING_CONFIG="-Dnop"
  fi

  export CLASSPATH
  export JAVA_OPTS

# Start Tomcat using jsvc
        $SUDO ${CATALINA_HOME}/bin/jsvc -user ${RUN_USER}\
                            -home ${JAVA_HOME} \
                            -Dcatalina.home=${CATALINA_HOME} \
                            -Dcatalina.base=${CATALINA_BASE} \
                            -Djava.io.tmpdir=${CATALINA_BASE}/tmp \
                            -wait 60 \
                            -Ddragon.exec.env=qt \
                            -pidfile ${CATALINA_PID} \
                            -cp ${CLASSPATH} \
                            -outfile ${CATALINA_OUTLOG} \
                            -errfile ${CATALINA_OUTLOG} \
                            ${JAVA_OPTS}\
                            ${LOGGING_CONFIG}\
                            org.apache.catalina.startup.Bootstrap \
  && success || failure
   chown -R quantum:gopher $CATALINA_BASE/logs
   chmod -R 775 $CATALINA_BASE/logs

sleep 2
  RETVAL=$?
  echo
  return $RETVAL
}

stop() {
  time_stamp;  echo -n "Stopping $SERVICE: "

#sleep 2

  $SUDO ${CATALINA_HOME}/bin/jsvc -stop -pidfile ${CATALINA_PID} \
                            org.apache.catalina.startup.Bootstrap \
  && success || failure

        time_stamp; echo "Allowing Tomcat to stop... waiting 5 seconds"
                sleep 5
        time_stamp; echo "Checking if Tomcat is still running ......."

        NULLVALUE=`cat /dev/null`
        GPID=`ps -ef | grep $SERVICE | grep java | awk '{print $2}'`

        if [[ $GPID != $NULLVALUE ]]
        then
                time_stamp; echo "Killing Tomcat pid: $GPID"
                ps -ef | grep $SERVICE | grep java | awk '{print $2}' | xargs kill

        else                time_stamp; echo "Stop command shut down Tomcat completely, no need to kill the pid"
        fi


}

cd $CATALINA_BASE
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status $SERVICE
        ;;
    restart)
        stop
        sleep 5
        start
        ;;
    *)
        echo "Usage: $0  [start|stop|restart]"
        exit 1
        ;;
esac
exit $?

