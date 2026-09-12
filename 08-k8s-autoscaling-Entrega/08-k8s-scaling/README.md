# Autoescalado en Google Kubernetes Engine (GKE)

## Introducción

Google Kubernetes Engine (GKE) ofrece varias herramientas de autoescalado tanto a nivel de **pods** como de **infraestructura**.
En esta práctica verás cómo:

- Configurar un *Horizontal Pod Autoscaler* (HPA)
- Activar el *Cluster Autoscaler*
- Habilitar *Node Auto Provisioning* (NAP)
- Probar el comportamiento del cluster bajo picos de carga

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
para una aplicación de prueba (puedes usar la imagen `k8s.gcr.io/hpa-example`, que
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

## 4️⃣ Test de carga y observación del escalado

Genera carga simulada sobre el servicio PHP-Apache (por ejemplo, lanzando un pod
efímero que haga peticiones en bucle contra el servicio).

Mientras tanto, en otra terminal, observa cómo evolucionan el HPA y el Deployment.

Tras unos minutos, deberías poder observar:

- El número de réplicas del `php-apache` aumenta (HPA activo)
- Nuevos nodos se añaden al cluster (Cluster Autoscaler activo)
- Node pools adicionales creados (NAP activo)

---

## 5️⃣ Liberación de recursos

Cuando termines, borra todos los recursos que hayas creado (HPA, Deployment, Service y
finalmente el clúster).

---

## ✅ Resultado esperado

Al final del ejercicio habrás:

- Configurado un clúster GKE con autoescalado horizontal de pods (HPA)
- Activado el autoescalado de nodos (Cluster Autoscaler)
- Habilitado Node Auto Provisioning (NAP)
- Verificado el comportamiento ante picos de carga

Esto demuestra cómo GKE puede adaptarse automáticamente a la carga, optimizando costes y manteniendo la disponibilidad del servicio.
