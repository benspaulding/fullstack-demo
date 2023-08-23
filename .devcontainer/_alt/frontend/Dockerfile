# note: This Dockerfile could target both production and development environments.
ARG NODE_IMG="node:18-bullseye"

### Node Base Image
FROM ${NODE_IMG} as base
LABEL com.ourtilt.lang="node"
LABEL com.ourtilt.stack="frontend"
LABEL com.ourtilt.step="base"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"

ARG APP_USER
ENV APP_USER="${APP_USER:-app}"

ARG REPO_DIR
ENV REPO_DIR="${REPO_DIR:-/code}"

ARG NODE_DIR
ENV NODE_DIR="${REPO_DIR}/frontend/node_modules"

ENV DOCKER="1"
ENV LANG="C.UTF-8"
ENV PATH="${NODE_DIR}/.bin:${PATH}"

USER root

RUN groupadd --gid 1024 "${APP_USER}" \
  && useradd --uid 1024 --gid "${APP_USER}"  --shell /bin/bash --create-home "${APP_USER}"

RUN mkdir "${REPO_DIR}" && chown -R 1024:1024 "${REPO_DIR}"

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
CMD [ "npm" ]
##/ Node Base Image


### Node Build Image
FROM base as build
LABEL com.ourtilt.step="build"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

ARG DEBIAN_FRONTEND="noninteractive"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  && rm -rf /var/lib/apt/lists/*

USER "${APP_USER}"
WORKDIR "${REPO_DIR}"

COPY --chown=1024:1024 "frontend/package*.json" "frontend/"

WORKDIR "${REPO_DIR}/frontend"
RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
  npm install --omit dev
##/ Node Build Image


### Node Prod Image
FROM base as prod
LABEL com.ourtilt.env="production"
LABEL com.ourtilt.step="built"

SHELL [ "/bin/bash", "+o", "errexit", "+o", "nounset", "+o", "pipefail", "-c" ]

USER "${APP_USER}"
WORKDIR "${REPO_DIR}/frontend"

COPY --chown=1024:1024 ./frontend "${REPO_DIR}/frontend/"
COPY --chown=1024:1024 --from=build "${NODE_DIR}" "${NODE_DIR}/"
##/ Node Prod Image


### Node Dev Image
FROM build as dev
LABEL com.ourtilt.env="development"
LABEL com.ourtilt.step="built"

ARG DEBIAN_FRONTEND="noninteractive"

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

RUN usermod -aG sudo "${APP_USER}"  \
  && echo "${APP_USER}  ALL=(ALL:ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${APP_USER}"

USER "${APP_USER}"
WORKDIR "${REPO_DIR}/frontend"

COPY --chown=1024:1024 ./frontend "${REPO_DIR}/frontend/"

RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
  npm install

# ARG PRECOMMIT_CFG=".pre-commit-config.yaml"
# COPY --chown=1024:1024 "${PRECOMMIT_CFG}" "${PRECOMMIT_CFG}"
# RUN --mount=type=cache,id=app,uid=1024,gid=1024,target=/home/app/.cache \
# 	git init \
# 	&& python -m pre_commit install-hooks \
# 	&& rm -rf .git
##/ Node Dev Image
