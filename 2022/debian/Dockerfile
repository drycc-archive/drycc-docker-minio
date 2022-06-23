FROM registry.drycc.cc/drycc/base:bullseye

ENV GOSU_VERSION="1.14" \
  WATI_FOR_PORT_VERSION="1.0.3" \
  JQ_VERSION="1.6" \
  MC_VERSION="2022.06.17.02.52.50" \
  MINIO_VERSION="2022.06.20.23.13.45"

COPY prebuildfs /

RUN install-packages libnss-wrapper psmisc \
  && install-stack gosu $GOSU_VERSION \
  && install-stack wait-for-port $WATI_FOR_PORT_VERSION \
  && install-stack jq $JQ_VERSION \
  && install-stack mc $MC_VERSION \
  && install-stack minio $MINIO_VERSION \
  && echo "export NSS_WRAPPER_LIB=/usr/lib/`echo $(uname -m)`-linux-gnu/libnss_wrapper.so" >> /opt/drycc/minio/profile.d/minio.sh \
  && . init-stack \
  && rm -rf \
    /usr/share/doc \
    /usr/share/man \
    /usr/share/info \
    /usr/share/locale \
    /var/lib/apt/lists/* \
    /var/log/* \
    /var/cache/debconf/* \
    /etc/systemd \
    /lib/lsb \
    /lib/udev \
    /usr/lib/`echo $(uname -m)`-linux-gnu/gconv/IBM* \
    /usr/lib/`echo $(uname -m)`-linux-gnu/gconv/EBC* \
  && mkdir -p /usr/share/man/man{1..8} \
  && mkdir /docker-entrypoint-initdb.d /docker-entrypoint-startdb.d \
  &&  chmod g+rwX /opt/drycc

COPY rootfs /
RUN /opt/drycc/scripts/minio-client/postunpack.sh
RUN /opt/drycc/scripts/minio/postunpack.sh

VOLUME [ "/certs", "/data" ]
EXPOSE 9000 9001

WORKDIR /opt/drycc/mc
USER 1001
ENTRYPOINT [ "init-stack", "/opt/drycc/scripts/minio/entrypoint.sh" ]
CMD [ "/opt/drycc/scripts/minio/run.sh" ]
 