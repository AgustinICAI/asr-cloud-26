### Pruebas de la app `v1` y `v2`

Ejemplos de peticiones para probar las dos versiones de la app, igual que en el paso 7
de la [práctica 07](../../07-k8s-init/README.md).

Recuerda las diferencias entre las dos versiones:

| | `v1` (práctica 07) | `v2` ([app-v2/](app-v2)) |
|---|---|---|
| Alta (`POST /`) | Solo guarda el `name` | Guarda el JSON completo del estudiante |
| Listado (`GET /`) | Lista de nombres | Lista de objetos con todos sus campos |
| Cabecera `X-App-Version` | No | `v2` |
| Endpoint `/version` | No (`404`) | `{"version": "v2"}` |

#### Probar cada versión por separado

Para probar una versión concreta sin pasar por el reparto de tráfico, abre un
`port-forward` a uno de sus pods (cada uno en una terminal distinta; `Ctrl+C` para
cerrarlo):

```shell
kubectl port-forward $(kubectl get pod -l app=asr-flask,version=v1 -o name | head -1) 8081:8080
```

```shell
kubectl port-forward $(kubectl get pod -l app=asr-flask,version=v2 -o name | head -1) 8082:8080
```

**`v1`** (`localhost:8081`):

```shell
#Añadir estudiante (los campos que no sean "name" se ignoran):
curl -X POST http://localhost:8081/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice", "email": "alice@example.com", "curso": 3}'

#Listar estudiantes:
curl http://localhost:8081/

#Ver la versión (devuelve 404: la v1 no tiene este endpoint):
curl -i http://localhost:8081/version
```

**`v2`** (`localhost:8082`):

```shell
#Añadir estudiante con toda su información:
curl -X POST http://localhost:8082/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Bob", "email": "bob@example.com", "curso": 2}'

#Añadir otro estudiante:
curl -X POST http://localhost:8082/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Carol", "email": "carol@example.com", "curso": 4, "asignaturas": ["ASR", "Redes"]}'

#Alta sin "name" (devuelve 400):
curl -X POST http://localhost:8082/ \
     -H "Content-Type: application/json" \
     -d '{"email": "anonimo@example.com"}'

#Listar estudiantes (con todos sus campos):
curl http://localhost:8082/

#Ver la versión y la cabecera X-App-Version:
curl -i http://localhost:8082/version

#Resetear lista y añadir estudiante en un solo paso:
curl -X POST http://localhost:8082/reset \
     -H "Content-Type: application/json" \
     -d '{"name": "Dave", "email": "dave@example.com", "curso": 1}'
```

Como las dos versiones comparten Redis, vuelve a listar los estudiantes desde la `v1`
(`curl http://localhost:8081/`) después de las altas de la `v2` y compara lo que ve
cada una.

#### Probar a través del Gateway de Istio

Las peticiones que entran por el Gateway se reparten entre `v1` y `v2` según tu
`VirtualService`:

```shell
export GATEWAY_IP=$(kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

#Listar estudiantes, mostrando las cabeceras para ver qué versión ha respondido:
curl -i http://$GATEWAY_IP/

#Solo la cabecera de versión (vacío si ha respondido la v1):
curl -s -D - -o /dev/null http://$GATEWAY_IP/ | grep -i x-app-version
```
