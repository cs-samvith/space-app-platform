FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5001

ENV ASPNETCORE_URLS=http://+:5001

USER app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["TM.Frontend.Ui.csproj", ""]

ADD https://kmxprodzscalercerts.blob.core.windows.net/zscalercerts/zscaler_root_ca.crt /usr/local/share/ca-certificates/zscaler.crt
RUN cat /usr/local/share/ca-certificates/zscaler.crt >> /etc/ssl/certs/ca-certificates.crt

RUN dotnet restore "TM.Frontend.Ui.csproj"
COPY . .
# WORKDIR "/src/TM.Frontend.Ui"
RUN dotnet build "TM.Frontend.Ui.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "TM.Frontend.Ui.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TM.Frontend.Ui.dll"]
