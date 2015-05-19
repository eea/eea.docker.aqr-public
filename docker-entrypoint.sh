#!/bin/bash
#: File: docker-entrypoint.sh
#: Description: 
#: Imports EuropeanCommission and CommisSign certificates, configures tomcat ECAS Authenticator, deploys the war.
#: 

set -e

BEANS_XML_URL="https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/tomcat/org/apache/catalina/authenticator/mbeans-descriptors.xml"

mkdir -p ${CATALINA_HOME}/lib/org/apache/catalina/authenticator
curl -L "$BEANS_XML_URL" > ${CATALINA_HOME}/lib/org/apache/catalina/authenticator/mbeans-descriptors.xml

AUTHENTICATOR_PROPERTIES_URL="https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/tomcat/org/apache/catalina/startup/Authenticators.properties"
mkdir -p ${CATALINA_HOME}/lib/org/apache/catalina/startup
curl -L "${AUTHENTICATOR_PROPERTIES_URL}" > ${CATALINA_HOME}/lib/org/apache/catalina/startup/Authenticators.properties

ECAS_TOMCAT_JAR_URL="https://github.com/eea/aqr-public/raw/master/ServerConfiguration/ecas/tomcat/ecas-tomcat-5.5-3.6.3.jar"
LOG4J_JAR_URL="https://github.com/eea/aqr-public/raw/master/ServerConfiguration/ecas/tomcat/log4j-1.2.17.jar"
#
# TODO(ezyk) Move all these jar dependencies to maven if possible.
# TODO(ezyk) Move Logging configuration. Logging configuration should be done when we build the war
#
curl -L "${ECAS_TOMCAT_JAR_URL}" > ${CATALINA_HOME}/lib/ecas-tomcat-5.5-3.6.3.jar
curl -L "${LOG4J_JAR_URL}" > ${CATALINA_HOME}/lib/log4j-1.2.17.jar

# Handle logging
LOGGING4J_PROPERTIES_URL="https://github.com/eea/aqr-public/blob/master/ServerConfiguration/log4j/log4j.properties"
curl -L "$LOGGING4J_PROPERTIES_URL" > ${CATALINA_HOME}/lib/log4j.properties

TOMCAT_JULI_ADAPTERS_JAR_URL="https://github.com/eea/aqr-public/raw/master/ServerConfiguration/log4j/tomcat-juli-adapters.jar"
curl -L "${TOMCAT_JULI_ADAPTERS_JAR_URL}" > ${CATALINA_HOME}/lib/tomcat-juli-adapters.jar

TOMCAT_JULI_JAR_URL="https://github.com/eea/aqr-public/raw/master/ServerConfiguration/log4j/tomcat-juli.jar"
curl -L "${TOMCAT_JULI_JAR_URL}" > ${CATALINA_HOME}/lib/tomcat-juli.jar

# Remove logging.properties file from tomcat
rm ${CATALINA_HOME}/conf/logging.properties

#
# Configure tomcat authentication
#
sed -i 's#<Realm className="org.apache.catalina.realm.UserDatabaseRealm"#<Realm className="org.apache.catalina.realm.UserDatabaseRealm" allRolesMode="authOnly"#' $CATALINA_HOME/conf/server.xml



# URL location of the certificates
EUROCOM_CERT_URL="https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/certs/CommisSign.cer"
COMMISSIGN_CERT_URL="https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/certs/EuropeanCommission.cer" 

# Expected SHA1 values for EUROPEANCOMMISSION and COMMISSIGN certificates
EUROCOM_CERT_SHA1_DEFAULT="70a7c70604a20c0fedc704351637efb9ff298b4f"
COMMISSIGN_CERT_SHA1_DEFAULT="b7e343a36e8bfbe5154250c1987f2efc6c396abb"


# If cacert password hasn't changed, set to default value
if [ -z "${KEYSTORE_PASS}" ]; then
	KEYSTORE_PASS="changeit"
fi

# Download certificates
mkdir -p /tmp/certs
curl -L "${EUROCOM_CERT_URL}" > /tmp/certs/CommisSign.cer 
curl -L "${COMMISSIGN_CERT_URL}" >/tmp/certs/EuropeanCommission.cer

# Get the SHA1 from the certificates that we downloaded.
EUROCOM_CERT_SHA1_FROM_FILE=$(sha1sum /tmp/certs/EuropeanCommission.cer | awk '{print $1}')
COMMISSIGN_CERT_SHA1_FROM_FILE=$(sha1sum /tmp/certs/EuropeanCommission.cer | awk '{print $1}')

# Check if the certificates are corrupted or invalid.
if [ "${EUROCOM_CERT_SHA1_FROM_FILE}" = "${EUROCOM_CERT_SHA1_DEFAULT}" ] && [ "${COMMISSIGN_CERT_SHA1_FROM_FILE}" = "${COMMISSIGN_CERT_SHA1_DEFAULT}" ]; then
	printf "Invalid sha1sum for certificates trying to import.\n"
	exit 1
fi

# Import certificates
keytool -import -noprompt -v -keystore cacerts -storepass ${KEYSTORE_PASS} -alias EuropeanCommission -file /tmp/certs/EuropeanCommission.cer
keytool -import -noprompt -v -keystore cacerts -storepass ${KEYSTORE_PASS} -alias CommisSign -file /tmp/certs/CommisSign.cer


# Delete the old Root directory
if [ -d "${CATALINA_HOME}/webapps/ROOT" ]; then
	rm -rf ${CATALINA_HOME}/webapps/ROOT
fi

if [ -n "$CURL_URL" ]; then
	if [ -n "$CURL_USER"] && [ -n "$CURL_PASSWORD" ]; then
		curl -o $WAR_FILEPATH -u "${CURL_USER}:${CURL_PASSWORD}" "$CURL_URL"
	else
		curl -o $WAR_FILEPATH "$CURL_URL"
	fi
	
fi

# Check if war file exists
if [ ! -f "$WAR_FILEPATH" ]; then
	printf "Couldn't find the war file in %s\n" "$WAR_FILEPATH"
	ls -la $WAR_FILEPATH
	exit 1
fi

cp ${WAR_FILEPATH} $CATALINA_HOME/webapps/ROOT.war

# Run tomcat server
${CATALINA_HOME}/bin/catalina.sh run

