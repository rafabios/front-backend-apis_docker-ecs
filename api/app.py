from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"status": "ok"})

@app.route('/healthcheck')
def healthcheck():
    return jsonify({"status": "API healthy"})

@app.route('/db-check')
def db_check():
    try:
        conn = psycopg2.connect(
            dbname=os.getenv('POSTGRES_DB'),
            user=os.getenv('POSTGRES_USER'),
            password=os.getenv('POSTGRES_PASSWORD'),
            host=os.getenv('POSTGRES_HOST')
        )
        return jsonify({"status": "Connected to the database"})
    except Exception as e:
        return jsonify({"status": "Failed to connect", "error": str(e)})

if __name__ == "__main__":
    app.run(debug=True, port=80)
