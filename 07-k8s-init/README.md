### Introducción
El objetivo del siguiente ejemplo es el de introducir Google Kubernetes Engine (GKE),
un servicio de Kubernetes gestionado y seguro para el despliegue, gestión y
(auto)escalado de aplicaciones contenerizadas usando la infraesturctura de
GCP. Para ello, en este ejemplo vamos a crear un cluster GKE, que consiste
en un conjunto de VMs (instancias de Google Compute Engine), y desplegaremos
en éste una aplicación sencilla `hello-world`.

### 1. Creación del cluster GKE

Configura una zona de cómputo por defecto para tu proyecto, y crea un cluster GKE
(`gcloud container clusters create`) que:

- Tenga habilitadas las redes autorizadas del *master* (`--enable-master-authorized-networks`),
  restringiendo el acceso al API server únicamente a tu IP pública.
- Tenga habilitado el alias de IP (`--enable-ip-alias`).
- Use un tamaño de disco razonable por nodo.

La creación del clúster podrá llevar varios minutos.

Una vez la creación ha finalizado satisfactoriamente, obtén las credenciales del
cluster para poder interaccionar con él (`gcloud container clusters get-credentials`).
La primera vez necesitarás instalar el plugin de autenticación de `gcloud` para GKE.

### 2. Despliegue y exposición de la aplicación

⚠️ Para la gestión del cluster necesitarás tener instalado `kubectl` (the Kubernetes
command-line tool). Puedes encontrar el instalador [aquí](https://kubernetes.io/docs/tasks/tools/).

GKE utiliza los objetos de Kubernetes (una abstracción para representar el estado de
un cluster) para crear y administrar los recursos de sus clústeres.
Algunos de los objetos que oferta k8s son:

* `Deployment`: para implementar aplicaciones sin estado como servidores web

* `Service`: definen las reglas y el balanceo de cargas para acceder a su aplicación desde Internet

Para crear un nuevo objeto `Deployment` y un `Service` usaremos manifiestos YAML y `kubectl apply` (recomendado para infra como código).

Deberás crear:

1. Un fichero `deployment.yaml` que despliegue una aplicación `hello-server` (puedes usar,
   por ejemplo, la imagen `nginx:stable-alpine`) exponiendo el puerto `80` del contenedor.

2. Un fichero `service.yaml` que exponga dicho `Deployment` mediante un `Service` de tipo
   `LoadBalancer`.

Aplica ambos manifiestos con `kubectl apply -f`, y comprueba el estado del `Service`
hasta que se le asigne una IP externa (puede tardar aproximadamente un minuto).

Finalmente, visita la aplicación en tu navegador usando la `EXTERNAL-IP` del servicio.

### Usando un IDE avanzado para trabajar con kubernetes

*K9s* es una herramienta de interfaz de línea de comandos (CLI) diseñada para gestionar y visualizar clústeres de Kubernetes. Proporciona una forma interactiva y muy eficiente de explorar y gestionar recursos de Kubernetes sin necesidad de usar comandos kubectl constantemente. Instálalo siguiendo las instrucciones de su [repositorio oficial](https://github.com/derailed/k9s) si quieres probarlo.

### 3. Borrar el cluster

Cuando termines, borra el clúster (`gcloud container clusters delete`) para no consumir
créditos innecesariamente. El proceso de borrado puede llevar unos minutos.
