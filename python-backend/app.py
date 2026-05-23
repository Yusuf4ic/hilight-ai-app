from flask import Flask, render_template_string, jsonify
import requests
import os
from datetime import datetime

app = Flask(__name__)
os.makedirs("captures", exist_ok=True)

# ⚠️ REPLACE THIS WITH YOUR ACTUAL ESP32-CAM IP ADDRESS
ESP32_CAM_IP = "192.168.8.107" 
SNAPSHOT_URL = "http://192.168.8.107/capture"

# A simple, clean mobile UI with a button
HTML_INTERFACE = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Highlighter MVP</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; background: #f4f4f9; padding: 20px; }
        .btn { background: #007bff; color: white; border: none; padding: 20px 40px; font-size: 20px; border-radius: 10px; cursor: pointer; width: 80%; max-width: 300px; margin-top: 30px; }
        .btn:active { background: #0056b3; }
        #result { margin-top: 30px; font-size: 18px; font-weight: bold; color: #333; padding: 15px; background: white; border-radius: 8px; display: none; }
    </style>
</head>
<body>
    <h2>Smart Highlighter</h2>
    <p>Hold the camera over the text and click below:</p>
    
    <button class="btn" onclick="captureText()">📸 Scan Text</button>
    <div id="result">Processing...</div>

    <script>
        function captureText() {
            const resultDiv = document.getElementById('result');
            resultDiv.style.display = 'block';
            resultDiv.innerText = 'Capturing frame from ESP32-CAM...';
            
            fetch('/capture')
                .then(response => response.json())
                .then(data => {
                    resultDiv.innerText = data.status;
                })
                .catch(err => {
                    resultDiv.innerText = 'Error connecting to backend.';
                });
        }
    </script>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_INTERFACE)

@app.route('/capture')
def capture_frame():
    try:
        print(f"Sending request to ESP32 at: {SNAPSHOT_URL}")
        # Fetch the single snapshot directly from the camera hardware memory
        response = requests.get(SNAPSHOT_URL, timeout=5)
        
        if response.status_code == 200:
            filename = datetime.now().strftime("%Y%m%d_%H%M%S") + ".jpg"
            filepath = os.path.join("captures", filename)
            with open(filepath, "wb") as f:
                f.write(response.content)
            print(f"Success: Snapshot saved as {filepath}")
            return jsonify({"status": f"Snapshot saved as {filename}. Ready for OCR stage."})
        else:
            print(f"Camera returned an error code: {response.status_code}")
            return jsonify({"status": f"Camera returned an error code: {response.status_code}"})
            
    except requests.exceptions.Timeout:
        print("Error: The request to the ESP32-CAM timed out.")
        return jsonify({"status": "Failed: Camera timed out. Is any other tab streaming video?"})
    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"status": f"Failed: {str(e)}"})

if __name__ == '__main__':
    # Runs the server on port 5000, accessible to your phone
    app.run(host='0.0.0.0', port=5000, debug=True)