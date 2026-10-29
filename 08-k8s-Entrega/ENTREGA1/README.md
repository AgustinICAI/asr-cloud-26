# 🧪 Entrega 1: Validar el autoescalado con una prueba de carga (k6)

## 🎯 Objetivo

Google Kubernetes Engine (GKE) ofrece varias herramientas de autoescalado tanto a
nivel de **pods** como de **infraestructura**. En esta entrega vas a partir de la
aplicación **Flask + Redis** que desplegaste en la
[práctica 07](../../07-k8s-init/README.md) y vas a:

- Configurar un *Horizontal Pod Autoscaler* (HPA) sobre la aplicación Flask (`asr-flask`).
- Activar el *Cluster Autoscaler* y *Node Auto Provisioning* (NAP) a nivel de clúster.
- Validar el autoescalado con una prueba de carga real hecha con **k6**, montada como
  un **Job de Kubernetes**.

Trabajaremos de forma **declarativa**, utilizando **ficheros YAML** y comandos `kubectl apply`.

---

## 1️⃣ Preparación del entorno

Crea un clúster GKE con el **autoescalado de nodos** (Cluster Autoscaler) y **Node
Auto Provisioning** habilitados y el *release channel* `rapid`. Obtén sus credenciales.

El clúster debe cumplir los [requisitos de seguridad comunes](../README.md#-requisitos-de-seguridad-comunes-a-las-3-entregas)
del lab (nodos privados con Cloud NAT, plano de control restringido a tu IP y Services
`LoadBalancer` restringidos a IPs de confianza).

---

## 2️⃣ Despliegue de la aplicación Flask + Redis

Despliega en el nuevo clúster la aplicación Flask + Redis de la práctica 07 (app y
Redis, cada uno con su `Service`) y comprueba que funciona.

Todos los manifiestos deben poder aplicarse directamente con `kubectl apply -f`, sin
ningún paso previo de sustitución.

---

## 3️⃣ Autoescalado horizontal (HPA)

Crea un fichero `app-hpa.yaml` con un `HorizontalPodAutoscaler` (API
`autoscaling/v2`) sobre la aplicación Flask, que escale en función del uso medio de CPU.

---

## 4️⃣ Prueba de carga con k6

Monta un **Job de Kubernetes** que lance una prueba de rendimiento con **k6**
(imagen oficial `grafana/k6`) contra la aplicación Flask. El escenario de prueba se
definirá en un **script de k6 (JavaScript)** que se cargará en el pod mediante un
**ConfigMap**.

Consulta los resultados del test cuando el Job termine.

---

## 5️⃣ Observar el autoescalado

Genera carga suficiente para que se dispare el autoescalado de pods (HPA) y de nodos
(Cluster Autoscaler / NAP), y observa cómo sube y cómo vuelve a bajar.

---

## 6️⃣ Liberación de recursos

Cuando termines, borra todos los recursos que hayas creado.

---

## 🧾 ENTREGA

Debes entregar:

1. Una carpeta con todos los ficheros necesarios, al menos:
   - los manifiestos de la aplicación Flask + Redis,
   - `app-hpa.yaml`
   - `k6-configmap.yaml`
   - `k6-job.yaml`
   - `test-script.js`
2. Evidencia de que se cumplen los requisitos de seguridad comunes (incluido el
   comando con el que has creado el clúster).
3. Una captura o fichero de texto con la **salida del test**.
4. Capturas (antes y durante el pico de carga) que muestren el efecto del autoescalado
   de pods y de nodos.
5. Una respuesta razonada: ¿tendría sentido aplicar también un HPA a Redis?

El profesor podrá corregir ejecutando:

```bash
kubectl apply -f <folder_del_alumno>
```
