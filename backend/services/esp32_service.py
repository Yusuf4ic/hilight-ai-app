import os
import requests
from datetime import datetime

# Simple health check to see if ESP32 device is reachable
def check_connection(esp32_ip: str) -> bool:
    try:
        resp = requests.get(f'http://{esp32_ip}/status', timeout=2)
        return resp.status_code == 200
    except Exception:
        return False

# Capture image from ESP32-CAM
def capture_image(esp32_ip: str):
    try:
        resp = requests.get(f'http://{esp32_ip}/capture', timeout=5)
        if resp.status_code != 200:
            return {'success': False, 'error': f'Status {resp.status_code}'}
        # Save image to captures folder
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        ext = resp.headers.get('Content-Type', 'image/jpeg').split('/')[-1]
        filename = f"capture_{timestamp}.{ext}"
        captures_dir = os.path.join(os.path.dirname(__file__), '..', 'captures')
        os.makedirs(captures_dir, exist_ok=True)
        filepath = os.path.join(captures_dir, filename)
        with open(filepath, 'wb') as f:
            f.write(resp.content)
        return {'success': True, 'filepath': filepath, 'filename': filename}
    except Exception as e:
        return {'success': False, 'error': str(e)}
