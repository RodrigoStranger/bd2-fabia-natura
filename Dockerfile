FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

# Instalar dependencias mínimas
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    ca-certificates \
    apt-transport-https \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Agregar repositorio de Microsoft
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/20.04/prod focal main" > /etc/apt/sources.list.d/msprod.list

# Instalar sqlcmd
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools18 && \
    ln -sfn /opt/mssql-tools18/bin/sqlcmd /usr/bin/sqlcmd && \
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /etc/bash.bashrc && \
    rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios
RUN mkdir -p /FabiaNaturaBD && \
    chown -R mssql:mssql /FabiaNaturaBD

ENV PATH="$PATH:/opt/mssql-tools18/bin"

USER mssql