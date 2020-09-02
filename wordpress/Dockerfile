FROM bitnami/wordpress:5.5.1 as builder

USER root

COPY *.sh *.js /template/
RUN /template/setup.sh

USER 1001
