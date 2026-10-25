#!/bin/sh
# Script de arranque para Gunicorn
# Usa exec para que el proceso principal reciba las señales correctamente
exec gunicorn "$PYTHON_APP:$FLASK_APP" -b ":$PORT" --timeout "$TIMEOUT"
