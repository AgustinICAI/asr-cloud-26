# 🧪 Práctica: Pruebas de rendimiento con Locust en Kubernetes

## 🎯 Objetivo
Montar un **cluster de Locust** para ejecutar pruebas de rendimiento en un servicio web.
El cluster estará compuesto por un **pod Master** (servidor web y orquestador) y varios **pods Worker** (que lanzan la carga).

---

## 🧱 1. Estructura de los ficheros

Tu entrega deberá contener al menos estos archivos:

```
/mi-practica-locust/
├── Dockerfile
├── locustfile.py
├── master-deployment.yaml
└── worker-deployment.yaml
```

---

## 🧩 2. Crear la imagen Docker con Locust

Parte de la imagen oficial de Python e instala Locust (`pip install locust`). Copia a la
imagen tu script de pruebas (`locustfile.py`) y define `locust` como `ENTRYPOINT`.

## 🗂️ 3. Script de prueba (locustfile.py)

Escribe una clase `HttpUser` (con un `wait_time` entre peticiones) que defina, al menos,
una `@task` que haga una petición contra el path `/` de tu servicio a testear.

## ⚙️ 4. Desplegar Locust en Kubernetes

a) **Deployment del Master** (`master-deployment.yaml`): una réplica de tu imagen,
lanzando Locust en modo `--master`, exponiendo el puerto del dashboard (`8089`).

b) **Deployment de los Workers** (`worker-deployment.yaml`): varias réplicas de tu
imagen, lanzando Locust en modo `--worker`, apuntando al `--master-host` del Deployment
anterior (usa el nombre del Service/Deployment del master para la resolución DNS interna).

## 🚀 5. Desplegar en Kubernetes

Aplica ambos manifiestos y comprueba que los pods están en marcha. Accede al dashboard
de Locust (puerto 8089 del Master) para iniciar las pruebas.

## 📜 6. Entrega

Debes entregar:

Los ficheros:

- Dockerfile
- locustfile.py
- master-deployment.yaml
- worker-deployment.yaml

Un PDF con pantallazos de la ejecución de Locust, mostrando:

- Pruebas con distintas réplicas de servidor.

- Pruebas con HPA.

El profesor podrá corregir aplicando:

```bash
docker build -t gcr.io/$PROJECT/locust:v0.0.1 .
kubectl apply -f master-deployment.yaml
kubectl apply -f worker-deployment.yaml
```
