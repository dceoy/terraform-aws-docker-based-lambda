# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.12
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim AS base

ARG USER_UID=1001
ARG USER_GID=1001
ARG USER_NAME=batch

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=UTF-8
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
      groupadd --gid "${USER_GID}" "${USER_NAME}" \
      && useradd --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash --create-home "${USER_NAME}"

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

HEALTHCHECK NONE


FROM base AS app

ENV LANG=en_US.UTF-8
ENV TZ=:/etc/localtime
ENV PATH=/var/lang/bin:/usr/local/bin:/usr/bin/:/bin:/opt/bin
ENV LD_LIBRARY_PATH=/var/lang/lib:/lib64:/usr/lib64:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib:/opt/lib
ENV LAMBDA_TASK_ROOT=/var/task
ENV LAMBDA_RUNTIME_DIR=/var/runtime

RUN \
      mkdir -p "${LAMBDA_TASK_ROOT}" \
      && chown -R "${USER_NAME}:${USER_NAME}" "${LAMBDA_TASK_ROOT}"

USER "${USER_NAME}"

RUN \
      --mount=type=bind,source=.,target=/mnt/host \
      cp /mnt/host/main.py "${LAMBDA_TASK_ROOT}/"

WORKDIR ${LAMBDA_TASK_ROOT}

ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["main.lambda_handler"]
