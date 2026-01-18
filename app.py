from flask import Flask, jsonify
import os
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/health', methods=['GET'])
def health():
    """
    Health check endpoint
    Returns 200 OK if the service is running
    """
    logger.info('Health check requested')
    return jsonify({
        'status': 'healthy',
        'service': 'azodha-api',
        'version': '1.0.0'
    }), 200

@app.route('/predict', methods=['GET'])
def predict():
    """
    Prediction endpoint
    Returns a prediction score
    """
    logger.info('Prediction requested')
    return jsonify({
        'score': 0.75
    }), 200

@app.route('/', methods=['GET'])
def index():
    """
    Root endpoint
    Returns API information
    """
    return jsonify({
        'service': 'Azodha Health Prediction API',
        'version': '1.0.0',
        'endpoints': {
            '/health': 'Health check endpoint',
            '/predict': 'Prediction endpoint'
        }
    }), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
