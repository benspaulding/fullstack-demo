# Alternate Dev Container Approach

_**Note**: VS Code only looks one level deep in `.devcontainer` for configurations. Thus
these are hidden **two** levels deep to keep them from cluttering the VS Code UI._

It is possible that we want to use common and/or production Dockerfiles and Compose
files for development. This directory shows how that might work.

## Usage

The following paths must be children of the `.devcontainer` directory.

- `backend`
- `frontend`
- `compose.discrete.yaml`

You can execute the `./flip` script to link those, and `./flip flop` to unlink them.
