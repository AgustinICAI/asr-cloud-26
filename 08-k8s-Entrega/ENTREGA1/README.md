# 🧪 Entrega 1: Validar el autoescalado con una prueba de carga (k6)

## 🎯 Objetivo

Google Kubernetes Engine (GKE) ofrece varias herramientas de autoescalado tanto a
nivel de **pods** como de **infraestructura**. En esta entrega vas a:

- Configurar un *Horizontal Pod Autoscaler* (HPA) sobre una aplicación de prueba.
- Activar el *Cluster Autoscaler* y *Node Auto Provisioning* (NAP) a nivel de clúster.
- Validar el autoescalado con una prueba de carga real hecha con **k6**, montada como
  un **Job de Kubernetes**.

Trabajaremos de forma **declarativa**, utilizando **ficheros YAML** y comandos `kubectl apply`.

---

## 1️⃣ Preparación del entorno

Configura tu zona de cómputo y crea un clúster GKE que tenga habilitado el
**autoescalado de nodos** (piensa en qué flags de `gcloud container clusters create`
activan el autoescalado y fijan un número mínimo y máximo de nodos), con un tamaño de
disco razonable por nodo y el *release channel* `rapid`.

Obtén las credenciales del cluster recién creado.

---

## 2️⃣ Despliegue de la aplicación PHP-Apache

Crea un fichero `php-apache.yaml` con un `Deployment` (varias réplicas) y un `Service`
para una aplicación de prueba (puedes usar la imagen `registry.k8s.io/hpa-example`, que
sirve contenido por el puerto 80). Al contenedor asígnale unos `requests`/`limits` de
CPU modestos, ya que la carga de CPU será la métrica que dispare el autoescalado.

Aplica el manifiesto y verifica que el `Deployment` está en marcha.

---

## 3️⃣ Autoescalado horizontal (HPA)

Crea un fichero `php-apache-hpa.yaml` con un `HorizontalPodAutoscaler` (API
`autoscaling/v2`) que apunte al `Deployment` anterior, con un mínimo y máximo de
réplicas a tu elección, y como métrica el uso medio de CPU (`averageUtilization`)
sobre un umbral razonable (por ejemplo, 50%).

Aplica el HPA y comprueba su estado con `kubectl get hpa`.

---

## 4️⃣ Prueba de carga con k6

Vamos a montar un **Job de Kubernetes** que lance una prueba de rendimiento usando
**k6** contra el `Service` de `php-apache` y el HPA configurados en los pasos
anteriores. El escenario de prueba se definirá en un **script de k6 (JavaScript)** que
se cargará en el pod mediante un **ConfigMap**.

### 🧱 Estructura de los ficheros

Tu entrega deberá contener al menos estos archivos:

```
/mi-practica-k6/
├── k6-configmap.yaml
├── k6-job.yaml
└── test-script.js
```

### 🗂️ Definir el script de prueba (`test-script.js`)

Escribe un script simple en **JavaScript** (usando el módulo `k6/http`) que:

- Defina unos `options` con un número de usuarios virtuales (`vus`) y una `duration`.
- En la función por defecto, haga una petición `http.get` contra tu servicio
  `php-apache` (o, si quieres probar la herramienta primero, contra
  `https://test.k6.io`), compruebe con `check` que la respuesta es `200`, y añada un
  pequeño `sleep` entre iteraciones.

### 🧩 Crear un ConfigMap (`k6-configmap.yaml`)

El ConfigMap debe contener el script anterior como dato embebido (clave
`test-script.js`), de forma que después lo puedas montar como fichero dentro del pod.

### ⚙️ Definir el Job de Kubernetes (`k6-job.yaml`)

Este Job debe usar la imagen oficial de **Grafana k6** (`grafana/k6`), montar el script
desde el ConfigMap anterior como un volumen, y ejecutar `k6 run` sobre dicho fichero.
Recuerda fijar `restartPolicy: Never`, ya que se trata de una tarea que se ejecuta una
única vez.

### 🚀 Desplegar en Kubernetes

Aplica el ConfigMap y el Job, y comprueba que el Job y sus pods se han creado
correctamente (`kubectl get jobs`, `kubectl get pods`).

### 📜 Ver los resultados

Cuando el Job haya terminado, consulta los resultados del test desde los logs del pod
(`kubectl logs`).

(En GCP u otra plataforma gestionada, también puedes ver los logs desde el **visor de logging**).

---

## 5️⃣ Observar el autoescalado

Ajusta el número de usuarios virtuales (`vus`) y la `duration` de tu script para generar
carga sostenida suficiente. Mientras el Job de k6 está corriendo, observa en paralelo:

```bash
watch kubectl get hpa
watch kubectl get nodes
```

y comprueba que el número de réplicas de `php-apache` sube (HPA) y, si la carga es
suficiente, que se añaden nodos al clúster (Cluster Autoscaler / NAP).

---

## 6️⃣ Liberación de recursos

Cuando termines, borra todos los recursos que hayas creado (Job, ConfigMap, HPA,
Deployment, Service y finalmente el clúster).

---

## 🧾 ENTREGA

Debes entregar:

1. Los ficheros:
   - `php-apache.yaml`
   - `php-apache-hpa.yaml`
   - `k6-configmap.yaml`
   - `k6-job.yaml`
   - `test-script.js`
2. Una captura o fichero de texto con la **salida del test** (logs del pod o del logging del clúster).
3. Una captura de `kubectl get hpa` y `kubectl get nodes` (antes y durante el pico de carga) que muestre el efecto del autoescalado.

El profesor podrá corregir ejecutando:

```bash
kubectl apply -f <folder_del_alumno>
```
