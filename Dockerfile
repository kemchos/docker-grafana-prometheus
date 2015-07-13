FROM alpine:latest

ENV GRAFANA_VERSION=v2.0.2

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin

RUN apk add --update build-base nodejs go git mercurial \
    && mkdir -p /go/src/github.com/grafana && cd /go/src/github.com/grafana \
    && git clone https://github.com/grafana/grafana.git -b ${GRAFANA_VERSION} \
    && cd grafana \
    && go run build.go setup \
    && godep restore \
    && go build . \
    && npm install \
    && npm install -g grunt-cli \
    && grunt \
    && npm uninstall -g grunt-cli \
    && npm cache clear \
    && mkdir -p /usr/share/grafana/bin/ \
    && cp -a /go/src/github.com/grafana/grafana/grafana /usr/share/grafana/bin/grafana-server \
    && cp -ra /go/src/github.com/grafana/grafana/public /usr/share/grafana \
    && cp -ra /go/src/github.com/grafana/grafana/conf /usr/share/grafana \
    && go clean -i -r \
    && mkdir -p /tmp/src && cd /tmp/src \
    && git clone https://github.com/kemchos/grafana-plugins.git \
    && cd grafana-plugins && git checkout prometheus-nested-variable && cd .. \
    && cp -ra grafana-plugins/datasources/prometheus /usr/share/grafana/public/app/plugins/datasource/ \
    && apk del --purge build-base nodejs go git mercurial \
    && rm -rf /go /tmp/* /var/cache/apk/* /root/.n*

EXPOSE 3000

WORKDIR /usr/share/grafana/

CMD ["/usr/share/grafana/bin/grafana-server"]