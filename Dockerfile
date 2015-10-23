FROM tomcat:6
MAINTAINER Ervis Zyka <ez@eworx.gr>
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV DOCKER_DEPLOYMENT_DIR /docker/deployment/papers
ENV JENKINS_URL http://ci.eionet.europa.eu/view/Java/job/AQRSystem/lastSuccessfulBuild/artifact/SourceCode/aqrsystem/target/aqrsystem.war
ENV PATH $PATH:/scripts
ENV KEYSTORE_PASS "changeit"
ENV EUROCOM_CERT_SHA1_DEFAULT "70a7c70604a20c0fedc704351637efb9ff298b4f"
ENV COMMISSIGN_CERT_SHA1_DEFAULT "b7e343a36e8bfbe5154250c1987f2efc6c396abb"

RUN apt-get update -y && apt-get install -y openjdk-7-jdk
RUN rm -rf /var/lib/apt/lists/* \
 && rm $CATALINA_HOME/bin/tomcat-juli.jar
COPY ServerConfiguration/ecas/tomcat/* $CATALINA_HOME/lib/
COPY ServerConfiguration/ecas/org $CATALINA_HOME/lib/org
COPY ServerConfiguration/tomcat-juli.jar $CATALINA_HOME/bin/tomcat-juli.jar
COPY ServerConfiguration/certs /tmp/certs

RUN rm ${CATALINA_HOME}/conf/logging.properties && \
    keytool -import -noprompt -v -keystore ${JAVA_HOME}/jre/lib/security/cacerts -storepass ${KEYSTORE_PASS} -alias EuropeanCommission -file /tmp/certs/EuropeanCommission.cer && \
    keytool -import -noprompt -v -keystore ${JAVA_HOME}/jre/lib/security/cacerts -storepass ${KEYSTORE_PASS} -alias CommisSign -file /tmp/certs/CommisSign.cer && \
    sed -i 's#<Realm className="org.apache.catalina.realm.UserDatabaseRealm"#<Realm className="org.apache.catalina.realm.UserDatabaseRealm" allRolesMode="authOnly"#' $CATALINA_HOME/conf/server.xml
    

COPY docker-entrypoint.sh /entrypoint.sh
COPY scripts/ /scripts/
ENTRYPOINT ["/entrypoint.sh"]
