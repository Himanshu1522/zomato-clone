from flask import Flask, jsonify, request
from datetime import datetime

app = Flask(__name__)

@app.route('/', methods=['GET'])
def get_time_and_ip():
    # Get current timestamp
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Get visitor's IP address
    # For Docker, we need to handle potential proxies
    if request.headers.get('X-Forwarded-For'):
        client_ip = request.headers.get('X-Forwarded-For').split(',')[0]
    else:
        client_ip = request.remote_addr
    
    # Create response data
    response_data = {
        "timestamp": current_time,
        "ip": client_ip
    }
    
    return jsonify(response_data)

if __name__ == '__main__':
    # Make sure to use 0.0.0.0 to allow external connections
    app.run(host='0.0.0.0', port=5002, debug=True)

