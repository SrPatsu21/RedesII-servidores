# Setup

## Bind9

- make readable

```shell
sudo chown -R 100:101 bind9/
```

- start it up:

```shell
docker compose up -d
```

- test exemple

```shell
dig @127.0.0.1 -p 30053 www.example.local
```