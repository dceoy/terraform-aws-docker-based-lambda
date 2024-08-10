# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.12
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim AS base

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=UTF-8
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on

RUN \
      rm -f /etc/apt/apt.conf.d/docker-clean \
      && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
        > /etc/apt/apt.conf.d/keep-cache

RUN \
      --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
      apt-get -y update \
      && apt-get -y upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates

RUN \
      --mount=type=cache,target=/root/.cache/pip \
      /usr/local/bin/python -m pip install -U --no-cache-dir \
        awslambdaric pip

ENV PYTHONPATH=/var/task

RUN \
      --mount=type=bind,source=.,target=/mnt/host \
      mkdir -p "${PYTHONPATH}" \
      && cp -a /mnt/host/app.py "${PYTHONPATH}/app.py"

HEALTHCHECK NONE

ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["app.lambda_handler"]
