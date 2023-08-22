ARG PYTHON_IMG="python:3.11-bullseye"

### Python Base Image
FROM ${PYTHON_IMG} as base
LABEL com.ourtilt.lang="python"
LABEL com.ourtilt.stack="backend"
LABEL com.ourtilt.step="base"
LABEL devcontainer.metadata='[{ \
  "remoteUser": "app", \
  "containerUser": "app" \
  "workspaceFolder": "/code" \
  }]'

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"

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

RUN groupadd --gid 1024 app \
  && useradd --uid 1024 --gid app --shell /bin/bash --create-home app

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

USER app
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

USER app
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

USER app
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

RUN apt-get update && apt-get install -y --no-install-recommends \
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

RUN usermod -aG sudo app \
  && echo "app ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/app

USER app
WORKDIR "${REPO_DIR}/backend"

COPY --chown=1024:1024 ./backend "${REPO_DIR}/backend/"

RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
  poetry install \
  --directory "${REPO_DIR}/backend" \
  --no-interaction

# Create folders that will probably have mounted volumes; this will cause the mounted
# volume to be owned by `app` instead of `root`.
RUN mkdir /home/app/.cache /home/app/.vscode-server

# ARG PRECOMMIT_CFG=".pre-commit-config.yaml"
# COPY --chown=1024:1024 "${PRECOMMIT_CFG}" "${PRECOMMIT_CFG}"
# RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
# 	git init \
# 	&& python -m pre_commit install-hooks \
# 	&& rm -rf .git
##/ Python Dev Image
