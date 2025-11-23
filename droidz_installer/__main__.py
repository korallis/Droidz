"""Allow execution via python -m droidz_installer."""

from .cli import main

if __name__ == "__main__":
    raise SystemExit(main())
