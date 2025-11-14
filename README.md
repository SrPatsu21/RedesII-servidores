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
dig @127.20.0.2 A www.angelcorp.com.br
dig @127.20.0.3 -p 300153 www.angelcorp.com.br
```
