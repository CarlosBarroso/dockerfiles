# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2016 AS downloader
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV KIBANA_VERSION="7.1.1" `
    KIBANA_HOME="C:\kibana"

WORKDIR C:/

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest "https://artifacts.elastic.co/downloads/kibana/kibana-$($env:KIBANA_VERSION)-windows-x86_64.zip" -OutFile 'kibana.zip' -UseBasicParsing;  

##install 7 zip to unzip kibana file, the poweshell Expand-Archive is too slow
ENV INSTALLER_7_ZIP = "7z1900-x64.msi" 
RUN Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.msi" -OutFile $env:INSTALLER_7_ZIP; `
    msiexec /i $env:INSTALLER_7_ZIP /qb; 
	
RUN	set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"; `
    sz x kibana.zip ; 
	
RUN Move-Item c:/kibana-$($env:KIBANA_VERSION)-windows-x86_64 $env:KIBANA_HOME;

# RUN Expand-Archive kibana.zip -DestinationPath C:\; `     
#    Move-Item c:/kibana-$($env:KIBANA_VERSION)-windows-x86 $env:KIBANA_HOME;

#RUN Invoke-WebRequest "https://artifacts.elastic.co/downloads/kibana/kibana-$($env:KIBANA_VERSION)-windows-x86_64.zip.sha1" -OutFile 'kibana.zip.sha1' -UseBasicParsing; `
#    $env:KIBANA_SHA1 = Get-Content -Raw kibana.zip.sha1; `
#    Invoke-WebRequest "https://artifacts.elastic.co/downloads/kibana/kibana-$($env:KIBANA_VERSION)-windows-x86_64.zip" -OutFile 'kibana.zip' -UseBasicParsing; `
#    if ((Get-FileHash kibana.zip -Algorithm sha1).Hash.ToLower() -ne $env:KIBANA_SHA1) {exit 1}; `
#    Expand-Archive kibana.zip -DestinationPath C:\; `
#    Move-Item c:/kibana-$($env:KIBANA_VERSION)-windows-x86 $env:KIBANA_HOME;

# Kibana
FROM mcr.microsoft.com/windows/servercore:ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV KIBANA_VERSION="7.1.1" `
    KIBANA_HOME="C:\kibana"

EXPOSE 5601
ENTRYPOINT ["powershell"]
CMD ["./init.ps1"]

WORKDIR C:/kibana
COPY kibana\init.ps1 .
COPY --from=downloader C:\kibana\ .

# Default configuration for host & Elasticsearch URL
RUN (Get-Content ./config/kibana.yml) -replace '#server.host: \"localhost\"', 'server.host: \"0.0.0.0\"' | Set-Content ./config/kibana.yml; `
    (Get-Content ./config/kibana.yml) -replace '#elasticsearch.hosts: \[\"http://localhost:9200\"\]', 'elasticsearch.hosts: [\"http://elasticsearch:9200\"]' | Set-Content ./config/kibana.yml; `
	cat config\kibana.yml

HEALTHCHECK --start-period=30s --interval=10s --retries=5 `
 CMD powershell -command `
    try { `
     $response = iwr -useb http://localhost:5601/app/kibana; `
     if ($response.StatusCode -eq 200) { return 0} `
     else {return 1}; `
    } catch { return 1 }