## PRUEBAS DE CARGA CON HERRAMIENTAS

Vamos a avanzar un poco más en las pruebas de rendimiento. Antes de nada, para el bucle infinito de carga que hayas lanzado en el ejercicio anterior con busybox.

Vamos a lanzar ahora unas pruebas de rendimiento controladas. Estas son algunas de las herramientas existentes para lanzar pruebas de rendimiento:
- K6S (27.000 ★ en github) Herramienta moderna y muy usada para pruebas de carga, escrita en Go y con scripts en JavaScript. La principal ventana es la integración directa con Kubernetes (via k6-operator o k6-cloud), permitiendo escalar pods de carga fácilmente.
- JMETER (9100 ★ en github) basada en java, tiene múltiples plugins lo que permite casi probar y medir rendimiento de infinidad de tecnologías. Basado en un nodo master que hace de servidor y nodos slaves que lanzan las pruebas de rendimiento. Los escenarios se pueden configurar mediante clicks en el nodo servidor, o evolucionar escribiéndolos en groovy.
- Locust (25.000 ★ en github): supone una evolución, está basado en eventos en vez de hilos y las pruebas de rendimiento son programadas en python. El consumo de recursos es de un 70% menos.
- Apachebench (desde 1996): fue de las primeras herramientas para lanzar pruebas de carga. Está basada en el cliente "ab", el cual permite de forma cómoda lanzar peticiones rest.

Elige (o combina) alguna de las siguientes entregas para poner en práctica estas herramientas contra tu servicio `php-apache` del ejercicio anterior:

- [ENTREGA1](ENTREGA1/README.md): Pruebas de rendimiento con **k6**
- [ENTREGA2](ENTREGA2/README.md): Pruebas de rendimiento con **ApacheBench (ab)**
- [ENTREGA3](ENTREGA3/README.md): Pruebas de rendimiento con **Locust**
