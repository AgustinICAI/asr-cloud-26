##### 💻 LAB 8: Soluciones y estrategias de autoescalado con K8s

Este lab es uno de los más técnicos que vamos a tener, precisamente para entender la
complejidad de K8s, además de la infinidad de configuraciones posibles existentes (a
pesar de tan solo explorar una pequeñísima fracción del todo en este ejemplo). En
particular, veremos la posibilidad de escalar horizontal a nivel POD, para
posteriormente ver cómo este escalamiento horizontal se puede realizar a nivel cluster.
Este nivel de control de un cluster es necesario cuando trabajemos con proyectos
productivos, en los que queremos una máxima estabilidad y resiliencia del servicio,
pero al menor coste posible (es decir, con la menor cantidad de infraestructura), y a
su vez que la infraestructura se adapte automáticamente a los picos de demanda tan
característicos del entorno digital de hoy en día. El hecho de que GKE nos permita esta
gestión de manera automática y nos provea con soluciones para gestionar este
automatismo es lo que hace que GKE sea el número uno en la gestión de contenedores en
entornos cloud. Sin embargo, también vamos a ver el intenso trabajo que esta
configuración, mantenimiento y monitorización requiere. De ahí la importancia de
trabajar con IaC y ficheros yamls, para ser capaces siempre de replicar el
comportamiento.

Empieza por la [práctica base de autoescalado](08-k8s-scaling/README.md) (HPA, Cluster
Autoscaler y Node Auto Provisioning). A partir del clúster y la aplicación `php-apache`
que despliegues ahí, la entrega se compone de **tres partes**, cada una centrada en una
pieza distinta (y muy extendida en la industria) del ecosistema de Kubernetes:

## ENTREGA: 3 prácticas sobre el ecosistema de autoescalado y despliegue en K8s

- [ENTREGA1](ENTREGA1/README.md): **Validar el autoescalado con una prueba de carga**,
  usando **k6** para generar tráfico controlado y observar cómo reacciona el HPA (y,
  si la carga es suficiente, el Cluster Autoscaler/NAP).
- [ENTREGA2](ENTREGA2/README.md): **GitOps con ArgoCD**, desplegando de forma
  declarativa desde un repositorio Git, con sincronización automática (*autosync* +
  *self-heal*) y un *webhook* externo para sincronizar al instante tras cada `push`.
- [ENTREGA3](ENTREGA3/README.md): **Canary release con Istio (Bookinfo)**, práctica
  muy guiada de *service mesh* en la que se despliega Bookinfo y se configura un
  reparto de tráfico del 90%/10% entre `reviews` v1 y v2 con `DestinationRule` +
  `VirtualService`.
