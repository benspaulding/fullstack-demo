# Fullstack Project

## Setup

1. Clone this repository to your Mac:

   ```sh
   git clone ssh://github.com/benspaulding/fullstack-demo
   ```

2. Run the `./setup` command the first time you work on the project:

   ```sh
   cd fullstack-demo
   ./setup
   ```

While the `./setup` script is safe to run again, there is no need or benefit.

## Development

After the `./setup` script has been run once, daily work can be started with `just`
recipies:

```sh
just install
just open
```

You can work in a container with VS Code by using the Dev Containers extension, or by
spinning up the stack directly with either the `just up` recipe or directly with
`docker compose`, then getting a shell to a container, or attaching VS Code to the
container using the Docker extension.

## TODO

- setup pre-commit
- setup static file handling
