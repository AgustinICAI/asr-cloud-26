# ============================
# Dockerfile optimizado para Python + Flask + Gunicorn
# ============================

# Imagen base oficial de Python
FROM python:3.12-slim

# Establecer directorio de trabajo
WORKDIR /usr/src/app

# Copiar requirements.txt e instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto de la aplicación
COPY . .

# Variables de entorno por defecto (puedes sobrescribirlas al correr el contenedor)
ENV PYTHON_APP=app \
    FLASK_APP=app \
    PORT=8080 \
    TIMEOUT=60

# Copiar y configurar script de arranque
COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

# Exponer puerto de la aplicación
EXPOSE $PORT

# CMD usando script de arranque (exec form) para manejar bien señales y variables
CMD ["/usr/src/app/entrypoint.sh"]
