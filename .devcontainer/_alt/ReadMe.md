# Alternate Dev Container Approach

It is possible that we want to use common and/or production Dockerfiles and Compose
files for development. This directory shows how that might work.

## Usage

The following paths must be children of the `.devcontainer` directory.

- `backend`
- `frontend`
- `compose.discrete.yaml`

You can execute the `./flip` script to link those, and `./flip flop` to unlink them.
