FROM bitnami/wordpress:5.1.1 as builder

COPY *.sh *.js /template/
RUN /template/setup.sh
