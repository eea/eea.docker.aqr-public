FROM tomcat:6
COPY docker-entrypoint.sh /entrypoint.sh
ENV WAR_FILEPATH /tmp/ROOT.war
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
