# Docker

Tags: #docker #sql-server #containers

See [[p14s]] for architecture overview. See [[kvm]] for Windows VM / SSMS connection.

## SQL Server Setup

SQL data lives on the `/vm` partition (xfs) and is mounted into the container:

```
/vm/sqldata/   ← .mdf / .ldf files
```

Windows VM connects to SQL Server via host IP `192.168.122.1`.

When connecting from SSMS: enable **"Trust server certificate"** in Options → Connection Security (SQL Server uses a self-signed certificate).

## Install

```bash
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

## SQL Server Compose File

Located at `~/docker/docker-compose-dev.yml`.

```bash
# Fix permissions for mssql user (uid 10001) — required on first run
sudo chown 10001:10001 /vm/sqldata

# Start
docker compose -f ~/docker/docker-compose-dev.yml up -d

# Stop
docker compose -f ~/docker/docker-compose-dev.yml down
```

## Common Commands

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start / stop
docker compose -f docker-compose-dev.yml up -d
docker compose -f docker-compose-dev.yml down

# Logs
docker logs <container-id>
docker logs -f <container-id>

# Shell into container
docker exec -it <container-id> bash

# Stop and remove container
docker stop <container-id>
docker rm <container-id>
```

## Cleanup

```bash
# Remove unused containers, networks, images
docker system prune

# Remove unused volumes too
docker system prune --volumes

# Remove specific image
docker rmi <image>
```

## TODO

- [x] Write docker-compose for SQL Server (multiple versions)
- [x] Mount /vm/sqldata into container
- [x] Verify SSMS connection from Windows VM via 192.168.122.1

## Related

- [[monitoring]] - docker compose for AlertManager/Prometheus
- [[kvm]] - Windows VM + SSMS
- [[p14s]] - system architecture
