FROM apache/superset:latest

USER root

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install pkg-config, gcc, and its dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libmariadb-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

ENV ADMIN_USERNAME $SUPERSET_ADMIN_USERNAME
ENV ADMIN_EMAIL $SUPERSET_ADMIN_EMAIL
ENV ADMIN_PASSWORD $SUPERSET_ADMIN_PASSWORD

COPY ./superset-init.sh /superset-init.sh
COPY superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

USER superset
ENTRYPOINT [ "/superset-init.sh" ]