FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Applications.Front/Applications.Front/Applications.Front.csproj", "Applications.Front/Applications.Front/"]
COPY ["Applications.Front/Applications.Front.Client/Applications.Front.Client.csproj", "Applications.Front/Applications.Front.Client/"]
RUN dotnet restore "Applications.Front/Applications.Front/Applications.Front.csproj"
COPY . .
WORKDIR "/src/Applications.Front/Applications.Front"
RUN dotnet build "Applications.Front.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Applications.Front.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Applications.Front.dll"]
