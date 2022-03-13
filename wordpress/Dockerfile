FROM bitnami/wordpress:5.9.2 as builder

USER root

COPY *.sh /template/
RUN /template/setup.sh

ARG USER_UID=1001
USER "${USER_UID}"
