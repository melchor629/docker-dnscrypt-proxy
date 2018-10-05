# dnscrypt-proxy in Docker

A small image based on alpine linux that downloads the latest version of [dnscrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy) and sets the environment to run the proxy.

The configuration must be stored in `/etc/dnscrypt-proxy`. The rest of files (like logs) can be located in other places if you want. By default, will try to read the configuration from `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`. If that's not your case, you can modify the arguments and the environment variable `CONFIG_PATH`. Remember that every relative path in the files referenced from the configuration will be located in the same directory as the configuration.

> **Note**: The proxy will always run as unprivileged user. In your configuration, you should use a port higher than `1024` (like `5353`) and then, you can expose the port as `53` or whatever other you want. This is done for you by default when the config volume is empty.

## Tags

In [Docker Hub](https://hub.docker.com/r/melchor9000/dnscrypt-proxy/), you can find these tags for `melchor9000/dnscrypt-proxy`:

 - `latest`: x86_64/amd64
 - `arm`: armhf (armv7)
 - `arm64`: aarch64 (armv8 64-bit)

All images are based on [alpine](https://hub.docker.com/_/alpine/) image to have low size images.

## The first run

The configuration files are written to the volume when you run for the first time the `dnscrypt-proxy` (only this one). My recomendation is to run the container for the first time, to let the configuration be written to the volume, and then stop it. Now, you can modify everything you want easily.

This first run also modifies some values of the configuration that you can modify, if you know what are you doing. As mentioned before, the proxy is run in a unprivileged user, so by default it will listen to port 5353. Also, the public resolvers list will be downloaded in the folder `/etc/dnscrypt-proxy/resolvers`.

This initial configuration is good enough to start doing things. But, for a production environment, it is recommended to modify some of the configuration files. These files have comments that will help you modify them. But feel free to go to the [official wiki](https://github.com/jedisct1/dnscrypt-proxy/wiki/Configuration) to extend the knowledge.

## Recommendations for the configuration

 1. Do not modify the `listen_addresses`, it's ok
 2. Do not uncomment or set `user_name`
 3. If docker has enabled IPv6 connectivity and you have IPv6 to the internet, you should set to `true` the line `ipv6_servers`
 4. Do not set a `log_file` nor `use_syslog`, let docker manage the log :)
 5. Could be a good idea to change the `fallback_resolver`, by default is `9.9.9.9:53`
 6. The forwarding and cloacking rules are enabled by default, you should modify the files to adapt to your needs
 7. The blacklist, ip-blacklist and whitelist are enabled too, you can add some block (or allow) rules in these files. The blacklist has some defined values, look them
 8. Could be a good idea to check the `cache` options

## Environment variables

The only one environment variable that can be configured is `CONFIG_PATH`. By default is `/etc/dnscrypt-proxy`, but if you want to change that, you can. This variable is to tell the init script where is the configuration folder inside the container. It is not recommended to change that, as the default value is valid, but you can change that if you need to.

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

