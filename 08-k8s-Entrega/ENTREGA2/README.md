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
2. Desplegar una aplicación de forma **declarativa** desde un repositorio Git.
3. Configurar el **sync automático** (*autosync* + *self-heal*), de forma que el
   clúster se mantenga fiel a lo que hay en Git sin intervención manual.
4. Configurar un **webhook externo** desde tu repositorio Git, para que ArgoCD
   reaccione al instante a un `push`, en lugar de esperar a su ciclo de *polling*.

---

## 1️⃣ Instalar ArgoCD

Crea un namespace `argocd` e instala ArgoCD siguiendo la
[guía oficial de instalación](https://argo-cd.readthedocs.io/en/stable/getting_started/).
Comprueba que todos los pods del namespace `argocd` llegan a estado `Running`.

## 2️⃣ Acceder a ArgoCD

Instala la CLI de `argocd` (opcional pero recomendable) y expón el `argocd-server`
(por ejemplo con `kubectl port-forward`, o cambiando el `Service` a tipo
`LoadBalancer` si quieres acceso externo, necesario para el paso del webhook).
Recupera la contraseña inicial del usuario `admin` y accede a la UI o haz login por CLI.

## 3️⃣ Crear una `Application` declarativa

Elige un repositorio Git con manifiestos de Kubernetes (puedes reutilizar, por
ejemplo, el `deployment.yaml`/`service.yaml` de la [práctica de k8s-init](../../07-k8s-init/README.md),
subidos a un repo tuyo). Crea un recurso `Application` de ArgoCD (`apiVersion:
argoproj.io/v1alpha1`, `kind: Application`) que indique:

- `source`: la URL de tu repositorio, la rama/`targetRevision`, y el `path` donde
  están los manifiestos.
- `destination`: el clúster (`https://kubernetes.default.svc`) y el `namespace` donde
  quieres desplegar.

Aplica el manifiesto de la `Application` (o créala desde la UI) y comprueba que
ArgoCD sincroniza la aplicación y la deja en estado `Synced` / `Healthy`.

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

1. El manifiesto de tu `Application` de ArgoCD (con la `syncPolicy` automática
   configurada).
2. Una captura de la `Application` en estado `Synced`/`Healthy` en la UI de ArgoCD.
3. Una captura o log que demuestre el `selfHeal` revirtiendo un cambio manual.
4. Una captura de la configuración del webhook en tu proveedor Git (**sin mostrar el
   secreto en claro**) y evidencia (logs de ArgoCD, o timestamps) de una sincronización
   disparada por el webhook tras un `push`.
