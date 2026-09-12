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
base de datos `Redis`, ambos dos servicios desplegados en GCP. Ya se te proporciona el
código de la App, compuesto por los ficheros:

- [app.py](app.py): Código Python de la aplicación
- [requirements.txt](requirements.txt): Manifiesto de las dependencias necesarias
- [Dockerfile](Dockerfile) y [entrypoint.sh](entrypoint.sh): Contenerización de la aplicación

La aplicación `Flask` expone:

- Método `POST` en el path `/`, que admita cargas `JSON` del tipo `{"name": "myName"}`
  que serán guardadas como entradas en la base de datos

- Método `GET` en el path `/`, que mostrará todos los registros guardados en la base
  de datos

- Método `POST` en el path `/reset`, que borrará la base de datos y mostrará
  el índice a posteriori (que estará en blanco)

### Objetivo: despliegue

Tu tarea es desplegar esta arquitectura de dos servicios en GCP. Los parámetros de
configuración (nombres, tipo de máquina, imagen de Redis, proyecto, puertos...) los
encontrarás/completarás en [config.ini](config.ini). En concreto tendrás que:

1. **Desplegar una VM en GCP con la imagen de Redis** (`gcloud compute instances
   create-with-container`), sirviendo por el puerto (TCP) `6379`.

2. **Construir la imagen Docker de la aplicación** (`docker build`), pasándole como
   *build-arg* la IP privada reservada para Redis, de manera que la App pueda
   establecer la conexión con ésta.

   Antes de subir la imagen al registry de Google, prueba que la imagen corre
   correctamente en local con Docker, contra un Redis también local. Al intentarlo
   verás que algo falla:

   ```shell
   docker run $app_image_uri
   ```

   ![alt text](images/error_environ.png)

   ¿Qué error da? ¿Por qué puede ser este error? ¿Cómo habría que corregirlo para
   poder probar la imagen en local antes de desplegarla en GCP?

3. **Publicar la imagen de la aplicación** en el *Artifact/Container Registry* asociado
   a tu proyecto GCP (`docker push`). Si el paso falla, revisa la autenticación de
   Docker contra el registry de Google.

4. **Desplegar una VM en GCP con la imagen de la aplicación**, indicándole mediante una
   variable de entorno la IP de la VM de Redis creada en el paso 1.

5. **Crear las reglas de `firewall`** necesarias para permitir el tráfico de entrada en
   los puertos que sirven la aplicación y Redis, restringiendo el origen a lo mínimo
   imprescindible.

Documenta en tu entrega los comandos que has utilizado en cada paso (puedes
automatizarlos en tu propio script, tomando como referencia el estilo de
[clean.sh](clean.sh)).

### Liberación de los recursos

Para evitar incurrir en gastos innecesarios que acabarían con nuestros créditos
gratuitos, procede a la limpieza del proyecto ejecutando el script [clean.sh](clean.sh):

```shell
chmod a+x clean.sh && ./clean.sh
```

#### 🔹 Prueba tu API con `curl`

Una vez desplegado, comprueba el comportamiento de la API con peticiones del estilo:

```bash
# Añadir un registro
curl -X POST http://<IP>:<PUERTO>/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice"}'

# Listar registros
curl http://<IP>:<PUERTO>/

# Resetear
curl -X POST http://<IP>:<PUERTO>/reset
```
