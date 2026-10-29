# 🕸️ Entrega 3: Canary release con Istio (app Flask + Redis)

## 🎯 Objetivo

Hasta ahora hemos gestionado el tráfico con los `Service` nativos de Kubernetes, que
reparten las peticiones equitativamente entre todos los pods que hacen `match` con su
`selector`. Esto es un problema en cuanto queremos hacer un **despliegue progresivo**
(*canary release*): por ejemplo, sacar una `v2` de un servicio y mandarle solo un 10%
del tráfico real, para validarla con poco riesgo antes de generalizarla.

Un **service mesh** como **Istio** resuelve esto en la capa de red, sin tocar el código
de la aplicación: añade un *sidecar* (`Envoy`) a cada pod que intercepta el tráfico, y
permite definir reglas de enrutado muy finas (por peso, por cabecera HTTP, por
usuario...) mediante sus propios recursos de Kubernetes (`VirtualService`,
`DestinationRule`, `Gateway`...).

En esta entrega vas a partir de la aplicación **Flask + Redis** de la
[práctica 07](../../07-k8s-init/README.md) (la misma que despliegas desde Git con
ArgoCD en la [ENTREGA2](../ENTREGA2/README.md)), vas a sacar una **`v2`** de la app y
vas a hacer un *canary release* que mande el **90%** del tráfico a la `v1` y el **10%**
a la `v2`.

> Si tu aplicación la gestiona ArgoCD (ENTREGA2), recuerda que el `selfHeal` deshará
> cualquier cambio que hagas a mano en sus recursos: los cambios en los manifiestos de
> la app se hacen con un `push` a tu repositorio Git.

---

## 1️⃣ Instalar Istio

Instala Istio con **Helm**, siguiendo la
[guía oficial de instalación con Helm](https://istio.io/latest/docs/setup/install/helm/):
los CRDs y recursos base (`istio/base`), el plano de control (`istio/istiod`) y un
*ingress gateway* (`istio/gateway`), todo en el namespace `istio-system`:

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --wait
helm install istiod istio/istiod -n istio-system --wait
helm install istio-ingressgateway istio/gateway -n istio-system --wait
```

Comprueba que los pods del namespace `istio-system` están `Running` y que el Service
`istio-ingressgateway` tiene `EXTERNAL-IP`:

```bash
kubectl get pods,svc -n istio-system
```

> ⚠️ En un clúster GKE con nodos privados (requisito de seguridad común del lab), el plano de control solo puede
> llegar a los nodos por ciertos puertos. Si la inyección de sidecars o la validación
> de recursos de Istio fallan con un *timeout* al llamar al webhook `istiod`, revisa
> qué regla de firewall necesita Istio para que el plano de control alcance a
> `istiod` (puerto `15017`).

## 2️⃣ Activar la inyección automática de sidecars

Istio solo añade el *sidecar* `Envoy` a los pods de los namespaces que marques
explícitamente con la label `istio-injection=enabled`. Marca el namespace donde está
desplegada tu app y haz que sus pods se recreen para que se les inyecte el sidecar.

Comprueba que los pods de `asr-flask` y `redis` tienen ahora **2 contenedores** (la
app + `istio-proxy`).

## 3️⃣ Construir y desplegar la `v2` de la app

En la carpeta [app-v2/](app-v2) tienes el código de la `v2`: es la app de la práctica
07 con estos cambios en [app.py](app-v2/app.py):

- Cada estudiante se guarda en Redis como un **objeto JSON completo**, con toda la
  información que se envíe en el alta (la `v1` solo guarda el `name`):

  ```bash
  curl -X POST http://<IP>/ \
       -H "Content-Type: application/json" \
       -d '{"name": "Alice", "email": "alice@example.com", "curso": 3}'
  ```

- Todas las respuestas llevan la cabecera `X-App-Version: v2`, y hay un endpoint
  `/version`. La `v1` no tiene ninguno de los dos, así que puedes distinguir qué
  versión ha atendido cada petición.

Construye la imagen `asr-flask:v2` y súbela a Artifact Registry. En [PRUEBAS.md](PRUEBAS.md)
tienes ejemplos de peticiones para probar la `v1` y la `v2`.

Despliega la `v1` y la `v2` de la app a la vez, de forma que:

- ambas versiones compartan el mismo `Service` (`asr-flask`) y el mismo Redis, y
- los pods de cada versión se distingan por una label `version` (`v1` / `v2`).

Comprueba que, sin ninguna regla de Istio, el `Service` reparte el tráfico entre las
dos versiones sin ningún criterio.

## 4️⃣ Exponer la app con un Gateway de Istio

Las reglas de enrutado de Istio solo se aplican al tráfico que pasa por un `Envoy`.
Expón la app a internet a través del *ingress gateway* de Istio (`Gateway` +
`VirtualService`) y comprueba que responde en la `EXTERNAL-IP` del Service
`istio-ingressgateway` (namespace `istio-system`).

Igual que el resto de Services `LoadBalancer` del lab (ver los
[requisitos de seguridad comunes](../README.md#-requisitos-de-seguridad-comunes-a-las-3-entregas)),
el del *ingress gateway* solo debe aceptar tráfico desde IPs de confianza.

## 5️⃣ 🧾 ENTREGA: canary release del 10% a la `v2`

Configura un `DestinationRule` con un *subset* por versión y un `VirtualService` que
reparta el tráfico que entra por el Gateway así:

- **90%** de las peticiones al subset `v1`.
- **10%** de las peticiones al subset `v2`.

Lanza unas 100 peticiones contra el Gateway y cuenta cuántas atiende cada versión,
para comprobar que la proporción observada se aproxima a 90/10.

### Qué entregar

1. Los manifiestos de la app (`v1` y `v2`).
2. Los YAML de tu `Gateway`, `DestinationRule` y `VirtualService`.
3. Una captura o breve conteo (por ejemplo, "88 veces v1 / 12 veces v2 en 100
   peticiones") que muestre que la proporción observada es razonablemente cercana a
   90/10.
4. Una respuesta razonada: si en lugar de entrar por el Gateway de Istio accedes a la
   app por la IP del Service `LoadBalancer` `asr-flask` de la práctica 07, ¿se respeta
   el reparto 90/10? ¿Por qué?
5. Las dos versiones comparten el mismo Redis. Da de alta estudiantes con la `v1` y con
   la `v2` y lista los estudiantes desde cada versión: ¿qué ve cada una? ¿Qué
   implicaciones tiene un cambio en el formato de los datos durante un *canary
   release*, en el que conviven las dos versiones?
6. Evidencia de que se cumplen los requisitos de seguridad comunes, en especial las
   IPs permitidas en el `LoadBalancer` del *ingress gateway* de Istio.

## 🧹 Limpieza de recursos

Cuando termines, para no dejar el clúster con el *service mesh* corriendo
innecesariamente, borra los recursos de Istio que hayas creado, desinstala Istio
(las *releases* de Helm, en orden inverso a como las instalaste, y los CRDs de Istio)
y quita la label de inyección del namespace.
