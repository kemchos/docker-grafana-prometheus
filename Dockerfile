FROM debian:wheezy

ENV GRAFANA_VERSION=grafana-2.0.2

RUN apt-get update && apt-get install -y curl git \
    && mkdir -p /tmp/src \
    && cd /tmp/src \
    && curl -L -O https://grafanarel.s3.amazonaws.com/builds/${GRAFANA_VERSION}.linux-x64.tar.gz \
    && tar -zxvf ${GRAFANA_VERSION}.linux-x64.tar.gz \
    && git clone https://github.com/kemchos/grafana-plugins.git \
    && cd grafana-plugins && git checkout prometheus-nested-variable && cd .. \
    && cp -ra grafana-plugins/datasources/prometheus ${GRAFANA_VERSION}/public/app/plugins/datasource/ \
    && mkdir -p /usr/share/grafana \
    && cp -ra ${GRAFANA_VERSION}/* /usr/share/grafana \
    && apt-get --purge autoremove -y curl git && apt-get clean \
    && rm -rf /tmp/src

EXPOSE 3000

WORKDIR /usr/share/grafana/

CMD ["/usr/share/grafana/bin/grafana-server"]