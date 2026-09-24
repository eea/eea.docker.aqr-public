#!/bin/bash
set -e

# Delete default Root directory if present
if [ -d "${CATALINA_HOME}/webapps/ROOT" ]; then
    rm -rf ${CATALINA_HOME}/webapps/ROOT
fi

# Ensure the war file is in place
if [ ! -f "$WAR_FILEPATH" ]; then
    printf "Critical Error: Found no application war file at %s\n" "$WAR_FILEPATH"
    exit 1
fi

cp "${WAR_FILEPATH}" "${CATALINA_HOME}/webapps/ROOT.war"

# Execute tomcat
exec ${CATALINA_HOME}/bin/catalina.sh run