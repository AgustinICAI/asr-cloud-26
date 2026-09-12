##### 💻 LAB 8: Extendiendo Kubernetes — instalando herramientas del ecosistema

Este lab es uno de los más técnicos que vamos a tener, precisamente para entender la
complejidad de K8s, además de la infinidad de configuraciones y herramientas posibles
existentes (a pesar de tan solo explorar una pequeñísima fracción del todo en este
ejemplo). Un clúster de Kubernetes "pelado" rara vez se queda así en un entorno real:
encima se instalan y operan piezas adicionales del ecosistema para cubrir necesidades
muy concretas — de autoescalado, de despliegue continuo, de gestión de tráfico...
Precisamente de eso trata este lab: de **instalar y extender** un clúster GKE con tres
piezas distintas (y muy extendidas en la industria), cada una en su propia entrega.
También vamos a ver el intenso trabajo que esta instalación, configuración y
monitorización requiere en cada caso. De ahí la importancia de trabajar con IaC y
ficheros YAML, para ser capaces siempre de replicar el comportamiento.

La primera de esas piezas es el autoescalado (HPA, Cluster Autoscaler y Node Auto
Provisioning): la posibilidad de escalar horizontalmente a nivel de POD, y de que ese
escalado horizontal se traduzca también en un escalado a nivel de clúster. Este nivel
de control es necesario en proyectos productivos, en los que queremos máxima
estabilidad y resiliencia del servicio al menor coste posible (la menor cantidad de
infraestructura), pero adaptándose automáticamente a los picos de demanda tan
característicos del entorno digital de hoy en día. Que GKE nos dé estas soluciones ya
integradas es parte de lo que lo hace el número uno en gestión de contenedores en
entornos cloud — pero el autoescalado es solo una pieza más del ecosistema, no el
único objetivo del lab: [ENTREGA1](ENTREGA1/README.md) incluye también la creación del
clúster GKE (con autoescalado de nodos habilitado) y el despliegue de la aplicación
`php-apache` sobre la que gira toda la entrega: empieza por ahí, y reutiliza ese mismo
clúster para ENTREGA2 y ENTREGA3.

## ENTREGA: 3 prácticas sobre el ecosistema de Kubernetes

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
