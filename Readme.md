## AQ e-Reporting ready to run docker image


### Installation process
1. Install [Docker](https://www.docker.com).
2. Install [Docker Compose](https://docs.docker.com/compose/).

### Download
    $ git clone https://github.com/eea/eea.docker.aqr-public
    $ cd eea.docker.aqr-public

## Development

    $ cp .secret.backup .secret

Edit the *.secret* file and provide postgresql credentials:
    
    POSTGRES_USER=aqrsystem
    POSTGRES_PASSWORD=aqrsystem
    POSTGRES_DB=aqrsystem

If the war file is located at */home/user/project/aqr-public/SourceCode/aqrsystem/target/aqrsystem.war* then edit the dev-docker-compose.yml file and change the line:

    /path/to/aqrsystem.war:/tmp/ROOT.war
    
to

    /home/user/project/aqr-public/SourceCode/aqrsystem/target/aqrsystem.war:/tmp/ROOT.war

### Start the containers

Run:

    $ docker-compose -f dev-docker-compose.yml up -d

Note: a) You need to start the containers in detached mode using the *-d* flag
      b) When you build the maven project , remember to configure the correct host for the database. Change the persistence.jdbc.url attribute
      
from

    <persistence.jdbc.url>jdbc:postgresql://localhost:5432/aqrsystem</persistence.jdbc.url>    

to

    <persistence.jdbc.url>jdbc:postgresql://DB:5432/aqrsystem</persistence.jdbc.url>
      

### Initialize database with data

Run:

    $ docker exec -t eeadockeraqrpublic_database_1 psql -U aqrsystem -d aqrsystem -f /tmp/postgres_init_db_files/create_aqd.sql 
    $ docker exec -t eeadockeraqrpublic_database_1 psql -U aqrsystem -d aqrsystem -f /tmp/postgres_init_db_files/insert_aqd.sql
    $ docker exec -t eeadockeraqrpublic_database_1 psql -U aqrsystem -d aqrsystem -f /tmp/postgres_init_db_files/UK_demos.sql


Open your browser and go to *http://localhost:8080*

## Production

Provide the URL of the war file:

    $ docker run -p 80:8080 -d -e url=http://..../aqrsystem.war eeacms/aqr-public
    
If credentials are required to access the war file, run:

    $ docker run -p 80:8080 -d -e user=jane -e password=secret -e url=http://..../aqrsystem.war eeacms/aqr-public
    
    
