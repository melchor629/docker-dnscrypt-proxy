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

        #Create one file that is not in the examples
        cat <<'EOF' > "$CONFIG_PATH/ip-blacklist.txt" 
###########################
#      IP Blacklist       #
###########################

#Rules for IP-based query blocking, one per line
# 192.*         Will match the start of IPs
# *.2           Will match the end of IPs
# 192.168.1.1   Will match an exact IP
# [::1]         The same but in IPv6
EOF

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

        #Ignore system DNS settings
        sed -i \
            "s/ignore_system_dns = false/ignore_system_dns = true/" \
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

        if [[ "$DNSCRYPT_PROXY_RULES" == *"blacklist"* ]]; then
            sed -i \
                "s/# blacklist_file = 'blacklist.txt'/blacklist_file = 'blacklist.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"ip-blacklist"* ]]; then
            sed -i \
                "s/# blacklist_file = 'ip-blacklist.txt'/blacklist_file = 'ip-blacklist.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi

        if [[ "$DNSCRYPT_PROXY_RULES" == *"whitelist"* ]]; then
            sed -i \
                "s/# whitelist_file = 'whitelist.txt'/whitelist_file = 'whitelist.txt'/" \
                "$CONFIG_PATH/dnscrypt-proxy.toml"
        fi
    fi
fi

exec "$@"
