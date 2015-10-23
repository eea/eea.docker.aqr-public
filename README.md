## AQ e-Reporting ready to run docker image


## Installation process
1. Install [Docker](https://www.docker.com).
2. Install [Docker Compose](https://docs.docker.com/compose/).

## Download
3.Clone the repository from github:

    $ git clone https://github.com/eea/eea.docker.aqr-public
    $ cd eea.docker.aqr-public

## Production deployment

4.Create a file named *.secret* which contains the database credentials. Example:
    
    POSTGRES_USER=aqrsystem
    POSTGRES_PASSWORD=aqrsystem
    POSTGRES_DB=aqrsystem


5.Create tomcat container:

    $ docker-compose up -d tomcat


6.Deploying changes to [production](https://docs.docker.com/compose/production/)
	
    $ docker-compose up --no-deps -d tomcat

Note: The --no-deps flag prevents Compose from also recreating any services which web depends on.