import requests
import os
from datetime import datetime

SNAPSHOT_URL = "http://192.168.8.107/capture"
OUTPUT_DIR = "captures"

os.makedirs(OUTPUT_DIR, exist_ok=True)

response = requests.get(SNAPSHOT_URL, timeout=5)
if response.status_code == 200:
    filename = datetime.now().strftime("%Y%m%d_%H%M%S") + ".jpg"
    filepath = os.path.join(OUTPUT_DIR, filename)
    with open(filepath, "wb") as f:
        f.write(response.content)
    print(f"Image saved to {filepath}")
else:
    print(f"Failed: HTTP {response.status_code}")
