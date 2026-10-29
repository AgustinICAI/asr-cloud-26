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
Flask + Redis de la [práctica 07](../07-k8s-init/README.md) sobre la que gira toda la
entrega: empieza por ahí, y reutiliza ese mismo clúster para ENTREGA2 y ENTREGA3.

## 🔒 Requisitos de seguridad (comunes a las 3 entregas)

El clúster GKE que crees, y todo lo que despliegues en él, debe cumplir **siempre**
estos requisitos. Son obligatorios en las tres entregas:

1. **Nodos con IP privada**: ningún nodo del clúster puede tener IP pública. La salida
   a internet de los nodos (descargar imágenes públicas, leer tu repositorio de GitHub...)
   se hace a través de **Cloud NAT**.
2. **Plano de control restringido**: el endpoint del API server de Kubernetes solo
   puede ser accesible desde **tu IP** (como en la práctica 07, con
   `--master-authorized-networks`), nunca desde `0.0.0.0/0`.
3. **Services `LoadBalancer` restringidos**: todo Service de tipo `LoadBalancer` (la
   app `asr-flask`, la UI de ArgoCD, el *ingress gateway* de Istio...) solo puede
   aceptar tráfico desde **IPs de confianza** (la tuya y, cuando haga falta, las de
   servicios concretos como los *webhooks* de GitHub), nunca desde todo internet.
4. **Sin reglas de firewall abiertas a todo internet** (`0.0.0.0/0`) hacia los nodos.

> 🤖 **Si usas una IA** (ChatGPT, Claude, Copilot...) para generar los comandos o los
> manifiestos, pásale estos requisitos de forma explícita y **revisa lo que te
> devuelve antes de ejecutarlo**: por defecto, la mayoría de ejemplos que encontrarás
> (y que generan las IAs) crean clústeres con nodos públicos, API server abierto a
> internet y balanceadores accesibles desde cualquier IP. Un clúster así, en una cuenta
> de Google Cloud real, es un objetivo fácil: el responsable de lo que levantas eres tú.

En cada entrega incluye la evidencia de que se cumplen estos requisitos (el comando de
creación del clúster, la configuración de Cloud NAT, y los Services `LoadBalancer` con
sus IPs permitidas).

## ENTREGA: 3 prácticas sobre el ecosistema de Kubernetes

- [ENTREGA1](ENTREGA1/README.md): **Validar el autoescalado con una prueba de carga**,
  usando **k6** para generar tráfico controlado y observar cómo reacciona el HPA (y,
  si la carga es suficiente, el Cluster Autoscaler/NAP).
- [ENTREGA2](ENTREGA2/README.md): **GitOps con ArgoCD**, desplegando de forma
  declarativa desde un repositorio Git, con sincronización automática (*autosync* +
  *self-heal*) y un *webhook* externo para sincronizar al instante tras cada `push`.
- [ENTREGA3](ENTREGA3/README.md): **Canary release con Istio**, práctica de *service
  mesh* en la que se saca una `v2` de la app Flask + Redis de la práctica 07 y se
  configura un reparto de tráfico del 90%/10% entre `v1` y `v2` con `Gateway` +
  `DestinationRule` + `VirtualService`.
