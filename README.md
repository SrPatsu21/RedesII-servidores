# Setup

## Bind9

- make readable

```shell
sudo chown -R 100:101 bind9_config/
sudo chown -R 100:101 bind9slave_config/
```

- start it up:

```shell
docker compose up -d
```

- reconfig

```shell
docker exec bind9-container named-checkconf /etc/bind/named.conf
docker exec bind9-container named-checkzone angelcorp.com.br /etc/bind/db.angelcorp.com.br
docker restart bind9-container
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

- generate cert

```shell
sudo chmod +x ./nginx/gen_cert.sh
./nginx/gen_cert.sh
```

- verify config

```shell
docker exec nginx-container nginx -t
```

- password

```shell
sudo apt update
sudo apt install apache2-utils
htpasswd -c nginx/conf.d/.htpasswd angelita
```

- reload

```shell
docker exec nginx-container nginx -s reload
```

- test Urls
    <http://reports.angelcorp.com.br/>
    <http://docs.angelcorp.com.br/>
    <https://www.angelcorp.com.br/>


## FTPS 

```conect
    lftp -u alunoftp,pass123 -p 21 10.0.0.5
```