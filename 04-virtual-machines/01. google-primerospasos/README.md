En este ejemplo vamos a proceder a la creación de una máquina virtual
en Google mediante línea de comandos. Para ello podemos proceder tanto desde
[cloud shell](https://shell.cloud.google.com/) como desde local si tenemos
instalado y autenticado Google SDK, i.e. el comando `gcloud`.

### Objetivo

1. **Crear un prototipo de instancia** (*instance template*), un recurso que podemos usar a
   posteriori para la creación de VMs tanto no gestionadas como gestionadas (*managed
   instance groups*, o MIGs) de manera rápida y eficiente.

   El prototipo (`gcloud compute instance-templates create`) debe cumplir:
   - Usar una imagen de Ubuntu (busca en el catálogo de imágenes públicas de GCP la que consideres más adecuada).
   - Tener un tamaño de máquina modesto (piensa en el nivel gratuito, e.g. `e2-medium` o inferior).
   - Llevar las `tags` necesarias para que la VM admita tráfico `http-server` y `https-server`.
   - Ejecutar como *startup script* el fichero [startup-script.sh](startup-script.sh) (que se te proporciona), de manera que la VM instale y arranque un servidor web automáticamente en el primer arranque.

   Comprueba con el comando de listado correspondiente que el prototipo se ha creado.

2. **Crear una instancia** a partir del prototipo anterior (`gcloud compute instances create`, usando `--source-instance-template`), en la zona que prefieras.

3. **Exponer el puerto 80**: visita la IP pública de la máquina en tu navegador. Si no ves nada servido, es porque hace falta habilitar el ingreso por el puerto `80` en la red `default` mediante una *firewall rule*. En este ejercicio puedes crearla desde el portal web; en próximos labs veremos cómo hacerlo programáticamente.

### Limpieza de recursos

Para no incurrir en gastos que consuman nuestros créditos de prueba, recuerda borrar todos los recursos que hayas creado (instancia y, si quieres, el prototipo) una vez termines.
