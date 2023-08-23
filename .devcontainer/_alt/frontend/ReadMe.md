# Frontend Dev Container

This dev container is an example of:

1. Running all processes in separate containers, as is recommended.
2. Using a Dockerfile that targets both production and development.

## Notes

Because every process runs in a different container if you alter the installed packages
in one they will not be reflected in the others. To add or remove packages you must
change the source, such as adding a package to `package.json`, and then rebuild all
containers.
