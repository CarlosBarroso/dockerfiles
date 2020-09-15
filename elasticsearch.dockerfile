# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2016 AS downloader
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV ES_VERSION="7.9.0" `
    ES_HOME="C:\elasticsearch"

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$($env:ES_VERSION)-windows-x86_64.zip" -OutFile 'elasticsearch.zip' -UseBasicParsing; `
    Expand-Archive elasticsearch.zip -DestinationPath C:\ ; `
    Move-Item c:/elasticsearch-$($env:ES_VERSION) $env:ES_HOME;


#RUN Invoke-WebRequest "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$($env:ES_VERSION)-windows-x86_64.zip.sha512" -OutFile 'elasticsearch.zip.sha512' -UseBasicParsing; `
#    $env:ES_SHA512 = Get-Content -Raw elasticsearch.zip.sha512; `
#    Invoke-WebRequest "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$($env:ES_VERSION)-windows-x86_64.zip" -OutFile 'elasticsearch.zip' -UseBasicParsing; `
#    if ((Get-FileHash elasticsearch.zip -Algorithm sha512).Hash.ToLower() -ne $env:ES_SHA512) {exit 1}; `
#    Expand-Archive elasticsearch.zip -DestinationPath C:\ ; `
#    Move-Item c:/elasticsearch-$($env:ES_VERSION) $env:ES_HOME;

# Elasticsearch
FROM openjdk:11-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV ES_VERSION="7.9.0" `
    ES_HOME="C:\elasticsearch" `
    ES_JAVA_OPTS="-Xms2048m -Xmx2048m"

# Volume and drive mount
VOLUME C:\data
#RUN Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices' -Name 'G:' -Value '\??\C:\data' -Type String    
RUN Set-Variable -Name 'regpath' -Value 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices' ; `
    Set-ItemProperty -path $regpath -Name 'G:' -Value '\??\C:\data' -Type String ; 
 
EXPOSE 9200 9300
SHELL ["cmd", "/S", "/C"]
CMD ".\bin\elasticsearch.bat"

WORKDIR $ES_HOME
COPY --from=downloader C:\elasticsearch\ .
COPY elasticsearch ./config

HEALTHCHECK --interval=5s `
 CMD powershell -command `
    try { `
     $content = (iwr -useb http://localhost:9200/_cluster/health?pretty).Content; `
     $health = $content.Split(' ')[3]; `
     if ($health -eq 'green' -or $health -eq 'yellow') { return 0 } `
     else { return 1 }; `
    } catch { return 1 }