#!/usr/bin/env bash

set -Eeo pipefail

if [ -z "$CONFIG_PATH" ]; then
    CONFIG_PATH=/etc/dnscrypt-proxy
fi

if [ "${1:0:1}" = '-' ]; then
    set -- dnscrypt-proxy "$@"
fi

if [ "$1" = 'dnscrypt-proxy' ]; then
    mkdir -p "$CONFIG_PATH"
    chown -R "$(id -u)" "$CONFIG_PATH" 2>/dev/null || :
    chmod 700 "$CONFIG_PATH" 2>/dev/null || :

    if [ ! -f "$CONFIG_PATH/dnscrypt-proxy.toml" ]; then
        echo " > Copying configuration to $CONFIG_PATH"
        cp /usr/local/share/dnscrypt-proxy/* /etc/dnscrypt-proxy

        #Change the default port as this is going to be executed without root privileges
        #Also disable IPv6 port bind as it is not enabled by default
        sed -i \
            "s/listen_addresses = \\['127.0.0.1:53'\\]/listen_addresses = ['0.0.0.0:5353']/" \
            "$CONFIG_PATH/dnscrypt-proxy.toml"

        #Store the cache of public resolvers in a subfolder
        mkdir -p "$CONFIG_PATH/resolvers"
        sed -i \
            "s%  cache_file = 'public-resolvers.md'%  cache_file = 'resolvers/public-resolvers.md'%" \
            "$CONFIG_PATH/dnscrypt-proxy.toml"
        sed -i \
            "s%  cache_file = 'relays.md'%  cache_file = 'resolvers/relays.md'%" \
            "$CONFIG_PATH/dnscrypt-proxy.toml"
        sed -i \
            "s%  # cache_file = 'quad9-resolvers.md'%  # cache_file = 'resolvers/quad9-resolvers.md'%" \
            "$CONFIG_PATH/dnscrypt-proxy.toml"
        sed -i \
            "s%  #  cache_file = 'parental-control.md'%  #  cache_file = 'resolvers/parental-control.md'%" \
            "$CONFIG_PATH/dnscrypt-proxy.toml"

        #Remove user_name configuration line
        sed -i \
            "s/# user_name = 'nobody'//" \
            "$CONFIG_PATH/dnscrypt-proxy.toml"

        #Modify log_file configuration line
        sed -i \
            "s/# log_file = 'dnscrypt-proxy.log'/# log_file = 'DONT'/" \
            "$CONFIG_PATH/dnscrypt-proxy.toml"

        #Enable * rules (for an easy configuration)
        if [[ "$DNSCRYPT_PROXY_RULES" == *"forwarding"* ]]; then
            sed -i \
                "s/# forwarding_rules = 'forwarding-rules.txt'/forwarding_rules = 'forwarding-rules.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"cloaking"* ]]; then
            sed -i \
                "s/# cloaking_rules = 'cloaking-rules.txt'/cloaking_rules = 'cloaking-rules.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"blocked-names"* ]]; then
            sed -i \
                "s/  # blocked_names_file = 'blocked-names.txt'/  blocked_names_file = 'blocked-names.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"blocked-ips"* ]]; then
            sed -i \
                "s/  # blocked_ips_file = 'blocked-ips.txt'/  blocked_ips_file = 'blocked-ips.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"allowed-names"* ]]; then
            sed -i \
                "s/  # allowed_names_file = 'allowed-names.txt'/  allowed_names_file = 'allowed-names.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"allowed-ips"* ]]; then
            sed -i \
                "s/  # allowed_ips_file = 'allowed-ips.txt'/  allowed_ips_file = 'allowed-ips.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"captive-portals"* ]]; then
            sed -i \
                "s/# map_file = 'example-captive-portals.txt'/map_file = 'captive-portals.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        # Enable configuring a local DoH
        if [[ "$DNSCRYPT_PROXY_RULES" == *"local-doh"* ]]; then
            sed -i \
                "s/# listen_addresses = \['127.0.0.1:3000'\]/listen_addresses = ['127.0.0.1:8443']/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
            sed -i \
                "s/# cert_file = 'localhost.pem'/cert_file = 'localhost.pem'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
            sed -i \
                "s/# cert_key_file = 'localhost.pem'/cert_key_file = 'localhost.pem'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
            sed -i \
                "s|# path = '/dns-query'|path = '/dns-query'|" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
            echo "!! Enabled local DoH: default certificate is use"
            echo "Take a look at https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Local-DoH"
        fi
    fi
fi

exec "$@"
