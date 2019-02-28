FROM bitnami/wordpress:5.1.0 as builder

COPY *.sh *.js /template/
RUN /template/setup.sh
