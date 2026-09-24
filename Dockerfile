FROM tomcat:6

# 1. Create directory structures
RUN mkdir -p ${CATALINA_HOME}/lib/org/apache/catalina/authenticator \
    && mkdir -p ${CATALINA_HOME}/lib/org/apache/catalina/startup

# 2. Download static configurations and JARs
ADD https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/tomcat/org/apache/catalina/authenticator/mbeans-descriptors.xml ${CATALINA_HOME}/lib/org/apache/catalina/authenticator/mbeans-descriptors.xml
ADD https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/tomcat/org/apache/catalina/startup/Authenticators.properties ${CATALINA_HOME}/lib/org/apache/catalina/startup/Authenticators.properties
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/ecas/tomcat/ecas-tomcat-5.5-3.6.3.jar ${CATALINA_HOME}/lib/ecas-tomcat-5.5-3.6.3.jar
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/ecas/tomcat/log4j-1.2.17.jar ${CATALINA_HOME}/lib/log4j-1.2.17.jar
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/log4j/tomcat-juli-adapters.jar ${CATALINA_HOME}/lib/tomcat-juli-adapters.jar
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/log4j/tomcat-juli.jar ${CATALINA_HOME}/lib/tomcat-juli.jar
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/log4j/log4j.properties ${CATALINA_HOME}/lib/log4j.properties

# 3. Perform server configuration tweaks
RUN rm -f ${CATALINA_HOME}/conf/logging.properties
COPY server.xml ${CATALINA_HOME}/conf/server.xml

# 4. Handle the application WAR file (the produced aqrsystem.war must exist in the current directory)
ENV WAR_FILEPATH=/tmp/ROOT.war
COPY aqrsystem.war ${WAR_FILEPATH}

# 5. Final setup
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
