#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["TM.Backend.Processor.csproj", ""]
RUN dotnet restore "./TM.Backend.Processor.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./TM.Backend.Processor.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "./TM.Backend.Processor.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TM.Backend.Processor.dll"]