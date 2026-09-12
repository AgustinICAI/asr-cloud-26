# 🧪 Práctica: Pruebas de rendimiento con ApacheBench (ab) en Kubernetes

## 🎯 Objetivo
Montar un **Job de Kubernetes** que ejecute pruebas de rendimiento usando **ApacheBench (ab)**.
El objetivo es comprender cómo ejecutar tareas **efímeras** en Kubernetes, crear imágenes personalizadas con **Docker** y lanzar cargas controladas sobre un servicio.

---

## 🧱 1. Estructura de los ficheros

Tu entrega deberá contener al menos estos archivos:

```
/mi-practica-ab/
├── Dockerfile
└── job.yaml
```

---

## 🧩 2. Crear la imagen Docker con ApacheBench

Parte de una imagen base de **Ubuntu**, e instala ApacheBench (`ab`), incluido en el
paquete `apache2-utils`. Define como `ENTRYPOINT` el propio binario `ab`.

---

## 🐳 3. Crear y subir la imagen al registry de Google Cloud

1. Compila tu imagen Docker.
2. Autentica Docker contra tu registry si es necesario.
3. Publica la imagen en tu registry.

---

## ⚙️ 4. Definir el Job en Kubernetes (`job.yaml`)

Lanza **ApacheBench** como **Job** (una única ejecución, `restartPolicy: Never`), con un
`command` que invoque `ab` con un número de peticiones y concurrencia a tu elección,
contra la URL de tu servicio `php-apache`.

---

## 🚀 5. Desplegar en Kubernetes

Aplica el Job y comprueba que se ha creado correctamente, junto con sus pods.

---

## 📜 6. Ver los resultados

Consulta los resultados de la prueba en los logs del pod.

(En GCP u otra plataforma gestionada, también puedes ver los logs desde el **visor de logging**).

---

## 🧾 ENTREGA

Debes entregar:

1. Los ficheros:
   - `Dockerfile`
   - `job.yaml`
2. Una captura o fichero de texto con la **salida del test** (logs del pod o del logging del clúster).

El profesor podrá corregir ejecutando:

```bash
docker build .
kubectl apply -f job.yaml
```

💡 *Nota:* En entornos reales, también se podría usar un CronJob para ejecutar la prueba de forma periódica.
