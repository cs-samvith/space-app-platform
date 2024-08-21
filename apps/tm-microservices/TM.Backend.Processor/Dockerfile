FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

USER app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["TM.Backend.Processor.csproj", ""]
RUN dotnet restore "TM.Backend.Processor.csproj"
COPY . .
# WORKDIR "/src/TM.Backend.Processor"
RUN dotnet build "TM.Backend.Processor.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "TM.Backend.Processor.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TM.Backend.Processor.dll"]
