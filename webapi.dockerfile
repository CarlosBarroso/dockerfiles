# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 AS build

#RUN [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; `
#    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
	
#RUN	& choco install netfx-4.5.2-devpack -y; `
#	& choco.exe install nuget.commandline --version=3.5.0


WORKDIR /app

COPY Api/packages.config .
RUN nuget restore packages.config -PackagesDirectory .\packages

COPY Api.sln .
COPY Api/ ./Api/
COPY Domain/ ./Domain/
COPY Infrastructure/ ./Infrastructure/
COPY Service/ ./Service/

WORKDIR /app/Api
RUN msbuild /p:OutputPath=/out /p:DeployOnBuild=true 

#FROM microsoft/aspnet:windowsservercore
FROM mcr.microsoft.com/dotnet/framework/aspnet

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=build c:\out\_PublishedWebsites\api c:\api
	
#WORKDIR C:\api
RUN Remove-Website -Name 'Default Web Site'; `
    New-Website -Name 'api' -Port 80 -PhysicalPath 'c:\api'

HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost/api/test/echo  || exit 1

#EXPOSE 80 --> ya se hace en la imagen base

#ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"] --> ya se hace en la imagen base