FROM bitnami/wordpress:5.0.2 as builder

COPY *.sh *.js /template/
RUN /template/setup.sh
