FROM bitnami/wordpress:5.4.1 as builder

USER root

COPY *.sh *.js /template/
RUN /template/setup.sh
# TODO: 'CMD eval $DC_COMMAND; ...' for improved performance on Windows

USER 1001
