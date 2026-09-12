### Introducción

El objetivo de este lab es la demostración de como
podemos desplegar de manera sencilla una función
en Google Cloud Function. Para este propósito vamos a
crear una función en Python cuyo "trigger" es
una llamada HTTP (para ver los posibles triggers
que acepta una cloud function, consultar la
[documentación oficial](https://cloud.google.com/functions/docs/concepts/events-triggers)).

### Función y Despliegue

Escribe una función en Python que reciba, en el cuerpo `JSON` de una petición HTTP,
dos valores `a` y `b` (los límites de un intervalo), y devuelva un `dict` con un
número aleatorio uniformemente distribuido en dicho intervalo. Si la petición no
trae los parámetros esperados, la función debe seguir funcionando con unos valores
por defecto razonables en lugar de fallar.

Declara en un `requirements.txt` las dependencias que necesites.

El despliegue de la *function* se hace con `gcloud functions deploy`, indicando:

- El punto de entrada (nombre de tu función Python).
- La región.
- El *runtime* de Python que vas a usar.
- Que el *trigger* es HTTP.
- Memoria y timeout razonables.
- Si va a admitir llamadas sin autenticar.

Una vez haya terminado el despliegue, Google SDK
nos informará de que se ha generado una URL
para la función. Pruébala con una petición `POST` con un cuerpo JSON del tipo
`{"a": 10, "b": 12}`, y comprueba que la respuesta es un JSON con un valor aleatorio en
ese intervalo.

### Liberación de los recursos

Para liberar recursos, recuerda borrar la función desplegada al terminar
(`gcloud functions delete`).
