### Introducción

El objetivo de este lab es la demostración de como
podemos desplegar de manera sencilla una app en
Google Cloud Run.

## Prerrequisitos

1. Configuración de Proyecto: crea o usa un proyecto en Google Cloud y configura el SDK para usar ese proyecto:
```shell
gcloud config set project [YOUR_PROJECT_ID]
```

2. Habilitar APIs: Asegúrate de que las APIs de Cloud Run y Artifact Registry estén habilitadas (Container Registry, `gcr.io`, está en proceso de retirada por parte de Google: usa siempre Artifact Registry para imágenes nuevas):
```shell
gcloud services enable run.googleapis.com artifactregistry.googleapis.com
```

3. Crear un repositorio en Artifact Registry (solo la primera vez):
```shell
gcloud artifacts repositories create cloud-run-repo \
    --repository-format=docker \
    --location=[YOUR_REGION]
```

## Paso 1: Crear la Aplicación
Vamos a crear un archivo de Python que servirá como nuestra aplicación para Cloud Run.

Crea una carpeta para el proyecto:

```shell
mkdir cloud-run-example
cd cloud-run-example
```

Dentro de esta carpeta, crea un archivo llamado `app.py` con el siguiente código Python:
```python
# app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "¡Hola desde Cloud Run!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

## Paso 2: Crear un Dockerfile
Cloud Run ejecuta contenedores, así que vamos a crear un archivo Dockerfile para definir la imagen de Docker de nuestra aplicación.

En la misma carpeta (`cloud-run-example`), crea un archivo llamado `Dockerfile` con el siguiente contenido:

```dockerfile
# Dockerfile
FROM python:3.13-slim

# Establece el directorio de trabajo en /app
WORKDIR /app

# Copia los archivos necesarios
COPY app.py ./

# Instala Flask
RUN pip install Flask

# Expone el puerto 8080
EXPOSE 8080

# Comando para ejecutar la aplicación
CMD ["python", "app.py"]
```

## Paso 3: Construir y Subir la Imagen a Artifact Registry
Autentica Docker con Google Cloud, construye la imagen y súbela al repositorio de
Artifact Registry que creaste antes (reemplaza `[YOUR_PROJECT_ID]` y `[YOUR_REGION]`):

```shell
gcloud auth configure-docker [YOUR_REGION]-docker.pkg.dev
docker build -t [YOUR_REGION]-docker.pkg.dev/[YOUR_PROJECT_ID]/cloud-run-repo/cloud-run-example .
docker push [YOUR_REGION]-docker.pkg.dev/[YOUR_PROJECT_ID]/cloud-run-repo/cloud-run-example
```

## Paso 4: Desplegar en Cloud Run
Ahora que la imagen está en Artifact Registry, vamos a desplegarla en Cloud Run
(reemplaza `[YOUR_PROJECT_ID]` y `[YOUR_REGION]`):

```shell
gcloud run deploy cloud-run-example \
    --image [YOUR_REGION]-docker.pkg.dev/[YOUR_PROJECT_ID]/cloud-run-repo/cloud-run-example \
    --platform managed \
    --region [YOUR_REGION] \
    --allow-unauthenticated
```

- `--platform managed`: despliega en la plataforma de Cloud Run completamente gestionada.
- `--region [YOUR_REGION]`: ubicación donde se desplegará el servicio (usa la misma que en los pasos anteriores).
- `--allow-unauthenticated`: permite que el servicio sea accesible públicamente.

Cuando termine el despliegue, verás una URL en la salida del comando. Esta URL es el endpoint público de tu aplicación en Cloud Run.

## Paso 5: Probar el Servicio
Visita la URL proporcionada por Cloud Run en tu navegador, y deberías ver la respuesta ¡Hola desde Cloud Run!.

## Paso 6: Limpiar Recursos (Opcional)
Si quieres evitar costos innecesarios, elimina el servicio de Cloud Run y la imagen de Artifact Registry.

Borra el servicio de Cloud Run:

```shell
gcloud run services delete cloud-run-example --region [YOUR_REGION]
```

Borra la imagen de Docker de Artifact Registry:

```shell
gcloud artifacts docker images delete [YOUR_REGION]-docker.pkg.dev/[YOUR_PROJECT_ID]/cloud-run-repo/cloud-run-example
```
