## ENTREGA: 3 prácticas sobre el ecosistema de autoescalado y despliegue en K8s

A partir del clúster y la aplicación `php-apache` de la
[práctica de autoescalado](../README.md), esta entrega se compone de **tres partes**,
cada una centrada en una pieza distinta (y muy extendida en la industria) del
ecosistema de Kubernetes:

- [ENTREGA1](ENTREGA1/README.md): **Validar el autoescalado con una prueba de carga**,
  usando **k6** para generar tráfico controlado y observar cómo reacciona el HPA (y,
  si la carga es suficiente, el Cluster Autoscaler/NAP).
- [ENTREGA2](ENTREGA2/README.md): **GitOps con ArgoCD**, desplegando de forma
  declarativa desde un repositorio Git, con sincronización automática (*autosync* +
  *self-heal*) y un *webhook* externo para sincronizar al instante tras cada `push`.
- [ENTREGA3](ENTREGA3/README.md): **Autoescalado dirigido por eventos con KEDA**,
  escalando un Deployment según un horario (*cron scaler*) en vez de según CPU/memoria,
  incluyendo *scale-to-zero*.
