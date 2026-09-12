### Introducción

El objetivo de este Lab es el de presentar las posibilidades
ofrecidas por [Terraform](https://www.terraform.io/).
En particular, vamos a crear un fichero de configuración que
enuncia la creación de una máquina virtual, y posteriormente
procederemos a la planificación y aplicación de la susodicha
configuración mediante la línea de comando `terraform`.

Para la realización de este lab será necesario tener instalada
la línea de comando `terraform`. Podrás encontrar instrucciones
sobre su descarga e instalación en la página oficial:
[aquí](https://www.terraform.io/downloads.html).

#### Fichero de configuración

Al igual que en el caso de Ansible, necesitamos
un fichero de configuración que será en el que listemos los
recursos de infraestructura a desplegar. En este caso, vamos
a generar una configuración que finalmente generará una
máquina virtual en nuestro proyecto. Recuerda que para que
este ejemplo funcione en tu proyecto, tendrás que cambiar el nombre
del proyecto para que coincida con el tuyo.

El fichero de configuración en este caso no será un YAML.
Esto se debe a que Terraform tiene su propia sintaxis que su
línea de comando es capaz de traducir a órdenes específicas
de cada una de las nubes con las que podemos trabajar.

Crea un fichero `main.tf` con, al menos:

- Un bloque `provider "google"` con tu proyecto, región y zona.
- Un `resource "google_compute_instance"` con un nombre y `machine_type` a tu elección,
  un `boot_disk` con una imagen de Ubuntu 24.04 LTS, y una `network_interface` conectada
  a la red `default` con un `access_config {}` (para obtener IP pública).

Para entender la sintaxis particular de Terraform, nos
referimos a la documentación oficial [aquí](https://www.terraform.io/docs/language/index.html).

Una vez tengas el fichero de configuración guardado como `main.tf`,
procede a la inicialización, planificación y aplicación del mismo.

#### Conectar instancia google con terraform

```
gcloud auth application-default login
```

#### Pasos a seguir

1. **Inicialización** (`terraform init`): descarga el proveedor necesario y prepara el
   directorio de trabajo. Comprueba que se ha generado la carpeta `.terraform` y el
   fichero `.terraform.lock.hcl`.

2. **Planificación** (`terraform plan`): revisa detenidamente la salida y asegúrate de
   entender qué recursos se van a crear antes de aplicarlos. Si falla, revisa que
   tienes seteada la variable de entorno `GOOGLE_APPLICATION_CREDENTIALS`.

3. **Aplicación** (`terraform apply`): confirma con `yes` cuando se te pida. Al terminar,
   revisa que se ha generado el fichero `terraform.tfstate`, que contiene el estado (la
   "foto") de la infraestructura desplegada. Terraform usará este estado para saber qué
   cambiar en próximos `apply`, sin destruir ni recrear lo ya existente si no es
   necesario.

## Entrega
Realizar las modificaciones necesarias en la plantilla de Terraform para que la máquina sea accesible por ssh y http. No podremos llegar tan lejos como con Ansible,
donde también instalabamos el servidor web, pero si deberíamos con la plantilla Terraform,
dejar la instancia lo más preparada posible, para poder instalar sobre la máquina el servidor web (este paso
manual no hace falta realizarlo).

Entregar en una carpeta "terraform" el/los ficheros ".tf" que hacen falta para llegar a la solución.

Si habéis entregado la parte de Terraform partiréis de un 9 (y para abajo). Si deseais llegar al diez, es necesario investigar el uso de los vars en Terraform, y como se podría invocar el mismo terraform con distintas variables de entorno (como son el nombre del proyecto). La variable GOOGLE_APPLICATION_CREDENTIALS que usa para setear la service account se da por hecho que tiene que ser seteable ;-).

Si se realiza la parte de ansible, se tendrá +5 puntos sobre la nota total de la práctica.


#### Liberación de los recursos

Para liberar recursos, solo tenemos que ejecutar:

```shell
$ terraform destroy
```

que hará las veces del ya habitual script de limpieza que hemos
usado en los anteriores labs (el conocido `clean.sh`).
Al igual que antes, Terraform nos preguntará antes de proceder,
ya que se trata de un cambio de infraestructura relevante.
Solo tenemos que escribir `yes` y la infraestructura será
destruida.
