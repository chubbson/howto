# Docker

Tags: #docker #sql-server #containers

See [[p14s]] for architecture overview. See [[kvm]] for Windows VM / SSMS connection.

## SQL Server Setup

SQL data lives on the `/vm` partition (xfs) and is mounted into the container:

```
/vm/sqldata/   ← .mdf / .ldf files
```

Windows VM connects to SQL Server via host IP `192.168.122.1`.

## Install

```bash
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
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

- [ ] Write docker-compose for SQL Server (multiple versions)
- [ ] Mount /vm/sqldata into container
- [ ] Verify SSMS connection from Windows VM via 192.168.122.1

## Related

- [[monitoring]] - docker compose for AlertManager/Prometheus
- [[kvm]] - Windows VM + SSMS
- [[p14s]] - system architecture
