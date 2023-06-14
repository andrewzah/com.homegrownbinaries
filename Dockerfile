FROM docker.io/library/rockylinux:9.2.20230513-minimal AS builder

WORKDIR /

RUN microdnf install -y golang gcc-c++ git make \
  && git clone https://github.com/gohugoio/hugo.git \
  && cd hugo \
  && go install --tags extended

RUN microdnf install -y ruby \
  && gem install asciidoctor asciidoctor-html5s asciidoctor-diagram rouge

RUN microdnf install -y findutils

COPY ./ /build/
WORKDIR /build

RUN /root/go/bin/hugo \
  && cp -r ./public/ /dist/ \
  && find /dist/ -type f -exec sed -i 's#<img src#<img decoding="async" loading="lazy" src#g' {} \;

FROM docker.io/library/rockylinux:9.2.20230513-minimal

RUN microdnf install -y tar

ARG CADDY_VERSION="2.6.4"
RUN curl -fL "https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_amd64.tar.gz" \
    -o "caddy.tgz" \
  && tar xzf "caddy.tgz" \
  && chmod +x caddy \
  && mv caddy /usr/bin/caddy \
  && rm \
    "caddy.tgz" \
    "README.md" \
    "LICENSE"

COPY ./Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /dist/ /var/www/

EXPOSE 2020
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
