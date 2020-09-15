# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2016 AS downloader
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV LOGSTASH_VERSION="7.9.0" `
    LOGSTASH_HOME="C:\logstash"

WORKDIR C:/

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest "https://artifacts.elastic.co/downloads/logstash/logstash-$($env:LOGSTASH_VERSION).zip" -OutFile 'logstash.zip' -UseBasicParsing;  

##install 7 zip to unzip logstash file, the poweshell Expand-Archive is too slow
ENV INSTALLER_7_ZIP = "7z1900-x64.msi" 
RUN Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.msi" -OutFile $env:INSTALLER_7_ZIP; `
    msiexec /i $env:INSTALLER_7_ZIP /qb; 
	
RUN	set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"; `
    sz x logstash.zip ; 
	
RUN Move-Item c:/logstash-$($env:LOGSTASH_VERSION) $env:LOGSTASH_HOME;

# logstash
FROM openjdk:11-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV LOGSTASH_VERSION="7.9.0" `
    LOGSTASH_HOME="C:\logstash" `
	ES_JAVA_OPTS="-Xms1024m -Xmx1024m"

WORKDIR C:/logstash
COPY --from=downloader C:\logstash\ .
COPY logstash\config\beats.conf .

# http.host: 127.0.0.1
RUN (Get-Content ./config/logstash.yml) -replace '# http.host: \"127.0.0.1\"', 'http.host: \"0.0.0.0\"' | Set-Content ./config/kibana.yml;

EXPOSE 5044 9600 9700
ENTRYPOINT ["powershell"]
CMD ["./bin/logstash.bat -f beats.conf"]
