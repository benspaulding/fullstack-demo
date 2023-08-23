# note: This Dockerfile could target both production and development environments.
ARG PYTHON_IMG="python:3.11-bullseye"

### Python Base Image
FROM ${PYTHON_IMG} as base
LABEL com.ourtilt.lang="python"
LABEL com.ourtilt.stack="backend"
LABEL com.ourtilt.step="base"

# note: Use a safer, stricter shell than the default.
SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

# note: This is not a useful arg from the docker cli, but it is useful because
# ARG act like ENV during build, but are not persisted in the final image.
ARG DEBIAN_FRONTEND="noninteractive"

ARG APP_USER
ENV APP_USER="${APP_USER:-app}"

ARG REPO_DIR
ENV REPO_DIR="${REPO_DIR:-/code}"

ARG VENV_DIR
ENV VENV_DIR="${VENV_DIR:-/venv}"

ENV DOCKER="1"
ENV LANG="C.UTF-8"
ENV PATH="${VENV_DIR}/bin:${PATH}"
ENV PYTHONUNBUFFERED="1"

ENV PIP_LOG="${VENV_DIR}/log/pip.log"
ENV PIP_SRC="${VENV_DIR}/src"

ENV VIRTUAL_ENV="${VENV_DIR}"
ENV VIRTUAL_ENV_DISABLE_PROMPT="1"
ENV POETRY_VIRTUALENVS_IN_PROJECT="false"

USER root

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN groupadd --gid 1024 "${APP_USER}" \
  && useradd --uid 1024 --gid "${APP_USER}" --shell /bin/bash --create-home "${APP_USER}"

RUN mkdir "${REPO_DIR}" && chown -R 1024:1024 "${REPO_DIR}"
RUN mkdir "${VENV_DIR}" && chown -R 1024:1024 "${VENV_DIR}"

# [FIXME] Find a way to get this in here with COPY.
# COPY docker-entrypoint.sh /usr/local/bin/
# ARG PY_ENTRY
# RUN printf -- '%b\n' ${PY_ENTRY} > /usr/local/bin/docker-entrypoint.sh \
# 	&& chmod 755 /usr/local/bin/docker-entrypoint.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  gettext \
  postgresql-client-common \
  redis-tools \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

USER "${APP_USER}"
WORKDIR "${REPO_DIR}"

# ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "${VENV_DIR}/bin/python" ]
##/ Python Base Image


### Python Build Image
FROM base as build
LABEL com.ourtilt.step="build"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"

ARG POETRY_VERSION
ENV POETRY_VERSION="1.6.1"

ARG PYTHONWARNINGS
ENV PYTHONWARNINGS=${PYTHONWARNINGS:-"once"}

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  libmagic-dev \
  libpq-dev \
  libpython3-dev \
  && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,id=root,target=/root/.cache \
  python -m pip install --no-input --upgrade "poetry==${POETRY_VERSION}"

RUN --mount=type=cache,id=root,target=/root/.cache \
  python -m venv --upgrade-deps "${VENV_DIR}" && . "${VENV_DIR}/bin/activate"

RUN chown -R 1024:1024 "${VENV_DIR}"

USER "${APP_USER}"
WORKDIR "${REPO_DIR}"

ARG PYPROJ_TOML="backend/pyproject.toml"
COPY --chown=1024:1024 "${PYPROJ_TOML}" "${PYPROJ_TOML}"
RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
  poetry install \
  --directory "${REPO_DIR}/backend" \
  --no-directory \
  --no-interaction \
  --no-root \
  --only main
##/ Python Build Image


### Python Prod Image
FROM base as prod
LABEL com.ourtilt.env="production"
LABEL com.ourtilt.step="built"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG PYTHONWARNINGS
ENV PYTHONWARNINGS=${PYTHONWARNINGS:-"default"}

USER "${APP_USER}"
WORKDIR "${REPO_DIR}/backend"

COPY --chown=1024:1024 ./backend "${REPO_DIR}/backend/"
COPY --chown=1024:1024 --from=build "${VENV_DIR}" "${VENV_DIR}/"

RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
  poetry install \
  --directory "${REPO_DIR}/backend" \
  --no-interaction \
  --only-root
##/ Python Prod Image


### Python Dev Image
FROM build as dev
LABEL com.ourtilt.env="development"
LABEL com.ourtilt.step="built"

ARG DEBIAN_FRONTEND="noninteractive"

ENV PYTHONDONTWRITEBYTECODE="1"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

USER root

# todo: These extra dev packages should be reviewed and streamlined.
# question: Could we pull these from somewhere that would let devs customize them?
RUN apt-get update && apt-get install -y --no-install-recommends \
  exa \
  exuberant-ctags \
  fd-find \
  fzf \
  htop \
  jq \
  neovim \
  rsync \
  shellcheck \
  telnet \
  tmux \
  tree \
  vim \
  zsh \
  && rm -rf /var/lib/apt/lists/*

RUN usermod -aG sudo "${APP_USER}" \
  && echo "${APP_USER} ALL=(ALL:ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${APP_USER}"

USER "${APP_USER}"
WORKDIR "${REPO_DIR}/backend"

COPY --chown=1024:1024 ./backend "${REPO_DIR}/backend/"

RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
  poetry install \
  --directory "${REPO_DIR}/backend" \
  --no-interaction

# note: If a directory does not exist when a volume is mounted there it will be
# owned by `root`. To avoid permission issues we create them here so they are
# owned by `$APP_USER` instead.
RUN mkdir "/home/${APP_USER}/.cache" "/home/${APP_USER}/.vscode-server"

# ARG PRECOMMIT_CFG=".pre-commit-config.yaml"
# COPY --chown=1024:1024 "${PRECOMMIT_CFG}" "${PRECOMMIT_CFG}"
# RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
# 	git init \
# 	&& python -m pre_commit install-hooks \
# 	&& rm -rf .git
##/ Python Dev Image
