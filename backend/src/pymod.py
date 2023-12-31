"""A basic Python module."""
import sys
from typing import NoReturn


def doit(thing: object) -> None:
    print(thing)


def main() -> NoReturn:
    arg = sys.argv[1] if len(sys.argv) > 1 else __name__
    doit(arg)
    sys.exit()


if __name__ == "__main__":
    main()
