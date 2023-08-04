#!/usr/bin/env -S just --justfile

# Config
# ======================================================================

set dotenv-load := true
set ignore-comments := true
# set shell := ["fish", "-c"]

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
	code .
