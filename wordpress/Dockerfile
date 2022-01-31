FROM bitnami/wordpress:5.8.3 as builder

USER root

COPY *.sh /template/
RUN /template/setup.sh

USER 1001
