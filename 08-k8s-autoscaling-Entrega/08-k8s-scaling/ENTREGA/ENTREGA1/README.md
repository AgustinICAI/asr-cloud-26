# 🧪 Práctica: Pruebas de rendimiento con k6 en Kubernetes

## 🎯 Objetivo
Montar un **Job de Kubernetes** que lance una prueba de rendimiento usando **k6**.
El escenario de prueba se definirá en un **script de k6 (JavaScript)** que se cargará en el pod mediante un **ConfigMap**.
Al ejecutar el job, observaremos la salida del test desde los **logs del pod**.

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

---

## 🧾 ENTREGA

Debes entregar:

1. Los ficheros:
   - `k6-configmap.yaml`
   - `k6-job.yaml`
   - `test-script.js`
2. Una captura o fichero de texto con la **salida del test** (logs del pod o del logging del clúster).

El profesor podrá corregir ejecutando:

```bash
kubectl apply -f <folder_del_alumno>
```
