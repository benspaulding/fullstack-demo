"""A basic Django project."""
import os

# This will make sure the celery app is always imported when
# Django starts so that shared_task will use this app.
from .celery import app as celery_app

__all__ = (
    "celery_app",
    "django_manage",
)


def django_manage():
    """Django's command-line utility for administrative tasks."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "djproj.settings")
    from django.core.management import execute_from_command_line

    execute_from_command_line()
