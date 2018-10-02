ARG ARCH=library

FROM ${ARCH}/alpine

ARG VERSION=2.0.16
RUN apk add --no-cache curl ca-certificates && \
    case $(uname -m) in \
        x86_64 ) ARCH=x86_64 ;; \
        armv7l ) ARCH=arm ;; \
        aarch64 ) ARCH=arm64 ;; \
        * ) echo Unsupported ARCH $(uname -m); exit 1 ;; \
    esac && \
    curl -sSL https://github.com/jedisct1/dnscrypt-proxy/releases/download/$VERSION/dnscrypt-proxy-linux_$ARCH-${VERSION}.tar.gz | tar -xvz && \
    cp linux-$ARCH/dnscrypt-proxy /usr/bin/dnscrypt-proxy && \
    rm -r linux-$ARCH && \
    apk del --no-cache curl

VOLUME /etc/dnscrypt-proxy
USER nobody

ENTRYPOINT ["dnscrypt-proxy"]
CMD ["-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
