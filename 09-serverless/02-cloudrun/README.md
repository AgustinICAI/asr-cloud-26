### Introducción

El objetivo de este lab es la demostración de como
podemos desplegar de manera sencilla una app en
Google Cloud Run.

## Prerrequisitos

1. Configuración de Proyecto: usa un proyecto en Google Cloud y configura el SDK para usar ese proyecto:
```shell
gcloud config set project [YOUR_PROJECT_ID]
```

2. Habilitar APIs: Asegúrate de que las APIs de Cloud Run y Container/Artifact Registry estén habilitadas:
```shell
gcloud services enable run.googleapis.com containerregistry.googleapis.com
```

## Paso 1: Crear la Aplicación
Crea una carpeta para el proyecto y, dentro, un fichero `app.py` con una aplicación
Flask mínima que, en la ruta `/`, devuelva un mensaje de bienvenida (por ejemplo,
"¡Hola desde Cloud Run!"). Recuerda que Cloud Run espera que la aplicación escuche en
el host `0.0.0.0` y en el puerto `8080`.

## Paso 2: Crear un Dockerfile
Cloud Run ejecuta contenedores, así que necesitas un `Dockerfile` que:

- Parta de una imagen base de Python.
- Copie tu aplicación.
- Instale Flask.
- Exponga el puerto `8080`.
- Arranque la aplicación al iniciar el contenedor.

## Paso 3: Construir y Subir la Imagen al Registry
Autentica Docker con Google Cloud, construye la imagen y súbela a tu registry
(reemplaza `[YOUR_PROJECT_ID]` con el ID de tu proyecto):

```shell
gcloud auth configure-docker
docker build -t gcr.io/[YOUR_PROJECT_ID]/cloud-run-example .
docker push gcr.io/[YOUR_PROJECT_ID]/cloud-run-example
```

## Paso 4: Desplegar en Cloud Run
Despliega la imagen en Cloud Run (`gcloud run deploy`), indicando la plataforma
gestionada, la región, y si el servicio va a admitir tráfico sin autenticar.

## Paso 5: Probar el Servicio
Visita la URL proporcionada por Cloud Run en tu navegador, y comprueba que ves el
mensaje de tu aplicación.

## Paso 6: Limpiar Recursos (Opcional)
Si quieres evitar costos innecesarios, elimina el servicio de Cloud Run y la imagen del registry.
