FROM registry.access.redhat.com/ubi9/ubi:latest

ENV SQUID_VERSION=5.2.1

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Squid http proxy" \
      io.k8s.display-name="Squid 5.2.1" \
      io.openshift.expose-services="3128:3128" \
      io.openshift.tags="squid,http,proxy"

RUN dnf -q -y update \
 && dnf -q -y install squid \
 && dnf -q -y --enablerepo=* clean all

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /entrypoint.sh
COPY squidCA.pem /opt/squidCA.pem
RUN chown 1001:0 /opt/squidCA.pem && chmod 440 /opt/squidCA.pem

RUN chmod 755 /entrypoint.sh && \
    chmod 777 /etc/squid /var/log/squid /var/run /var/run/squid /var/spool/squid && \
    chmod 666 /etc/squid/squid.conf && \
    chmod 777 /var/spool/squid

USER 1001

EXPOSE 3128/tcp
VOLUME /var/spool/squid

ENTRYPOINT ["/entrypoint.sh"]