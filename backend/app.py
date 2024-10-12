from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/healthcheck')
def healthcheck():
    return jsonify({"status": "healthy"})

@app.route('/backend-call')
def backend_call():
    return jsonify({"message": "Chamada do backend ao API de relatórios"})

@app.route('/')
def index():
    return jsonify({"message": "ok"})


if __name__ == "__main__":
    app.run(debug=True)
