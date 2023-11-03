#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim AS base-amd64
WORKDIR /app

FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim-arm64v8 AS base-arm64
WORKDIR /app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:6.0.101-bullseye-slim AS build
WORKDIR /src
COPY ["src/HealthChecks.UI.K8s.Operator/HealthChecks.UI.K8s.Operator.csproj", "src/HealthChecks.UI.K8s.Operator/"]
RUN dotnet restore "src/HealthChecks.UI.K8s.Operator/HealthChecks.UI.K8s.Operator.csproj"
COPY . .
WORKDIR "/src/src/HealthChecks.UI.K8s.Operator"
RUN dotnet build "HealthChecks.UI.K8s.Operator.csproj" -c Release -o /app/build

FROM build AS publish
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
	RID=linux-x64 ; \
	elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
	RID=linux-arm64 ; \
	elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
	RID=linux-arm ; \
	fi \
	&&  dotnet publish "HealthChecks.UI.K8s.Operator.csproj" -c Release -o /app/publish

FROM base-${TARGETARCH} AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HealthChecks.UI.K8s.Operator.dll"]
