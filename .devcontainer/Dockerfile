ARG PYTHON_IMG="python:3.11-bullseye"
# ARG PYTHON_IMG="mcr.microsoft.com/devcontainers/python:3.11-bullseye"
# https://mcr.microsoft.com/en-us/product/devcontainers/python/about

####
### Python Images
####

### Python Base Image
FROM ${PYTHON_IMG} as base
LABEL com.ourtilt.lang="python"
LABEL com.ourtilt.stack="backend"
LABEL com.ourtilt.stage="base"

ENV DOCKER=1

ARG REPO_DIR
ENV REPO_DIR="${REPO_DIR:-/code}"
# ENV VENV_DIR="${REPO_DIR}/.venv"
ARG VENV_DIR
ENV VENV_DIR="${VENV_DIR}/venv"

ENV LANG="C.UTF-8"
ENV PATH="${VENV_DIR}/bin:${PATH}"
# ENV PYTHONPATH="${REPO_DIR}/backend:${PYTHONPATH}"
ENV PYTHONUNBUFFERED="1"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"

USER root

RUN groupadd --gid 1024 tilt \
	&& useradd --uid 1024 --gid tilt --shell /bin/bash --create-home tilt

RUN mkdir "${REPO_DIR}" && chown -R 1024:1024 "${REPO_DIR}"
RUN mkdir "${VENV_DIR}" && chown -R 1024:1024 "${VENV_DIR}"

# [FIXME] Find a way to get this in here with COPY.
# COPY docker-entrypoint.sh /usr/local/bin/
# ARG PY_ENTRY
# RUN printf -- '%b\n' ${PY_ENTRY} > /usr/local/bin/docker-entrypoint.sh \
# 	&& chmod 755 /usr/local/bin/docker-entrypoint.sh

RUN apt-get update && apt-get install -yqq --no-install-recommends \
	ca-certificates \
	gettext \
	postgresql-client-common \
	redis-tools \
	tzdata \
	&& rm -rf /var/lib/apt/lists/*

USER tilt
WORKDIR "${REPO_DIR}"
RUN mkdir "${REPO_DIR}/backend"

# ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "${VENV_DIR}/bin/python" ]
##/ Python Base Image


### Python Build Image
FROM base as build
LABEL com.ourtilt.stage="build"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"
ARG PIP_NO_INPUT="1"
ARG VIRTUALENV_VERSION="20.13.0"

ENV VIRTUALENV_NO_PERIODIC_UPDATE="1"
ENV VIRTUALENV_PIP="23.2.1"
ENV VIRTUALENV_SETUPTOOLS="60.6.0"
ENV VIRTUALENV_WHEEL="0.37.1"

ARG PYTHONWARNINGS
ENV PYTHONWARNINGS=${PYTHONWARNINGS:-"once"}

USER root

RUN apt-get update && apt-get install -yqq --no-install-recommends \
	build-essential \
	git \
	libmagic-dev \
	libpq-dev \
	python3.8-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,id=root,target=/root/.cache \
	python -m pip install --upgrade "virtualenv==${VIRTUALENV_VERSION}"

USER tilt
WORKDIR "${REPO_DIR}/backend"

RUN --mount=type=cache,id=tilt,uid=1024,gid=1024,target=/home/tilt/.cache \
	python -m virtualenv "${VENV_DIR}" && . "${VENV_DIR}/bin/activate"

ENV PIP_LOG="${VENV_DIR}/log/pip.log"
ENV PIP_SRC="${VENV_DIR}/src"
ENV PIP_PREFER_BINARY="1"

ARG PYTHON_REQS="backend/requirements.txt"
COPY --chown=1024:1024 "${PYTHON_REQS}" "${PYTHON_REQS}"
RUN --mount=type=cache,id=tilt,uid=1024,gid=1024,target=/home/tilt/.cache \
	python -m pip install -r "${PYTHON_REQS}"
##/ Python Build Image


### Python Prod Image
FROM base as prod
LABEL com.ourtilt.env="production"
LABEL com.ourtilt.stage="built"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"

ARG PYTHONWARNINGS
ENV PYTHONWARNINGS=${PYTHONWARNINGS:-"default"}

USER tilt
WORKDIR "${REPO_DIR}/backend"

COPY --chown=1024:1024 . "${REPO_DIR}/backend/"
COPY --chown=1024:1024 --from=build "${REPO_DIR}/backend" "${REPO_DIR}/backend/"
COPY --chown=1024:1024 --from=build "${VENV_DIR}" "${VENV_DIR}/"
##/ Python Prod Image


### Python Dev Image
FROM build as dev
LABEL com.ourtilt.env="development"
LABEL com.ourtilt.stage="built"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"
ARG PIP_NO_INPUT="1"

ENV PYTHONDONTWRITEBYTECODE=1

USER root

RUN apt-get update && apt-get install -yqq --no-install-recommends \
	exa \
	exuberant-ctags \
	fd-find \
	fish \
	fzf \
	htop \
	jq \
	neovim \
	rsync \
	screen \
	shellcheck \
	sudo \
	telnet \
	tmux \
	tree \
	vim \
	zsh \
	&& rm -rf /var/lib/apt/lists/*

RUN usermod -aG sudo tilt \
	&& echo "tilt ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/tilt

USER tilt
WORKDIR "${REPO_DIR}/backend"

ARG PYTHON_REQS_DEV="backend/requirements-dev.txt"
COPY --chown=1024:1024 "${PYTHON_REQS_DEV}" "${PYTHON_REQS_DEV}"
RUN --mount=type=cache,id=tilt,uid=1024,gid=1024,target=/home/tilt/.cache \
	python -m pip install -r "${PYTHON_REQS_DEV}"

# ARG PRECOMMIT_CFG=".pre-commit-config.yaml"
# COPY --chown=1024:1024 "${PRECOMMIT_CFG}" "${PRECOMMIT_CFG}"
# RUN --mount=type=cache,id=tilt,uid=1024,gid=1024,target=/home/tilt/.cache \
# 	git init \
# 	&& python -m pre_commit install-hooks \
# 	&& rm -rf .git
##/ Python Dev Image

####
##/ Python Images
####
