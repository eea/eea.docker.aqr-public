FROM tomcat:6

# 1. Create directory structures
RUN mkdir -p ${CATALINA_HOME}/lib/org/apache/catalina/authenticator \
    && mkdir -p ${CATALINA_HOME}/lib/org/apache/catalina/startup \
    && mkdir -p /tmp/certs

# 2. Download static configurations and JARs
ADD https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/tomcat/org/apache/catalina/authenticator/mbeans-descriptors.xml ${CATALINA_HOME}/lib/org/apache/catalina/authenticator/mbeans-descriptors.xml
ADD https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/tomcat/org/apache/catalina/startup/Authenticators.properties ${CATALINA_HOME}/lib/org/apache/catalina/startup/Authenticators.properties
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/ecas/tomcat/ecas-tomcat-5.5-3.6.3.jar ${CATALINA_HOME}/lib/ecas-tomcat-5.5-3.6.3.jar
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/ecas/tomcat/log4j-1.2.17.jar ${CATALINA_HOME}/lib/log4j-1.2.17.jar
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/log4j/tomcat-juli-adapters.jar ${CATALINA_HOME}/lib/tomcat-juli-adapters.jar
ADD https://github.com ${CATALINA_HOME}/lib/tomcat-juli.jar
ADD https://github.com/eea/aqr-public/raw/master/ServerConfiguration/log4j/tomcat-juli.jar ${CATALINA_HOME}/lib/log4j.properties

# 3. Download and verify certificates during the build phase
ADD https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/certs/CommisSign.cer /tmp/certs/CommisSign.cer
ADD https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/certs/EuropeanCommission.cer /tmp/certs/EuropeanCommission.cer
ADD https://raw.githubusercontent.com/eea/aqr-public/master/ServerConfiguration/ecas/certs/GlobalSign.cer /tmp/certs/GlobalSign.cer

# 4. Verify checksums and import certificates into the Java Keystore
RUN set -e; \
    EUROCOM_SHA="70a7c70604a20c0fedc704351637efb9ff298b4f"; \
    COMMIS_SHA="b7e343a36e8bfbe5154250c1987f2efc6c396abb"; \
    GLOBAL_SHA="461ad9496b06e2a8ad0df391367b16d00c8f8fc7"; \
    if [ "$(sha1sum /tmp/certs/EuropeanCommission.cer | awk '{print $1}')" != "$EUROCOM_SHA" ] || \
       [ "$(sha1sum /tmp/certs/CommisSign.cer | awk '{print $1}')" != "$COMMIS_SHA" ] || \
       [ "$(sha1sum /tmp/certs/GlobalSign.cer | awk '{print $1}')" != "$GLOBAL_SHA" ]; then \
        printf "Invalid certificate sha1sum discovered during build.\n" && exit 1; \
    fi; \
    keytool -import -noprompt -v -keystore cacerts -storepass changeit -alias EuropeanCommission -file /tmp/certs/EuropeanCommission.cer \
    && keytool -import -noprompt -v -keystore cacerts -storepass changeit -alias CommisSign -file /tmp/certs/CommisSign.cer \
    && keytool -import -noprompt -v -keystore cacerts -storepass changeit -alias GlobalSign -file /tmp/certs/GlobalSign.cer \
    && rm -rf /tmp/certs

# 5. Perform server configuration tweaks
RUN rm -f ${CATALINA_HOME}/conf/logging.properties
COPY server.xml ${CATALINA_HOME}/conf/server.xml

# 6. Handle the application WAR file (the produced aqrsystem.war must exist in the current directory)
ENV WAR_FILEPATH=/tmp/ROOT.war
COPY aqrsystem.war ${WAR_FILEPATH}

# 7. Final setup
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
