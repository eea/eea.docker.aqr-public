#!/usr/bin/env python

import os
from xml.dom import minidom
xmldoc = minidom.parse('/docker/deployment/papers/WEB-INF/classes/META-INF/persistence.xml')
for element in xmldoc.getElementsByTagName('property'):
    if element.hasAttribute('name'):
        name = element.getAttribute('name')
        if name == 'javax.persistence.jdbc.url':
            element.setAttribute('value', 'jdbc:postgresql://DB_HOST:5432/{}'.format(os.getenv('DB_HOST_ENV_POSTGRES_DB')))
        elif name == 'javax.persistence.jdbc.password':
            element.setAttribute('value', os.getenv('DB_HOST_ENV_POSTGRES_PASSWORD'))
        elif name == 'javax.persistence.jdbc.driver':
            element.setAttribute('value', 'org.postgresql.Driver')
        elif name == 'javax.persistence.jdbc.user':
            element.setAttribute('value', os.getenv('DB_HOST_ENV_POSTGRES_USER'))
        elif name == 'eclipselink.ddl-generation':
            element.setAttribute('value', 'none')
log = xmldoc.createElement('property')
log.setAttribute('name', 'log.file.name')
log.setAttribute('value', '/var/log/aqrsystem/aqrsystem.log')
xmldoc.getElementsByTagName('properties')[0].appendChild(log);
xmldoc.getElementsByTagName('persistence-unit')[0].setAttribute('name', 'Aqrsystem');
xmldoc.writexml(open('/docker/deployment/papers/WEB-INF/classes/META-INF/persistence.xml','w'))
