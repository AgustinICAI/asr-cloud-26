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

# =============================
# Rutas de la aplicación
# =============================
@app.route("/", methods=["POST", "GET"])
def index():
    if request.method == "POST":
        name = request.json.get("name")
        if not name:
            return {"error": "name is required"}, 400
        redis_server.rpush("students", name)
        return {"name": name}, 201

    if request.method == "GET":
        return jsonify(redis_server.lrange("students", 0, -1))


@app.route("/reset", methods=["POST", "GET"])
def reset():
    redis_server.flushdb()
    return index()


# =============================
# Entrada principal para desarrollo local
# =============================
def main_local_dev():
    app.run(host="0.0.0.0", port=5000, debug=False)


if __name__ == "__main__":
    main_local_dev()

