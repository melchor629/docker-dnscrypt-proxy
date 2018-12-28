ARG ARCH=library

FROM ${ARCH}/alpine

ARG VERSION=2.0.19
RUN apk add --no-cache curl ca-certificates su-exec bash && \
    case $(uname -m) in \
        x86_64 ) ARCH=x86_64 ;; \
        armv7l ) ARCH=arm ;; \
        aarch64 ) ARCH=arm64 ;; \
        * ) echo Unsupported ARCH $(uname -m); exit 1 ;; \
    esac && \
    \
    echo " > Downloading dnscrypt-proxy $VERSION" && \
    curl -sSL https://github.com/jedisct1/dnscrypt-proxy/releases/download/$VERSION/dnscrypt-proxy-linux_$ARCH-${VERSION}.tar.gz | tar -xvz && \
    \
    echo " > Copying dnscrypt-proxy executable" && \
    cp linux-$ARCH/dnscrypt-proxy /usr/bin/dnscrypt-proxy && \
    \
    echo " > Copying configuration" && \
    mkdir -p /usr/local/share/dnscrypt-proxy && \
    mkdir -p /etc/dnscrypt-proxy && \
    for file in linux-$ARCH/*.txt linux-$ARCH/*.toml; do \
        new_file_name=$(echo $file | sed "s/example-//") && \
        new_file_name=$(echo $new_file_name | sed "s/linux-$ARCH//") && \
        echo "   > Copying $file -> /usr/local/share/dnscrypt-proxy$new_file_name" && \
        cp $file "/usr/local/share/dnscrypt-proxy$new_file_name"; \
    done && \
    chmod 777 /etc/dnscrypt-proxy/ && \
    chmod -R a+r /usr/local/share/dnscrypt-proxy/ && \
    \
    echo " > Clean up" && \
    rm -r linux-$ARCH && \
    apk del --no-cache curl

COPY docker-entrypoint.sh /
RUN chmod ua+x /docker-entrypoint.sh

VOLUME /etc/dnscrypt-proxy
EXPOSE 5353 5353/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
