import json
import os
from flask import Flask, request, jsonify
from redis import Redis

# =============================
# Configuración de Flask
# =============================
app = Flask(__name__)

# Leer variable de entorno para Redis
redis_ip = os.environ.get("REDIS_IP_GCP", "localhost")

# =============================
# Cliente Redis
# =============================
redis_server = Redis(
    host=redis_ip,
    port=6379,
    db=0,
    socket_timeout=5,
    decode_responses=True  # UTF-8 por defecto en redis-py 4.x
)

# Versión de la app: v2 (canary). La v1 es la de la práctica 07
APP_VERSION = "v2"


# =============================
# Rutas de la aplicación
# =============================
@app.after_request
def add_version_header(response):
    # Cabecera para saber qué versión ha atendido cada petición
    response.headers["X-App-Version"] = APP_VERSION
    return response


@app.route("/version", methods=["GET"])
def version():
    return {"version": APP_VERSION}


# En la v2 cada estudiante se guarda en Redis como un objeto JSON completo
# ({"name": ..., y cualquier otro campo}), no solo su nombre como en la v1
def save_student(student):
    redis_server.rpush("students", json.dumps(student, ensure_ascii=False))


def load_students():
    students = []
    for item in redis_server.lrange("students", 0, -1):
        try:
            student = json.loads(item)
        except ValueError:
            student = None
        # Los estudiantes que dio de alta la v1 son solo el nombre (texto plano)
        if not isinstance(student, dict):
            student = {"name": item}
        students.append(student)
    return students


@app.route("/", methods=["POST", "GET"])
def index():
    if request.method == "POST":
        student = request.get_json(silent=True)
        if not isinstance(student, dict) or not student.get("name"):
            return {"error": "name is required"}, 400
        save_student(student)
        return student, 201

    if request.method == "GET":
        return jsonify(load_students())


@app.route("/reset", methods=["POST", "GET"])
def reset():
    redis_server.flushdb()
    # Si viene un JSON con "name", lo añadimos tras el borrado (reset + alta en un paso)
    data = request.get_json(silent=True) or {}
    if isinstance(data, dict) and data.get("name"):
        save_student(data)
    return jsonify(load_students())


# =============================
# Entrada principal para desarrollo local
# =============================
def main_local_dev():
    app.run(host="0.0.0.0", port=5000, debug=False)


if __name__ == "__main__":
    main_local_dev()

