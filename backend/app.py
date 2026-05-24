"""
HiLight Backend — Flask API Server
Orchestrates ESP32-CAM capture → Gemini text extraction pipeline.

Temporary HTML UI included for prototyping (will be removed when
a physical button is added to the ESP32 circuit).
"""

from flask import Flask, render_template_string, jsonify, request
from flask_cors import CORS
import os
from datetime import datetime, timezone

from dotenv import load_dotenv, dotenv_values
load_dotenv(override=True)

from services.esp32_service import capture_image, check_connection
from services.gemini_service import extract_text_from_image, mock_extract, chat_with_gemini

app = Flask(__name__)
CORS(app)

# Read directly from .env file to avoid Flask reloader caching issues
_env = dotenv_values()
ESP32_CAM_IP = _env.get("ESP32_CAM_IP", "172.20.10.2")
GEMINI_API_KEY = _env.get("GEMINI_API_KEY", "")


# ──────────────────────────────────────────
# Temporary HTML UI (will be removed later)
# ──────────────────────────────────────────
HTML_INTERFACE = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HiLight — Smart Scanner</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
            text-align: center; 
            background: #F5F0E8; 
            padding: 20px;
            min-height: 100vh;
        }
        .container { max-width: 400px; margin: 0 auto; }
        h2 { color: #2C2C2A; margin-top: 30px; font-size: 24px; }
        .subtitle { color: #5F5E5A; margin-top: 8px; font-size: 14px; }
        
        .btn { 
            background: #F5A623; color: white; border: none; 
            padding: 18px 40px; font-size: 18px; border-radius: 12px; 
            cursor: pointer; width: 100%; max-width: 300px; margin-top: 30px;
            font-weight: 600; transition: all 0.2s;
            box-shadow: 0 4px 12px rgba(245, 166, 35, 0.3);
        }
        .btn:active { transform: scale(0.97); background: #E09510; }
        .btn:disabled { background: #ccc; cursor: not-allowed; box-shadow: none; }
        
        .status { 
            margin-top: 16px; font-size: 13px; color: #5F5E5A;
            min-height: 20px;
        }
        
        #result { 
            margin-top: 20px; font-size: 15px; color: #2C2C2A; 
            padding: 20px; background: white; border-radius: 12px; 
            display: none; text-align: left; line-height: 1.6;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            border-left: 4px solid #F5A623;
        }
        #result .label { 
            font-size: 11px; text-transform: uppercase; letter-spacing: 1px;
            color: #F5A623; font-weight: 700; margin-bottom: 8px; 
        }
        #result .text { white-space: pre-wrap; }
        
        .highlights { 
            margin-top: 12px; padding-top: 12px; border-top: 1px solid #eee; 
        }
        .highlights .label { color: #7F77DD; }
        .highlight-item {
            background: rgba(127, 119, 221, 0.08); padding: 8px 12px;
            border-radius: 8px; margin-top: 6px; font-style: italic;
            border-left: 3px solid #7F77DD;
        }
        
        .meta { 
            margin-top: 12px; font-size: 11px; color: #999; 
            padding-top: 8px; border-top: 1px solid #eee; 
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>📖 HiLight</h2>
        <p class="subtitle">Hold the camera over text and scan</p>
        
        <button class="btn" id="scanBtn" onclick="scanText()">📸 Scan Text</button>
        <div class="status" id="status"></div>
        <div id="result"></div>
    </div>

    <script>
        async function scanText() {
            const btn = document.getElementById('scanBtn');
            const status = document.getElementById('status');
            const resultDiv = document.getElementById('result');
            
            btn.disabled = true;
            btn.innerText = '⏳ Scanning...';
            status.innerText = 'Capturing image from ESP32-CAM...';
            resultDiv.style.display = 'none';
            
            try {
                const response = await fetch('/api/scan', { method: 'POST' });
                const data = await response.json();
                
                if (data.success) {
                    status.innerText = '';
                    let html = `<div class="label">📝 Extracted Text</div>`;
                    html += `<div class="text">${data.extracted_text || 'No text found'}</div>`;
                    
                    if (data.highlights && data.highlights.length > 0) {
                        html += `<div class="highlights"><div class="label">✨ Highlights</div>`;
                        data.highlights.forEach(h => {
                            html += `<div class="highlight-item">${h}</div>`;
                        });
                        html += `</div>`;
                    }
                    
                    let meta = [];
                    if (data.confidence) meta.push(`Confidence: ${data.confidence}`);
                    if (data.language) meta.push(`Language: ${data.language}`);
                    if (data.mock) meta.push('⚠️ Mock data (no API key)');
                    if (data.image_filename) meta.push(`File: ${data.image_filename}`);
                    if (meta.length) html += `<div class="meta">${meta.join(' · ')}</div>`;
                    
                    resultDiv.innerHTML = html;
                    resultDiv.style.display = 'block';
                } else {
                    status.innerText = '❌ ' + (data.error || 'Unknown error');
                }
            } catch (err) {
                status.innerText = '❌ Cannot reach backend: ' + err.message;
            }
            
            btn.disabled = false;
            btn.innerText = '📸 Scan Text';
        }
    </script>
</body>
</html>
"""


# ──────────────────────────────────────────
# Shared scan state (in-memory for prototype)
# ──────────────────────────────────────────
latest_scan = {"result": None, "scan_id": 0}


def _run_scan_pipeline():
    """Shared scan logic: ESP32 capture -> Gemini -> store result."""
    global latest_scan

    capture_result = capture_image(esp32_ip=ESP32_CAM_IP)

    if not capture_result["success"]:
        return {
            "success": False,
            "stage": "capture",
            "error": capture_result["error"]
        }

    image_path = capture_result["filepath"]

    if GEMINI_API_KEY:
        extraction = extract_text_from_image(image_path, api_key=GEMINI_API_KEY)
    else:
        print("[API] No GEMINI_API_KEY set -- using mock extraction")
        extraction = mock_extract(image_path)

    response = {
        "success": extraction.get("success", False),
        "image_filename": capture_result["filename"],
        "extracted_text": extraction.get("extracted_text"),
        "highlights": extraction.get("highlights", []),
        "title": extraction.get("title"),
        "page_number": extraction.get("page_number"),
        "confidence": extraction.get("confidence"),
        "language": extraction.get("language"),
        "mock": extraction.get("mock", False),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "error": extraction.get("error")
    }

    # Store for polling
    latest_scan["scan_id"] += 1
    response["scan_id"] = latest_scan["scan_id"]
    latest_scan["result"] = response

    return response


# ──────────────────────────────────────────
# Routes
# ──────────────────────────────────────────

@app.route('/')
def home():
    """Temporary HTML UI for prototyping."""
    return render_template_string(HTML_INTERFACE)


@app.route('/api/scan', methods=['POST'])
def scan_text():
    """Called by Flutter app scan button (ESP32 path) or temp HTML UI."""
    result = _run_scan_pipeline()
    # Always return 200 so Flutter can read the error message properly
    return jsonify(result), 200


@app.route('/api/scan-upload', methods=['POST'])
def scan_upload():
    """Called by Flutter app when uploading a photo taken with device camera."""
    if 'image' not in request.files:
        return jsonify({"success": False, "error": "No image file uploaded"}), 400
        
    file = request.files['image']
    if file.filename == '':
        return jsonify({"success": False, "error": "No selected file"}), 400
        
    try:
        # Save temp file
        temp_dir = os.path.join(os.path.dirname(__file__), 'temp')
        os.makedirs(temp_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        temp_path = os.path.join(temp_dir, f"upload_{timestamp}.jpg")
        file.save(temp_path)
        
        # Run extraction
        if GEMINI_API_KEY:
            extraction = extract_text_from_image(temp_path, api_key=GEMINI_API_KEY)
        else:
            print("[API] No GEMINI_API_KEY set -- using mock extraction")
            extraction = mock_extract(temp_path)
            
        response = {
            "success": extraction.get("success", False),
            "image_filename": f"upload_{timestamp}.jpg",
            "extracted_text": extraction.get("extracted_text"),
            "highlights": extraction.get("highlights", []),
            "title": extraction.get("title"),
            "page_number": extraction.get("page_number"),
            "confidence": extraction.get("confidence"),
            "language": extraction.get("language"),
            "mock": extraction.get("mock", False),
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "error": extraction.get("error")
        }
        
        # Clean up temp file
        try:
            os.remove(temp_path)
        except Exception:
            pass
            
        status_code = 200 if response.get("success") else 500
        return jsonify(response), status_code
        
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/device-scan', methods=['POST', 'GET'])
def device_scan():
    """
    Endpoint for the ESP32 hardware button.
    When pressed, ESP32 calls this URL. Result stored for Flutter polling.
    GET allowed so ESP32 can use a simple HTTP GET.
    """
    print("[DEVICE] Hardware button triggered scan!")
    result = _run_scan_pipeline()
    status_code = 200 if result.get("success") else 500
    return jsonify(result), status_code


@app.route('/api/latest')
def get_latest():
    """
    Flutter polls this to detect new scans from the hardware button.
    Query param: ?after=<scan_id> -- only returns if there is a newer result.
    """
    after = request.args.get('after', 0, type=int)

    if latest_scan["result"] is None:
        return jsonify({"has_new": False, "scan_id": 0})

    current_id = latest_scan["scan_id"]
    if current_id > after:
        return jsonify({
            "has_new": True,
            "scan_id": current_id,
            "result": latest_scan["result"]
        })
    else:
        return jsonify({"has_new": False, "scan_id": current_id})


@app.route('/api/health')
def health():
    """Health check."""
    esp32_ok = check_connection(ESP32_CAM_IP)
    return jsonify({
        "backend": "ok",
        "esp32_cam": "reachable" if esp32_ok else "unreachable",
        "esp32_ip": ESP32_CAM_IP,
        "gemini_configured": bool(GEMINI_API_KEY)
    })


@app.route('/api/chat', methods=['POST'])
def chat():
    """Handle chat messages with Gemini."""
    data = request.get_json()
    if not data or 'messages' not in data:
        return jsonify({"success": False, "error": "No messages provided"}), 400
        
    messages = data['messages']
    result = chat_with_gemini(messages, api_key=GEMINI_API_KEY)
    
    status_code = 200 if result.get("success") else 500
    return jsonify(result), status_code


# ──────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 50)
    print("  HiLight Backend -- Prototype Server")
    print(f"  ESP32-CAM IP: {ESP32_CAM_IP}")
    print(f"  Gemini API:   {'[OK] Configured' if GEMINI_API_KEY else '[!] Not set (mock mode)'}")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=True)
