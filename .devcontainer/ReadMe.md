# Example Fullstack Dev Container

_**Note**: VS Code only looks one level deep in `.devcontainer` for configurations. Thus
these are hidden **two** levels deep to keep them from cluttering the VS Code UI._

It can be tedious setting up a fullstack develpoment environtment using Docker Compose /
Dev Containers. The `devcontainer.json` in this directory (and its related Dockerfile,
Profcile, and Compose files) gives an example of how it might work.

When this devcontainer is paired with one of the `*.code-workspace` files in the root of
the repository one can easily start parts of the stack using preconfigured VS Code tasks
and run other parts directly in a shell.

## Usage

There are numerous ways to get working in a devcontainer -- opening the folder, a
`.code-workspace` file, using the VS Code Command Palette or clicking in extension
panels, etc. One possible way is to:

1. Open the repository in VS Code, or open one of the `*.code-workspace` files.
2. Use the Command Palette to "Dev Containers: Open Current Folder in Container", or
   click the `+` button in the the Remote Explorer -> Dev Containers panel.
3. Use the Command Palette to "Tasks: Run Task", then choose the part of the stack you
   want to run.
