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
Esto se debe a que Terraform tiene su propia sintaxis (HCL) que su
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

4. **Idempotencia**: vuelve a lanzar `terraform apply` sin tocar nada. Terraform debería
   indicar que no hay cambios. Después, cambia algo en el código (p.ej. una `label` de la
   VM) y fíjate en que el `plan` solo propone modificar ese atributo.

#### Todo con Terraform: también el software de la máquina

Terraform no se queda en crear la "caja vacía". A la VM se le puede pasar un
*startup script* (el mismo mecanismo que usamos en la práctica 4 con
`--metadata-from-file=startup-script=...`) a través de sus metadatos, de modo que al
arrancar se instale y configure el servidor web sin ningún paso manual. Investiga:

- El argumento `metadata_startup_script` (o la clave `startup-script` dentro de
  `metadata`) del recurso `google_compute_instance`.
- La función [`templatefile`](https://developer.hashicorp.com/terraform/language/functions/templatefile),
  que permite tener el script en un fichero aparte (p.ej. `scripts/startup.sh.tftpl`) y
  rellenar en él valores que vienen de Terraform (variables, IPs, nombres de recursos...).

Del mismo modo, casi cualquier pieza de la infraestructura que hemos montado a mano en
prácticas anteriores tiene su recurso en Terraform: reglas de firewall
(`google_compute_firewall`), redes y subredes, Cloud NAT, balanceadores, políticas de
WAF (Cloud Armor), registros DNS... e incluso los certificados TLS, que se pueden generar
con el provider [`tls`](https://registry.terraform.io/providers/hashicorp/tls/latest/docs)
(CA privada, CSR y firma, lo mismo que hacíamos con `openssl`).

> ⚠️ El fichero `terraform.tfstate` guarda los valores de todos los recursos, incluidas
> claves privadas y contraseñas. Trátalo como un secreto: **no lo subas a git**.

## Entrega
Realizar las modificaciones necesarias en la plantilla de Terraform para que, con un único
`terraform apply` y **sin ningún paso manual**:

- La máquina sea accesible por SSH y HTTP (reglas de firewall creadas también con Terraform).
- El servidor web (`nginx`) quede instalado y sirviendo una página propia, mediante un
  *startup script* pasado a la VM desde Terraform.
- Al terminar, Terraform muestre la IP pública de la VM (bloque `output`).

Entregar en una carpeta "terraform" el/los ficheros ".tf" (y el script de arranque, si
va en un fichero aparte) que hacen falta para llegar a la solución. **No** incluyas el
`terraform.tfstate` ni la carpeta `.terraform`.

Si habéis entregado la parte de Terraform partiréis de un 9 (y para abajo). Si deseais llegar al diez, es necesario investigar el uso de los vars en Terraform, y como se podría invocar el mismo terraform con distintas variables de entorno (como son el nombre del proyecto). La variable GOOGLE_APPLICATION_CREDENTIALS que usa para setear la service account se da por hecho que tiene que ser seteable ;-).

Si se realiza la parte de ansible, se tendrá +5 puntos sobre la nota total de la práctica.

#### Reto opcional

Desplegar con Terraform la arquitectura completa de la 3ª mejora de la
[práctica 5](../../05-virtual-machines-Entrega/README.md) (máquina de salto, servidor web
sin IP pública, Cloud NAT, balanceador con WAF y HTTPS de extremo a extremo), **incluida
la generación de los certificados**.

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
