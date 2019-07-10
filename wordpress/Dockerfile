FROM bitnami/wordpress:5.2.2 as builder

COPY *.sh *.js /template/
RUN /template/setup.sh

# TODO: 'CMD eval $DC_COMMAND; ...' for improved performance on Windows
