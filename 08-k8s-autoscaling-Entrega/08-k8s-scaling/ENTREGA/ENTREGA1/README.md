# 🧪 Entrega 1: Validar el autoescalado con una prueba de carga (k6)

## 🎯 Objetivo
Montar un **Job de Kubernetes** que lance una prueba de rendimiento usando **k6**
contra el `php-apache` y el `HorizontalPodAutoscaler` que configuraste en la
[práctica de autoescalado](../../README.md).
El escenario de prueba se definirá en un **script de k6 (JavaScript)** que se cargará en el pod mediante un **ConfigMap**.
Al ejecutar el job, observaremos tanto la salida del test (**logs del pod**) como el
efecto que tiene sobre el número de réplicas y de nodos del clúster.

---

## 🧱 1. Estructura de los ficheros

Tu entrega deberá contener al menos estos archivos:

```
/mi-practica-k6/
├── k6-configmap.yaml
├── k6-job.yaml
└── test-script.js
```

---

## 🗂️ 2. Definir el script de prueba (`test-script.js`)

Escribe un script simple en **JavaScript** (usando el módulo `k6/http`) que:

- Defina unos `options` con un número de usuarios virtuales (`vus`) y una `duration`.
- En la función por defecto, haga una petición `http.get` contra tu servicio
  `php-apache` (o, si quieres probar la herramienta primero, contra
  `https://test.k6.io`), compruebe con `check` que la respuesta es `200`, y añada un
  pequeño `sleep` entre iteraciones.

---

## 🧩 3. Crear un ConfigMap (`k6-configmap.yaml`)

El ConfigMap debe contener el script anterior como dato embebido (clave
`test-script.js`), de forma que después lo puedas montar como fichero dentro del pod.

---

## ⚙️ 4. Definir el Job de Kubernetes (`k6-job.yaml`)

Este Job debe usar la imagen oficial de **Grafana k6** (`grafana/k6`), montar el script
desde el ConfigMap anterior como un volumen, y ejecutar `k6 run` sobre dicho fichero.
Recuerda fijar `restartPolicy: Never`, ya que se trata de una tarea que se ejecuta una
única vez.

---

## 🚀 5. Desplegar en Kubernetes

Aplica el ConfigMap y el Job, y comprueba que el Job y sus pods se han creado
correctamente (`kubectl get jobs`, `kubectl get pods`).

---

## 📜 6. Ver los resultados

Cuando el Job haya terminado, consulta los resultados del test desde los logs del pod
(`kubectl logs`).

(En GCP u otra plataforma gestionada, también puedes ver los logs desde el **visor de logging**).

## 📈 7. Observar el autoescalado

Ajusta el número de usuarios virtuales (`vus`) y la `duration` de tu script para generar
carga sostenida suficiente. Mientras el Job de k6 está corriendo, observa en paralelo:

```bash
watch kubectl get hpa
watch kubectl get nodes
```

y comprueba que el número de réplicas de `php-apache` sube (HPA) y, si la carga es
suficiente, que se añaden nodos al clúster (Cluster Autoscaler / NAP).

---

## 🧾 ENTREGA

Debes entregar:

1. Los ficheros:
   - `k6-configmap.yaml`
   - `k6-job.yaml`
   - `test-script.js`
2. Una captura o fichero de texto con la **salida del test** (logs del pod o del logging del clúster).
3. Una captura de `kubectl get hpa` y `kubectl get nodes` (antes y durante el pico de carga) que muestre el efecto del autoescalado.

El profesor podrá corregir ejecutando:

```bash
kubectl apply -f <folder_del_alumno>
```
