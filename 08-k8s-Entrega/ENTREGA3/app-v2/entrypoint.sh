#!/bin/sh
# Script de arranque para Gunicorn
# Usa exec para que el proceso principal reciba las señales correctamente
# --access-logfile - : escribe una línea por cada petición en stdout (la recoge Cloud Logging)
exec gunicorn "$PYTHON_APP:$FLASK_APP" -b ":$PORT" --timeout "$TIMEOUT" --access-logfile -
