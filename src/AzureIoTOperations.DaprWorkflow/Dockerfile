FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5002
EXPOSE 5005

ENV ASPNETCORE_URLS=http://+:5002

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["AzureIoTOperations.DaprWorkflow.csproj", "AzureIoTOperations.DaprWorkflow/"]
RUN dotnet restore "AzureIoTOperations.DaprWorkflow/AzureIoTOperations.DaprWorkflow.csproj"
COPY . .

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "AzureIoTOperations.DaprWorkflow.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AzureIoTOperations.DaprWorkflow.dll"]
