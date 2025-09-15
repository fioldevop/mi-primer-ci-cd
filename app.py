from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return '¡Hola desde Docker!'

@app.route('/health')
def health():
    return 'OK', 200

if __name__ == '__main__':
    # Asegurar que bindea a todas las interfaces
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
