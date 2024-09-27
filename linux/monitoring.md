
```
docker compose -f docker-compose-dev.yml up -d
```

```
docker compose -f docker-compose-dev.yml down
```

cleanup docker

```
docker ps -a

CONTAINER ID   IMAGE                       COMMAND                  CREATED         STATUS         PORTS                                       NAMES
192d2f23efce   prom/alertmanager:v0.27.0   "/bin/alertmanager -…"   2 minutes ago   Up 2 minutes   0.0.0.0:9093->9093/tcp, :::9093->9093/tcp   monitoring-alertmanager-1

docker stop 192d2f23efce
docker rm 192d2f23efce
```

now we shou