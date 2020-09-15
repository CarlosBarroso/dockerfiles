# dockerfiles
Este repositorio contiene los dockerfiles para preparar contenedores windows de:
- elastisearch
- kibana
- logstash
- web api

## elasticsearch
docker image build --tag elasticsearch:v1 --file ./elasticsearch.dockerfile . --network "Default Switch"
docker run --name elasticsearch -it -p 9200:9200 -p 9300:9300 -m 3GB -e discovery.type=single-node --rm epreselec-elasticsearch:v1

## kibana
docker image build --tag kibana:v1 --file ./kibana.dockerfile . --network "Default Switch"
docker run --name kibana -d -p 5601:5601 --rm kibana:v1

## logstash
docker image build --tag logstash:v1 --file ./logstash.dockerfile . --network "Default Switch"
docker run --name logstash -d -p 5601:5601 --rm logstash:v2

## webapi
docker image build --tag api:v1 --file ./sdk.dockerfile . --network "Default Switch"
docker run --name web -d -p 8080:80 --rm api:v1

## servidor BBDD sqlserver
docker run --name sqldeveloper -d -p 1433:1433 -e sa_password=<password> -e ACCEPT_EULA=Y -v "C:\sqlserverdata:C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA" -e attach_dbs="[{'dbName':'<nombre_bbdd>','dbFiles':['c:\data\<fichero>.mdf','c:\data\<fichero>.ndf','c:\data\<fichero>_Log.ldf']}]" microsoft/mssql-server-windows-developer
