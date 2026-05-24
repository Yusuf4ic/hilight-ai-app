"""
gemini_service.py — Handles text extraction from images and chat via Google Gemini.
"""

import base64
import os

# ── Real Gemini extraction ─────────────────────────────────────────────────────

def extract_text_from_image(image_path: str, api_key: str) -> dict:
    """Send image to Gemini and extract text."""
    try:
        import google.generativeai as genai
        genai.configure(api_key=api_key)

        with open(image_path, 'rb') as f:
            image_data = f.read()

        model = genai.GenerativeModel('gemini-2.0-flash')
        image_part = {
            "mime_type": "image/jpeg",
            "data": base64.b64encode(image_data).decode('utf-8')
        }

        prompt = (
            "You are an intelligent text extraction assistant. "
            "Extract ALL text visible in this image accurately. "
            "Then identify the most important highlights or key ideas (up to 3). "
            "Respond ONLY in JSON with this structure:\n"
            "{\n"
            "  \"extracted_text\": \"full text here\",\n"
            "  \"highlights\": [\"highlight1\", \"highlight2\"],\n"
            "  \"title\": \"short descriptive title\",\n"
            "  \"confidence\": \"high/medium/low\",\n"
            "  \"language\": \"detected language\"\n"
            "}"
        )

        response = model.generate_content([prompt, image_part])
        text = response.text.strip()

        # Strip markdown code block if present
        if text.startswith("```"):
            text = text.split("```")[1]
            if text.startswith("json"):
                text = text[4:]
            text = text.strip()

        import json
        data = json.loads(text)
        return {
            "success": True,
            "extracted_text": data.get("extracted_text", ""),
            "highlights": data.get("highlights", []),
            "title": data.get("title", ""),
            "confidence": data.get("confidence", "medium"),
            "language": data.get("language", "unknown"),
            "mock": False
        }

    except Exception as e:
        print(f"[Gemini] Error during extraction: {e}")
        return {"success": False, "error": str(e)}


# ── Mock extraction (no API key) ───────────────────────────────────────────────

def mock_extract(image_path: str) -> dict:
    """Return sample data when Gemini API key is not configured."""
    filename = os.path.basename(image_path)
    print(f"[Gemini] MOCK MODE — no API key, returning sample data for {image_path}")
    return {
        "success": True,
        "extracted_text": (
            "\"The whole point of abundance is to subtract the obvious "
            "and add the meaningful.\"\n\n— Austin Kleon, Steal Like An Artist"
        ),
        "highlights": [
            "Subtract the obvious, add the meaningful.",
            "Creativity lives in constraints.",
        ],
        "title": "Steal Like An Artist — Key Quote",
        "confidence": "high",
        "language": "English",
        "mock": True,
        "image_filename": filename
    }


# ── Chat with Gemini ───────────────────────────────────────────────────────────

def chat_with_gemini(messages: list, api_key: str) -> dict:
    """
    Multi-turn chat with Gemini.
    messages: list of {"role": "user"|"model", "text": "..."}
    """
    if not api_key:
        return {
            "success": True,
            "reply": (
                "⚠️ API key not configured. "
                "Please add GEMINI_API_KEY to backend/.env to get real AI responses."
            )
        }

    try:
        import google.generativeai as genai
        genai.configure(api_key=api_key)

        model = genai.GenerativeModel(
            model_name='gemini-2.0-flash',
            system_instruction=(
                "You are Lumi — a friendly, intelligent educational AI assistant "
                "embedded in the HiLight app. You help students understand, summarize, "
                "and discuss text they have scanned or written. Be concise, supportive, "
                "and academically helpful. Respond in the same language as the user."
            )
        )

        # Build history (all but the last message)
        history = []
        for msg in messages[:-1]:
            role = msg.get("role", "user")
            if role not in ("user", "model"):
                role = "user"
            history.append({
                "role": role,
                "parts": [msg.get("text", "")]
            })

        chat = model.start_chat(history=history)

        # Send the last user message
        last_msg = messages[-1].get("text", "")
        response = chat.send_message(last_msg)

        return {"success": True, "reply": response.text}

    except Exception as e:
        print(f"[Gemini] Chat error: {e}")
        return {"success": False, "error": str(e)}
