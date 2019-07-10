FROM bitnami/wordpress:5.2.2 as builder

COPY *.sh *.js /template/
RUN /template/setup.sh
