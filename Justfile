#!/usr/bin/env -S just --justfile

# Config
# ======================================================================

set dotenv-load := true
set ignore-comments := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# Short names for commonly used functions
FROM := invocation_directory()
HERE := justfile_directory()
SELF := justfile()
SHLL := `test -n "$0" && echo "$0" || basename "$(status fish-path)"`

# Export more explicit names for other scripts to use
export JUST_RUN_PATH := FROM
export JUST_SRC_PATH := HERE
export JUSTFILE := SELF
export JUST_SHELLISH := SHLL

# Handy bits
t := "true"
f := "false"

export HOMEBREW_BUNDLE_NO_LOCK := "1"
export HOMEBREW_NO_INSECURE_REDIRECT := "1"

export COMPOSE_FILE := env_var_or_default("COMPOSE_FILE", ".devcontainer/compose.yaml")
export COMPOSE_PROJECT_NAME := env_var_or_default("COMPOSE_PROJECT_NAME", "fullstack-demo")


# Aliases
# ======================================================================

alias h := help
alias i := install


# Recipes
# ======================================================================

## General
## ---------------------------------------------------------------------

# run this recipe if no arguments are given (by virtue of it being the *first* recipe)
@_default: ls

# list available recipes
@ls:
	"{{ SELF }}" --list --unsorted

# print help info & list available recipes
@help: && ls
	"{{ SELF }}" --help

# check that tooling is configured
@check:
	brew bundle check

# install necessary project tools
@install:
	brew bundle install
	# curl -sSL https://install.python-poetry.org | python3 -
	# cd backend && poetry install

# open project in VS Code
@open:
	open -ga Docker
	code .


# https://docs.celeryq.dev/en/latest/userguide/monitoring.html#celery-events-curses-monitor
# celery -A dproj control enable_events
# celery -A djproj events

# https://docs.celeryq.dev/en/latest/userguide/monitoring.html#commands
# celery shell
# celery purge

# https://docs.celeryq.dev/en/latest/userguide/monitoring.html#flower-real-time-celery-web-monitor
# celery -A djproj flower --port=${CELERY_PORT}

# start compose stack
up *services:
	docker compose \
		--file "${COMPOSE_FILE}" \
		--project-name "${COMPOSE_PROJECT_NAME}" \
		up \
		--detach \
		--remove-orphans \
		--renew-anon-volumes \
		{{ services }}

# stop docker compose stack
dn *services:
	#!/usr/bin/env bash
	set -euo pipefail

	# todo: Do not error if project is already paused, stopped, or down.
	# note: Cannot pass COMPOSE_PROJECT_NAME as a service if COMPOSE_FILE env var is set.
	if [ ! "${COMPOSE_FILE}" -a ! "{{ services }}" ]; then
		docker compose down --remove-orphans "${COMPOSE_PROJECT_NAME}"
	else
		docker compose down --remove-orphans {{ services }}
	fi

	# todo: Only run this if `--volumes` was not passed to `docker compose down`
	"{{ SELF }}" rm-data

# remove named volumes that should not persist
rm-data +volumes="node-modules venv-dir":
	#!/usr/bin/env bash
	set -euo pipefail

	# todo: Use `{{ volumes }}` arg in `jq` filter.
	# todo: Remove all project volumes if `volumes` is `--all`
	# todo: Do not error if volume(s) do not exist.
	volume_names=$(docker compose -f .devcontainer/compose.yaml config --format json | \
		jq -r '.volumes | [."node-modules", ."venv-dir"][].name')
	docker volume rm $volume_names
