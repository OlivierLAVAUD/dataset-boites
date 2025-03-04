# Installation 


## Prérequisite

*   [Docker Desktop](https://www.docker.com/products/docker-desktop/) for a contener deployment
or 
*   [Postgres Database Server] ( https://www.enterprisedb.com/downloads/postgres-postgresql-downloads) for a local use

## Installation for a local use

* for a Windows local installation
1. Install Postgres Database Server (upside url link)
2. Add a Windows environnement variable in path: 
2. Create a server name with a administrator user and password
3. Execute the initial sql script: init.sql 
```bash
psql -h localhost -p 5432 -U postgres -d postgres
``` 