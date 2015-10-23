#!/bin/bash
#: File: docker-entrypoint.sh
#: Description:
#:
#:

set -e
# Check if file was mounted using the volumes. If not download from Jenkins
if [ ! -f /mnt/aqrsystem.war ]; then
    wget -O "/mnt/aqrsystem.war" "$JENKINS_URL"
fi
if [ ! -d "${DOCKER_DEPLOYMENT_DIR}" ]; then
    mkdir -p ${DOCKER_DEPLOYMENT_DIR}
    # /mnt/docker/aqrsystem.war is treated as readonly, so we interact only with the copy
    cp /mnt/aqrsystem.war ${DOCKER_DEPLOYMENT_DIR}
    cd ${DOCKER_DEPLOYMENT_DIR}
    # Unpack war file so that we can modify properties values before tomcat caches the resources
    jar -xvf aqrsystem.war
    # remove war file
    rm -rf aqrsystem.war
    # create deployment descriptor
    if [ ! -f ${CATALINA_HOME}/conf/Catalina/localhost/ROOT.xml ]; then
        mkdir -p ${CATALINA_HOME}/conf/Catalina/localhost
        cat <<EOF > ${CATALINA_HOME}/conf/Catalina/localhost/ROOT.xml
<?xml version='1.0' encoding='utf-8'?>
<Context docBase="${DOCKER_DEPLOYMENT_DIR}" path="/" />
EOF
    fi

		# update ecas-config from environment variables
		update-ecas-config.py
		update-db-credentials.py
fi

# If no command is provided, run tomcat
if [ "$#" -eq 0 ]; then
    catalina.sh run
else
    exec "$@"
fi
