# dockerfiles
Este repositorio contiene los dockerfiles para preparar contenedores windows de:
- elastisearch
- kibana
- logstash
- web api

## elasticsearch
docker image build --tag elasticsearch:v1 --file ./elasticsearch.dockerfile . --network "Default Switch"

docker run --name elasticsearch -it -p 9200:9200 -p 9300:9300 -m 3GB -e discovery.type=single-node --rm elasticsearch:v1

docker run --name elasticsearch -it -p 9200:9200 -p 9300:9300 -m 3GB -e discovery.type=single-node --rm cbarrosoc/elasticsearch:v1

## kibana
docker image build --tag kibana:v1 --file ./kibana.dockerfile . --network "Default Switch"

docker run --name kibana -d -p 5601:5601 --rm kibana:v1

docker run --name kibana -d -p 5601:5601 --rm cbarrosoc/kibana:v1

## logstash
docker image build --tag logstash:v1 --file ./logstash.dockerfile . --network "Default Switch"

docker run --name logstash -d -p 5601:5601 --rm logstash:v1

docker run --name logstash -d -p 5601:5601 --rm cbarrosoc/logstash:v1

# app stack
Se incluyen los docker files para crear los contenedores de webapi y la bbdd.

Así mismo se puede encontrar el docker-compose que levanta los dos contenedores.

No se ha podido incluir el stack de elk en el fichero de docker compose por los requisitos de memoria que tiene elastic search. 

No he encontrado como transladar el parámetro -m al fichero docker-compose


## webapi
docker image build --tag api:v1 --file ./sdk.dockerfile . --network "Default Switch"

docker run --name web -d -p 8080:80 --rm api:v1

## servidor BBDD sqlserver
docker run --name sqldeveloper -d -p 1433:1433 -e sa_password=<sa_password> -e ACCEPT_EULA=Y -v "C:\sqlserverdata:C:\data" -e attach_dbs="[{'dbName':'<nombre_bbdd>','dbFiles':['c:\data\<fichero>.mdf','c:\data\<fichero>.ndf','c:\data\<fichero>_Log.ldf']}]" microsoft/mssql-server-windows-developer
