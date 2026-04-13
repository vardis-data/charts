ARG BASE_IMAGE=pgduckdb/pgduckdb:17-v1.1.1
FROM ${BASE_IMAGE}

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-17-cron \
        postgresql-17-repack \
        postgresql-contrib-17 \
    && rm -rf /var/lib/apt/lists/*

USER 999
