### Introducción
El objetivo del siguiente ejemplo es el de introducir Google Kubernetes Engine (GKE),
un servicio de Kubernetes gestionado y seguro para el despliegue, gestión y
(auto)escalado de aplicaciones contenerizadas usando la infraestructura de
GCP. Para ello, en este ejemplo vamos a crear un cluster GKE, que consiste
en un conjunto de VMs (instancias de Google Compute Engine), y desplegaremos
en éste una aplicación sencilla `hello-world`.


### 1. Creación del cluster GKE
Lo primero que vamos a hacer es asegurarnos de tener configurada una
zona de procesamiento predeterminada. Para establecer nuestra zona de procesamiento
predeterminada en `europe-southwest1-b` ejecutaremos el siguiente comando:

```shell
gcloud config set compute/zone europe-southwest1-b
```

Una vez configurada la zona por defecto, vamos a proceder a crear un cluster GKE.
Éste constará de, al menos, una instancia principal y varias VMs que ejecutarán los procesos de
Kubernetes, llamadas en este contexto nodos.
Así, los nodos son VMs de Compute Engine que ejecutan los procesos de Kubernetes necesarios.

A continuación vamos a crear nuestro cluster, el cual tendrá el nombre que queramos especificar
en la variable `$CLUSTER_NAME`:

```shell
gcloud container clusters create $CLUSTER_NAME \
--enable-master-authorized-networks \
--enable-ip-alias \
--disk-size 35 \
--master-authorized-networks "$(curl ifconfig.me)/32"
```
La creación del clúster podrá llevar varios minutos.

#### Explicación:
- `CLUSTER_NAME`: el nombre que le quieras dar al cluster.
- `ZONE`: la zona donde quieres crear el cluster (ejemplo: `europe-southwest1-b`).
- `--enable-ip-alias`: opción para habilitar alias de IP (redes VPC-native).
- `--disk-size DISK_SIZE`: tamaño del disco para cada nodo en GB. Reemplázalo con el tamaño que prefieras (por ejemplo, 20 para 20 GB).
- `--master-authorized-networks "$(curl ifconfig.me)/32"`: restringe el acceso al API server solo a tu IP pública.

Una vez la creación ha finalizado satisfactoriamente, vamos a proceder a interaccionar con el cluster.
Para ello necesitamos las credenciales correspondientes, las cuales podemos obtener
fácilmente mediante la ejecución del siguiente comando:

```shell
# La primera vez necesitaremos instalar el siguiente plugin
gcloud components install gke-gcloud-auth-plugin
# Una vez instalado, este comando nos configurará nuestro cluster en el fichero ~/.kube/config
gcloud container clusters get-credentials $CLUSTER_NAME
```

Una vez nos hemos autenticado, podemos comenzar a gestionar el cluster GKE.
Una de las labores más comunes en la gestión de un cluster es el despliegue de una aplicación
en el mismo. En este ejemplo vamos a proceder a desplegar una aplicación tipo `hello-world`,
con el ánimo de simplemente mostrar los inicios (que pueden llegar a ser bastante duros)
con GKE.

### 2. Despliegue y exposición de la aplicación

⚠️ Para la gestión del cluster necesitaremos tener instalado `kubectl` (the Kubernetes command-line tool).
Puedes encontrar el instalador [aquí](https://kubernetes.io/docs/tasks/tools/), o instalarlo directamente vía `gcloud`:

```shell
gcloud components install kubectl
kubectl version --client
```

GKE utiliza los objetos de Kubernetes (una abstracción para representar el estado de
un cluster) para crear y administrar los recursos de sus clústeres.
Algunos de los objetos que oferta k8s son:

* `Deployment`: para implementar aplicaciones sin estado como servidores web

* `Service`: definen las reglas y el balanceo de cargas para acceder a su aplicación desde Internet

Para crear un nuevo objeto `Deployment` y un `Service` usaremos manifiestos YAML y `kubectl apply` (recomendado para infra como código).

Crea `deployment.yaml` con el siguiente contenido:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-server
  template:
    metadata:
      labels:
        app: hello-server
    spec:
      containers:
      - name: hello-app
        image: nginx:stable-alpine
        ports:
        - containerPort: 80
```

Aplica el despliegue:

```shell
kubectl apply -f deployment.yaml
```

Crea `service.yaml` con el siguiente contenido:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-server
spec:
  type: LoadBalancer
  selector:
    app: hello-server
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

Aplica el service (crea el LoadBalancer):

```shell
kubectl apply -f service.yaml
```

Comprueba el Service hasta que se le asigne una IP externa (puede tardar aproximadamente un minuto):

```shell
kubectl get service hello-server
```

Finalmente, visita la aplicación en tu navegador usando la `EXTERNAL-IP` del servicio.

### Usando un IDE avanzado para trabajar con kubernetes

*K9s* es una herramienta de interfaz de línea de comandos (CLI) diseñada para gestionar y visualizar clústeres de Kubernetes. Proporciona una forma interactiva y muy eficiente de explorar y gestionar recursos de Kubernetes sin necesidad de usar comandos kubectl constantemente. Instálalo siguiendo las instrucciones de su [repositorio oficial](https://github.com/derailed/k9s) si quieres probarlo.

### Lanzar el script (opcional, alternativa a los comandos anteriores)

La creación del cluster, despliegue y exposición de la app se pueden hacer
simplemente ejecutando [deployment.sh](deployment.sh):

```shell
chmod a+x deployment.sh && ./deployment.sh
```

### 3. Borrar el cluster

Cuando termines, borra el clúster para no consumir créditos innecesariamente:

```shell
gcloud container clusters delete $CLUSTER_NAME --quiet
```

El proceso de borrado puede llevar unos minutos. Este borrado también se puede hacer
mediante [clean.sh](clean.sh):

```shell
chmod a+x clean.sh && ./clean.sh
```
