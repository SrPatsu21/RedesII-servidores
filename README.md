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
dig @10.0.0.2 angelcorp.com.br
dig @10.0.0.2 A www.angelcorp.com.br
dig @10.0.0.3 A www.angelcorp.com.br
dig @10.0.0.3 www.angelcorp.com.br
dig @10.0.0.3 google.com
```

## Nginx

generate cert

```shell
sudo chmod +x ./nginx/gen_cert.sh
./nginx/gen_cert.sh
```

verify config

```shell
docker exec nginx-container nginx -t
```

pass

```shell
sudo apt update
sudo apt install apache2-utils
htpasswd -c nginx/conf.d/.htpasswd angelita
```

reload

```shell
docker exec nginx-container nginx -s reload
```
