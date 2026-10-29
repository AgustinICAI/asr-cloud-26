# 🚀 Entrega 2: GitOps con ArgoCD (autosync + webhook externo)

## 🎯 Objetivo

Hasta ahora hemos desplegado en Kubernetes ejecutando `kubectl apply` a mano. En un
entorno real, esto es propenso a errores (¿qué versión hay realmente desplegada? ¿qué
pasa si alguien cambia algo a mano en el clúster y nadie se entera?).

**GitOps** propone que el repositorio Git sea la única fuente de verdad del estado
deseado del clúster, y que un controlador se encargue de mantener el clúster
sincronizado con lo que hay en Git, en vez de que alguien haga los despliegues a mano.
**ArgoCD** es el proyecto más extendido para implementar GitOps en Kubernetes.

En esta práctica vas a:

1. Instalar ArgoCD en tu clúster.
2. Desplegar la aplicación **Flask + Redis** de la [práctica 07](../../07-k8s-init/README.md)
   de forma **declarativa** desde un repositorio Git.
3. Configurar el **sync automático** (*autosync* + *self-heal*), de forma que el
   clúster se mantenga fiel a lo que hay en Git sin intervención manual.
4. Configurar un **webhook externo** desde tu repositorio Git, para que ArgoCD
   reaccione al instante a un `push`, en lugar de esperar a su ciclo de *polling*.

---

## 0️⃣ Requisitos de seguridad

El clúster sigue cumpliendo los [requisitos de seguridad comunes](../README.md#-requisitos-de-seguridad-comunes-a-las-3-entregas)
del lab. En esta entrega te afectan especialmente:

- ArgoCD necesita leer tu repositorio de GitHub, y los nodos no tienen IP pública:
  comprueba que, aun así, desde el clúster se llega a GitHub a través de Cloud NAT.
- La UI de ArgoCD es un panel de administración del clúster: su `LoadBalancer` solo
  debe aceptar tráfico de tu IP y de las IPs desde las que GitHub envía los
  *webhooks* (las publica GitHub en <https://api.github.com/meta>, campo `hooks`).

## 1️⃣ Instalar ArgoCD

Crea un namespace `argocd` e instala ArgoCD siguiendo la
[guía oficial de instalación](https://argo-cd.readthedocs.io/en/stable/getting_started/).
Comprueba que todos los pods del namespace `argocd` llegan a estado `Running`.

## 2️⃣ Acceder a ArgoCD

Expón el `argocd-server` para que la UI de ArgoCD quede accesible desde internet
(necesario también para el paso del webhook), por ejemplo cambiando su `Service` a tipo
`LoadBalancer` (`kubectl port-forward` te sirve para pruebas en local, pero no para
acceso externo). Recupera la contraseña inicial del usuario `admin` y accede a la UI.

## 3️⃣ Desplegar la práctica 07 desde Git

Sube a un repositorio Git tuyo los manifiestos de la aplicación Flask + Redis de la
[práctica 07](../../07-k8s-init/README.md) y crea un recurso `Application` de ArgoCD
que la despliegue en tu clúster a partir de ese repositorio.

A partir de este momento, la aplicación no se despliega con `kubectl apply`: el único
camino para cambiarla es hacer `push` al repositorio.

Comprueba que la aplicación queda en estado `Synced` / `Healthy` y que funciona.

## 4️⃣ Configurar sync automático (autosync + self-heal)

Por defecto, ArgoCD detecta diferencias pero espera a que sincronices manualmente.
Configura la `syncPolicy` de tu `Application` en modo automático, con:

- `prune: true`: borra en el clúster los recursos que ya no estén en Git.
- `selfHeal: true`: si alguien modifica algo a mano en el clúster (`kubectl edit`,
  por ejemplo cambiando el número de réplicas), ArgoCD debe revertirlo
  automáticamente para que vuelva a coincidir con Git.

Comprueba el `selfHeal` en la práctica: cambia algo a mano con `kubectl` en un recurso
gestionado por tu `Application` y observa cómo ArgoCD lo deshace solo al cabo de unos
segundos.

## 5️⃣ Configurar un webhook externo

Por defecto ArgoCD comprueba el repositorio periódicamente (cada 3 minutos). Para que
reaccione al instante:

1. Genera/localiza el *webhook secret* que usa ArgoCD (en el `Secret`
   `argocd-secret`, campo `webhook.github.secret` u equivalente según tu proveedor
   Git).
2. En la configuración de tu repositorio Git (Settings → Webhooks), da de alta un
   webhook apuntando a `https://<tu-argocd-server>/api/webhook`, tipo de contenido
   `application/json`, usando el secreto del paso anterior.
3. Haz un `push` con un cambio (por ejemplo, sube el número de réplicas en tu
   manifiesto) y comprueba que ArgoCD sincroniza el cambio de forma prácticamente
   inmediata, sin esperar al ciclo de *polling*.

## 🧾 ENTREGA

Debes entregar:

1. La URL del repositorio Git con los manifiestos de la práctica 07 y el manifiesto
   de tu `Application` de ArgoCD (con la `syncPolicy` automática configurada).
2. Una captura de la `Application` en estado `Synced`/`Healthy` en la UI de ArgoCD.
3. Una captura o log que demuestre el `selfHeal` revirtiendo un cambio manual.
4. Una captura de la configuración del webhook en tu proveedor Git (**sin mostrar el
   secreto en claro**) y evidencia (logs de ArgoCD, o timestamps) de una sincronización
   disparada por el webhook tras un `push`.
5. Evidencia de que se cumplen los requisitos de seguridad comunes, en especial las
   IPs permitidas en el `LoadBalancer` de ArgoCD.
