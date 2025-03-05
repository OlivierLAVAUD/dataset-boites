# Installation 


## Prérequisite

*   [Docker Desktop](https://www.docker.com/products/docker-desktop/) for a contener deployment
or 
*   [Postgres Database Server] ( https://www.enterprisedb.com/downloads/postgres-postgresql-downloads) for a local use

## Installation for a local use

* for a Windows local installation
1. Install and Run Postgres Database Server (upside url link)
2. During the installation, specify a server name, a admin or root user with password
3. Add to local user or system environnement variable path, a new item: C:\Program Files\PostgreSQL\17\bin 
4. Restart the session or the computer
5. Execute the initial sql script: init.sql 
```bash
psql -h localhost -p 5432 -U postgres -d postgres
``` 