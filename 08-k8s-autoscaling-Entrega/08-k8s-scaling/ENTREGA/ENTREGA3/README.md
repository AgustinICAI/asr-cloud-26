# 🕸️ Entrega 3: Canary release con Istio (Bookinfo)

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

Vamos a desplegar **Bookinfo**, la aplicación de ejemplo oficial de Istio (4
microservicios: `productpage`, `details`, `ratings` y `reviews`, este último con 3
versiones — `v1` sin estrellas, `v2` con estrellas negras y `v3` con estrellas rojas),
y vamos a configurar un *canary release* del servicio `reviews`.

Esta práctica está pensada para ir muy guiada paso a paso: la única parte que tienes
que resolver tú es la del final (sección 6).

---

## 1️⃣ Instalar Istio

Descarga `istioctl` (esto también descarga localmente los ejemplos que usaremos,
incluido Bookinfo):

```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH
```

Instala Istio en tu clúster con el perfil de demostración (trae ya el *ingress
gateway* configurado):

```bash
istioctl install --set profile=demo -y
```

Comprueba que los pods del namespace `istio-system` están `Running`:

```bash
kubectl get pods -n istio-system
```

## 2️⃣ Activar la inyección automática de sidecars

Istio solo añade el *sidecar* `Envoy` a los pods de los namespaces que marques
explícitamente. Vamos a desplegar Bookinfo en el namespace `default`:

```bash
kubectl label namespace default istio-injection=enabled
```

## 3️⃣ Desplegar Bookinfo

```bash
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

Comprueba que hay **6 pods** corriendo (details, productpage, ratings, y reviews-v1,
reviews-v2 y reviews-v3), cada uno con **2 contenedores** (la app + el sidecar
`istio-proxy`):

```bash
kubectl get pods
```

Verifica que la aplicación responde internamente:

```bash
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
```

## 4️⃣ Exponer la aplicación con un Gateway de Istio

```bash
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```

Obtén la IP externa del *ingress gateway* de Istio:

```bash
kubectl get svc istio-ingressgateway -n istio-system
```

Con la `EXTERNAL-IP` de ese Service, visita `http://<EXTERNAL-IP>/productpage` en tu
navegador. Refresca la página varias veces: verás que el bloque de "reviews" cambia
aleatoriamente entre sin estrellas (v1), estrellas negras (v2) y estrellas rojas (v3),
porque el `Service` de Kubernetes reparte el tráfico sin ningún criterio entre las 3
versiones.

## 5️⃣ Fijar un punto de partida determinista (todo el tráfico a v1)

Antes de poder repartir tráfico por versión, Istio necesita saber qué pods
corresponden a cada versión. Eso se declara con un `DestinationRule` (define
*subsets* a partir de las labels de los pods, en este caso la label `version`).
Aplica el `DestinationRule` ya preparado para los 4 servicios de Bookinfo:

```bash
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml
```

Y, como punto de partida conocido, aplica el `VirtualService` que manda el 100% del
tráfico de los 4 servicios al subset `v1`:

```bash
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```

Refresca varias veces `/productpage`: ahora **siempre** deberías ver el bloque de
reviews sin estrellas (v1), de forma consistente.

## 6️⃣ 🧾 ENTREGA: canary release del 10% a `reviews` v2

Tu tarea es modificar el `VirtualService` del servicio `reviews` (el que se aplicó en
el paso anterior dentro de `virtual-service-all-v1.yaml`) para que reparta el tráfico
así:

- **90%** de las peticiones al subset `v1` (sin estrellas).
- **10%** de las peticiones al subset `v2` (estrellas negras).

Esto se consigue dando dos `route.destination` distintos en el bloque `http` del
`VirtualService`, cada uno con su `weight` (90 y 10 respectivamente), apuntando cada
uno a un `subset` distinto (`v1` y `v2`) de los que ya definiste en el
`DestinationRule` del paso 5. **No hace falta tocar el `DestinationRule`**: los
subsets `v1`/`v2`/`v3` ya están definidos ahí; solo tienes que decidir a qué subsets
apunta el `VirtualService` y con qué peso.

Aplica tu `VirtualService` modificado y refresca `/productpage` unas 30-40 veces,
anotando cuántas veces sale cada versión, para comprobar que la proporción observada
se aproxima a 90/10 entre v1 y v2 (y que v3 no debería aparecer nunca).

### Qué entregar

1. El YAML completo de tu `VirtualService` de `reviews` con el reparto 90/10 entre
   `v1` y `v2`.
2. Una captura o breve conteo (por ejemplo, "31 veces v1 / 9 veces v2 en 40 refrescos")
   que muestre que la proporción observada es razonablemente cercana a 90/10.

## 🧹 Limpieza de recursos

Cuando termines, para no dejar el clúster con el *service mesh* corriendo
innecesariamente:

```bash
kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f samples/bookinfo/networking/bookinfo-gateway.yaml
istioctl uninstall --purge -y
kubectl label namespace default istio-injection-
```
