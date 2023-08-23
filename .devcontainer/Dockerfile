# note: This Dockerfile is only meant for local development.
ARG IMG="mcr.microsoft.com/devcontainers/python:1-3.11-bullseye"

FROM "${IMG}"

# note: Use a safer, stricter shell than the default.
SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

# note: This is not a useful arg from the docker cli, but it is useful because
# ARG act like ENV during build, but are not persisted in the final image.
ARG DEBIAN_FRONTEND="noninteractive"

ARG REPO_DIR
ENV REPO_DIR="${REPO_DIR:-/code}"

ARG POETRY_VERSION
ENV POETRY_VERSION="1.6.1"

ARG PYTHONWARNINGS
ENV PYTHONWARNINGS=${PYTHONWARNINGS:-"once"}

# A useful flag in case we need to know that we are running in Docker.
ENV DOCKER="1"
ENV POETRY_VIRTUALENVS_CREATE="false"
ENV PYTHONDONTWRITEBYTECODE="1"
ENV PYTHONUNBUFFERED="1"

# todo: These extra dev packages should be reviewed and streamlined.
# question: Could we pull these from somewhere that would let devs customize them?
RUN apt-get update && apt-get -y install --no-install-recommends \
  build-essential \
  ca-certificates \
  exa \
  exuberant-ctags \
  fd-find \
  fzf \
  gettext \
  git \
  htop \
  jq \
  libmagic-dev \
  libpq-dev \
  libpython3-dev \
  postgresql-client-common \
  redis-tools \
  rsync \
  shellcheck \
  tree \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,id=root,target=/root/.cache \
  python -m pip install --no-input --upgrade \
  "poetry==${POETRY_VERSION}" \
  honcho \
  pipx

# note: Bake dependencies into the image because they should not change often.
COPY "backend/pyproject.toml" "/tmp/poetry-tmp/"
RUN --mount=type=cache,id=root,target=/root/.cache \
  poetry install \
  --directory "/tmp/poetry-tmp" \
  --no-directory \
  --no-interaction \
  --no-root

# thought: Install is handled devcontainer.json:postStartCommand, but doing it
# here could be handy for when running via docker/compose directly.
# COPY "backend/" "${REPO_DIR}/backend/"
# RUN --mount=type=cache,id=root,target=/root/.cache \
#   poetry install \
#   --directory "${REPO_DIR}/backend" \
#   --no-interaction \
#   --only-root

# note: The user `vscode` is setup by the microsoft devcontainer image.
USER vscode
WORKDIR "${REPO_DIR}"

# note: If a directory does not exist when a volume is mounted there it will be
# owned by `root`. To avoid permission issues we create them here so they are
# owned by `vscode` instead.
RUN mkdir -p "${REPO_DIR}/frontend/node_modules"
