## AQ e-Reporting ready to run docker image


### Installation process
1. Install [Docker](https://www.docker.com).
2. Install [Docker Compose](https://docs.docker.com/compose/).

### Download
3.Clone the repository from github:

    $ git clone https://github.com/eea/eea.docker.aqr-public
    $ cd eea.docker.aqr-public


## Database container

4.Create a data container for the postgresql database service
	
	$ docker run --name dbdata -v /var/lib/postgresql/data busybox


5.Create a file named *.secret* which contains the database credentials. Example:
    
    POSTGRES_USER=aqrsystem
    POSTGRES_PASSWORD=aqrsystem
    POSTGRES_DB=aqrsystem


6.Create a database container:

	$ docker run -d --name postresqldb --volumes-from dbdata --env-file .secret postgres:9.3

The database container is up and running.

## Import data
7.Import sql data and initialize the database:

	$ docker run -v /host/path/to/create_aqd.sql:/data.sql -t --rm  --link postresqldb:dbserver postgres:9.3 bash -c 'PGPASSWORD=dbpass psql -h dbserver -p 5432 -U dbuser -d dbname < /data.sql'
	
	$ docker run -v /host/path/to/insert_aqd.sql:/data.sql -t --rm --link postresqldb:dbserver postgres:9.3 bash -c 'PGPASSWORD=dbpass psql -h dbserver -p 5432 -U dbuser -d dbname < /data.sql'	
	
	$ docker run -v /host/path/to/UK_demos.sql:/data.sql -t --rm  --link postresqldb:dbserver postgres:9.3 bash -c 'PGPASSWORD=dbpass psql -h dbserver -p 5432 -U dbuser -d dbname < /data.sql'	


*Note: dbuser, dbpass, dbname should match the values POSTGRESQL_USERNAME, POSTGRESQL_PASS, POSTGRESQL_DB declared in the .secret file.*

## Web app container

10.Create a data container that will store the log files for the web server
	
	$ docker run --name webappdatacontainer -v /usr/local/tomcat/logs -v /var/log/aqrsystem busybox


11.If the war file that you want to deploy is located on your filesystem then:
	
	$ docker run --name warcontainer -v /path/to/aqrsystem.war:/tmp/ROOT.war busybox


### Override persistence.xml and ecas-config.properties file


	$ docker run --name warcontainer -v /tmp -v /path/to/aqrsystem.war:/aqrsystem.war -v /path/to/ecas-config.properties:/tmp/WEB-INF/classes/ecas-config.properties -v /path/to/persistence.xml:/tmp/WEB-INF/classes/META-INF/persistence.xml java:7 sh -c 'cp /aqrsystem.war /tmp/ROOT.war && cd /tmp && jar -uf ROOT.war WEB-INF/classes/ecas-config.properties WEB-INF/classes/META-INF/persistence.xml'


## Run the web app container
	
	$ docker run --name aqrsystemserver -p 8080:8080 --volumes-from webappdatacontainer --volumes-from warcontainer --link postresqldb:DB_HOST eeacms/aqr-public
	

*Note: In the persistence.xml file, the database IP Adress should match the docker container alias (DB_HOST)*
    
    $ <property name="javax.persistence.jdbc.url" value="jdbc:postgresql://DB_HOST:5432/dbname"/>
