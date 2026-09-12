### Introducción

En el siguiente ejemplo vamos a profundizar un poco más en la automatización de los
despliegues de aplicaciones (interconectadas) mediante `gcloud`. En este proceso de
automatización vamos a introducir también algunos de los 12-factores (12F) que deben
componer una aplicación *nativa cloud* (*cloud native* en inglés), e.g.,
vamos a introducir la praxis de explicitar la configuración de la aplicación en un
fichero de parametrización, en este caso en concreto será [config.ini](config.ini),
así como declarar todas las dependencias en un manifiesto, en nuestro caso será
[requirements.txt](requirements.txt).

### Previo

- Instalar Docker en tu entorno de trabajo (WSL2/Linux/Mac). Si usas Ubuntu/WSL2 puedes
  seguir la [guía oficial de instalación de Docker Engine](https://docs.docker.com/engine/install/ubuntu/).

### La aplicación

Se trata de una aplicación sencilla escrita
en `python` (con `Flask`) la cual actúa como interfaz de comunicación con una
base de datos `Redis`, ambos dos servicios desplegados en GCP. La idea es que la
aplicación `Flask` exponga:

- Método `POST` en el path `/`, que admita cargas `JSON` del tipo `{"name": "myName"}`
  que serán guardadas como entradas en la base de datos

- Método `GET` en el path `/`, que mostrará todos los registros guardados en la base
  de datos

- Método `POST` en el path `/reset`, que borrará la base de datos y mostrará
  el índice a posteriori (que estará en blanco)

El código de la App está compuesto por los ficheros:

- [app.py](app.py): Código Python de la aplicación
- [requirements.txt](requirements.txt): Manifiesto de las dependencias necesarias
- [Dockerfile](Dockerfile) y [entrypoint.sh](entrypoint.sh): Contenerización de la aplicación

Los pasos necesarios son (ver [deployment.sh](deployment.sh)):

1. Desplegar una VM en GCP con la imagen de Redis, la cual estará sirviendo a través del puerto
   (TCP) `6379`:

   ```shell
   gcloud compute instances create-with-container $redis_server \
      --machine-type="$machine_type" \
      --container-image="$redis_image" \
      --quiet
   ```
   Las opciones de configuración de la máquina y de la imagen vienen dadas en el fichero
   [config.ini](config.ini).

2. Habilitar Artifact Registry y crear un repositorio Docker en tu proyecto (solo la
   primera vez), y autenticar Docker contra él:

   ```shell
   gcloud services enable artifactregistry.googleapis.com
   gcloud artifacts repositories create $REGISTRY_NAME \
       --repository-format=docker \
       --location=europe-southwest1 \
       --description="Repo docker practica 4"
   gcloud auth configure-docker europe-southwest1-docker.pkg.dev --quiet
   ```

   La variable de entorno `app_image_uri` se define como
   `app_image_uri="europe-southwest1-docker.pkg.dev/$PROJECT/$REGISTRY_NAME/$app_img"`,
   siendo `$PROJECT` el ID de nuestro proyecto y `$app_img` el nombre de la imagen de
   nuestra aplicación, tal y como viene explicitado en [config.ini](config.ini).

3. Contenerizar la aplicación (haciendo `docker build`), pasándole como argumento de
   construcción la IP reservada para Redis, de manera que la App pueda establecer la
   conexión con ésta:

   ```shell
   docker build --tag $app_image_uri \
       --build-arg REDIS_IP=$REDIS_VM_IP \
       .
   ```

   Antes de subir la imagen al registry de Google, vamos a probar que nuestra imagen
   corre correctamente con docker:

   ```shell
   docker run $app_image_uri
   ```

   ![alt text](images/error_environ.png)

   ¿Qué error da? ¿Por qué puede ser este error? ¿Cómo habría que corregirlo?

   ```shell
   docker run -p 6379:6379 redis
   docker run -e REDIS_IP_GCP=host.docker.internal -p 5000:5000 --add-host=host.docker.internal:host-gateway asr-flask:v.0.0.1
   ```

4. Publicar la imagen de la aplicación en nuestro Artifact Registry asociado al
   proyecto GCP:

   ```shell
   docker push "$app_image_uri"
   ```

5. Desplegar una VM en GCP con la imagen de la aplicación:

   ```shell
   gcloud compute instances create-with-container $app_name \
       --machine-type=$machine_type \
       --container-image=$app_image_uri \
       --tags=app-server \
       --container-env=REDIS_IP_GCP=$REDIS_VM_IP
   ```

6. Crear reglas de `firewall` para permitir tráfico de entrada en los puertos `5000`/`8080`
   (el que sirve el tráfico de `app.py`, ver `$app_port` en [config.ini](config.ini)) y
   `6379` (redis):

   ```shell
   gcloud compute firewall-rules create "default-allow-onlymyip-$app_port" \
       --direction=INGRESS \
       --priority=1000 \
       --network=default \
       --action=ALLOW \
       --rules=tcp:"$app_port" \
       --source-ranges=$(curl ifconfig.me) \
       --target-tags=app-server
   ```

Todo ello se podría haber ejecutado de forma automática agregando todos los pasos en el
siguiente script:
```shell
chmod a+x deployment.sh && ./deployment.sh
```
Esta podría ser nuestra primera infraestructura como código, pero veremos métodos más
avanzados de hacer esto.

### Liberación de los recursos

Para evitar incurrir en gastos innecesarios que acabarían con nuestros créditos
gratuitos, podemos proceder a la limpieza del proyecto ejecutando el script [clean.sh](clean.sh):

```shell
chmod a+x clean.sh && ./clean.sh
```

#### 🔹 Ejemplos con `curl`

```bash
#Añadir estudiante:
curl -X POST http://localhost:8080/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice"}'

#Añadir otro estudiante:
curl -X POST http://localhost:8080/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Bob"}'

#Listar estudiantes:
curl http://localhost:8080/

#Resetear lista de estudiantes:
curl -X POST http://localhost:8080/reset

#Resetear lista y añadir estudiante en un solo paso:
curl -X POST http://localhost:8080/reset \
     -H "Content-Type: application/json" \
     -d '{"name": "Charlie"}'
```
