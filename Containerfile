# ============================
# Etapa 1: Build
# ============================
# Imagen base Red Hat UBI con .NET SDK
FROM registry.redhat.io/ubi8/dotnet-90 AS build
#FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

# Establecer directorio de trabajo en el contenedor para la compilación
WORKDIR /src

# Copiar la solución completa y proyectos
COPY *.sln ./
COPY BlazorApp/ ./BlazorApp/

# Restaurar dependencias
RUN dotnet restore *.sln

# Copiar todo el código fuente y compilar
# Publicar proyecto principal
#RUN dotnet publish BlazorApp/BlazorApp.csproj -c Release -o /out -r browser-wasm
RUN dotnet publish BlazorApp/BlazorApp.csproj -c Release -o /tmp/publish --self-contained false -r linux-x64

# ============================
# Etapa 2: Runtime
# ============================
FROM registry.redhat.io/rhel8/dotnet-90-runtime AS runtime
#FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Copiar los artefactos publicados desde la etapa de build
COPY --from=build /tmp/publish .

# Puerto por defecto para Kestrel
EXPOSE 8080

# Variable de entorno recomendada para contenedores
ENV ASPNETCORE_URLS=http://+:8080 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Comando de inicio
ENTRYPOINT ["dotnet", "BlazorApp.dll"]