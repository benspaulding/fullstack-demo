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

## TODO

- setup pre-commit
- setup static file handling
- setup frontend profile
- setup backend profile
