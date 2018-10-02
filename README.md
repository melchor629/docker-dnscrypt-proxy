# dnscrypt-proxy in Docker

A small image based on alpine linux that downloads the latest version of [dnscrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy) and sets the environment to run the proxy.

The configuration must be stored in `/etc/dnscrypt-proxy`. The rest of files (like logs or source cache file) can be located in other places if you want. By default, will try to read the configuration from `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`. If that's not your case, you can modify the arguments. Remember that every relative path in the files referenced from the configuration will be located in the same directory as the configuration.

> **Note**: By default, runs as unprivileged user. In your configuration, you should use a port higher than `1024` (like `5353`) and then, you can expose the port as `53` or whatever other you want.

## Example: docker

```sh
docker container run --rm -d -v $PWD/config:/etc/dnscrypt-proxy -p 53:5353/udp melchor9000/dnscrypt-proxy
```

The listen address is `['0.0.0.0:5353']`.

## Example: docker-compose

```yaml
version: '3.6'

services:
  server:
    image: melchor9000/dnscrypt-proxy
    ports:
      - target: 5353
        published: 53
        protocol: udp
        mode: host
    restart: always
    volumes:
      #Here I have the toml and txt files
      #The cache is stored in another folder, but is not persisted
      - "./conf:/etc/dnscrypt-proxy"
    deploy:
      mode: replicated
      replicas: 2
```

