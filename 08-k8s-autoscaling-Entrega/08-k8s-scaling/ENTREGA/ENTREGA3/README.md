# ⚡ Entrega 3: Autoescalado dirigido por eventos con KEDA

## 🎯 Objetivo

El `HorizontalPodAutoscaler` nativo de Kubernetes que configuraste en la
[práctica de autoescalado](../../README.md) solo sabe escalar en función de CPU o
memoria (o de métricas custom, que requieren montar tú mismo un Prometheus Adapter).
En la práctica, muchas cargas de trabajo necesitan escalar en función de **otras
señales**: mensajes pendientes en una cola, métricas de negocio, o simplemente un
horario conocido de antemano.

**KEDA** (*Kubernetes Event-Driven Autoscaling*) es un proyecto de la CNCF (graduado,
igual que el propio Kubernetes) que añade decenas de "escaladores" (*scalers*) para
este tipo de señales — colas (RabbitMQ, Kafka, SQS, Pub/Sub...), métricas de
Prometheus, cron, y muchos más — y que además permite escalar **hasta 0 réplicas**
cuando no hay eventos que atender, algo que el HPA nativo no contempla.

En esta práctica vas a instalar KEDA y usarlo para escalar un Deployment según un
horario (*cron scaler*), sin depender de CPU ni de tráfico real.

---

## 1️⃣ Instalar KEDA

Instala KEDA en tu clúster (vía Helm o los manifiestos oficiales, ver la
[documentación de instalación](https://keda.sh/docs/latest/deploy/)). Comprueba que
los pods del namespace `keda` llegan a `Running`.

## 2️⃣ Desplegar la aplicación a escalar

Reutiliza el `Deployment` `php-apache` de la práctica de autoescalado (o despliega uno
nuevo similar), pero esta vez **sin** ningún `HorizontalPodAutoscaler` nativo
asociado: el escalado lo va a gestionar KEDA.

## 3️⃣ Crear un `ScaledObject` con un trigger `cron`

Crea un `ScaledObject` de KEDA (`apiVersion: keda.sh/v1alpha1`) que apunte a tu
`Deployment` y use un trigger de tipo `cron`, con:

- Una franja horaria (`start`/`end` en formato cron) en la que el número de réplicas
  deseado sea alto (por ejemplo, 5).
- Fuera de esa franja, el número de réplicas debe bajar a un valor mínimo (puede ser
  0, para comprobar el *scale-to-zero*).

Consulta la [documentación del Cron Scaler](https://keda.sh/docs/latest/scalers/cron/)
para la sintaxis exacta.

## 4️⃣ Observar el comportamiento

Aplica el `ScaledObject` y observa:

```bash
kubectl get scaledobject
kubectl get hpa      # KEDA crea y gestiona un HPA internamente
kubectl get pods -w
```

Comprueba que, al entrar en la franja horaria configurada, el número de réplicas sube
solo, y que al salir de ella vuelve a bajar (incluso a 0 pods, si así lo configuraste),
sin que hayas generado ningún tipo de carga real sobre la aplicación.

## 💡 5. (Opcional, nota extra) Otra fuente de eventos

Si quieres profundizar, sustituye el trigger `cron` por otro basado en una métrica de
Prometheus, o en la longitud de una cola (por ejemplo, un tema de Pub/Sub de GCP), y
comenta en tu entrega qué cambios ha sido necesario hacer.

---

## 🧾 ENTREGA

Debes entregar:

1. El manifiesto de tu `ScaledObject`.
2. Una captura de `kubectl get scaledobject` y `kubectl get hpa` mostrando el HPA que
   KEDA gestiona internamente.
3. Capturas o logs que muestren el número de réplicas subiendo al entrar en la franja
   horaria configurada, y bajando (idealmente a 0) al salir de ella.
