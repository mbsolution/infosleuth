import os
import json
import logging
import base64
import requests

from flask import Flask, request, Response

# ─── CORS setup ───────────────
try:
    from flask_cors import CORS
except ImportError:
    CORS = lambda app: None

# ─── OpenAI SDK (v1+) ─────────
try:
    import openai
    OPENAI_AVAILABLE = True
except ImportError:
    openai = None
    OPENAI_AVAILABLE = False

# ─── Flask init ───────────────
app = Flask(__name__)
CORS(app)
logging.basicConfig(level=logging.INFO)


def make_json_response(data: dict, status: int = 200) -> Response:
    payload = json.dumps(data, ensure_ascii=False)
    return Response(
        payload,
        status=status,
        mimetype='application/json; charset=utf-8'
    )


@app.after_request
def apply_cors(response: Response) -> Response:
    response.headers['Access-Control-Allow-Origin']  = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    return response


@app.route('/', methods=['GET', 'OPTIONS'])
def root():
    if request.method == 'OPTIONS':
        return '', 200
    return make_json_response({'status': 'orchestrator running'})


@app.route('/api/orchestrate', methods=['OPTIONS', 'POST'])
def orchestrate():
    if request.method == 'OPTIONS':
        return '', 200

    data  = request.get_json(force=True, silent=True) or {}
    query = data.get('query', '').strip()
    if not query:
        return make_json_response({'response': 'Error: No query provided.'}, 400)

    logging.info(f"Chat query: '{query}'")
    api_key = os.getenv('OPENAI_API_KEY')

    if OPENAI_AVAILABLE and api_key:
        try:
            client = openai.OpenAI(api_key=api_key)
            chat   = client.chat.completions.create(
                model='gpt-4o-mini',
                messages=[
                    {'role': 'system', 'content': 'You are a multilingual OSINT assistant.'},
                    {'role':   'user', 'content': query}
                ],
                temperature=0.2
            )
            text = chat.choices[0].message.content
        except Exception as e:
            logging.error("OpenAI error", exc_info=e)
            text = f"🔍 Stub response for: '{query}'"
    else:
        text = f"🔍 Stub response for: '{query}'"

    return make_json_response({'response': text})


@app.route('/api/search', methods=['OPTIONS', 'POST'])
@app.route('/api/search_image', methods=['OPTIONS', 'POST'])
def search():
    if request.method == 'OPTIONS':
        return '', 200

    # file upload?
    if 'file' in request.files:
        f   = request.files['file']
        img = f.read()
        b64 = base64.b64encode(img).decode('utf-8')
        typ, query = 'image', b64
    else:
        p     = request.get_json(force=True, silent=True) or {}
        typ   = p.get('type')
        query = p.get('query','').strip()

    if typ not in ('phone','email','address','social','image'):
        return make_json_response({'error': f"Unsupported '{typ}'"}, 400)
    if not query:
        return make_json_response({'error': 'No query provided.'}, 400)

    if typ == 'image':
        result = image_lookup(query)
    else:
        result = {'message': f"Stub {typ} lookup for '{query}'"}

    return make_json_response({'type': typ, 'query': query, 'result': result})


def image_lookup(data: str) -> dict:
    """
    Takes a base64-encoded JPEG string and returns
    google_web and saucenao results.
    """
    res = {'google_web': {}, 'saucenao': {}}

    # — Google Vision Web Detection —
    gv_key = os.getenv('GOOGLE_VISION_API_KEY')
    if gv_key:
        try:
            body = {
                'requests': [{
                    'image': {'content': data},
                    'features': [{'type': 'WEB_DETECTION'}]
                }]
            }
            r = requests.post(
                'https://vision.googleapis.com/v1/images:annotate',
                params={'key': gv_key},
                json=body,
                timeout=10
            )
            r.raise_for_status()
            payload = r.json()
            if payload.get('responses'):
                res['google_web'] = payload['responses'][0].get('webDetection', {}) or {}
            else:
                res['google_web'] = {'error': 'no responses key in JSON'}
        except Exception:
            logging.exception("Google Vision failed")
            res['google_web'] = {'error': 'Google Vision request failed'}
    else:
        res['google_web'] = {'stub': True}


    # — SauceNAO reverse-image search with retry (now using POST+file) —
    sn_key = os.getenv('SAUCENAO_API_KEY')
    if sn_key:
        sauce_result = None
        # decode once
        img_bytes = base64.b64decode(data)
        for attempt in range(1, 4):
            try:
                logging.info(f"SauceNAO attempt {attempt}/3 (POST file upload)")
                files   = {
                    # name "file" is per SauceNAO docs
                    'file': ('upload.jpg', img_bytes)
                }
                payload = {
                    'output_type': 2,
                    'api_key':     sn_key
                }
                r2 = requests.post(
                    'https://saucenao.com/search.php',
                    data=payload,
                    files=files,
                    timeout=20
                )
                if r2.status_code != 200:
                    logging.warning(f"SauceNAO returned HTTP {r2.status_code}")
                    raise requests.HTTPError(f"HTTP {r2.status_code}")
                # JSON comes back
                sauce_result = r2.json() or {}
                break
            except Exception as e:
                logging.warning(f"SauceNAO attempt {attempt} failed: {e}")
                if attempt == 3:
                    sauce_result = {
                        'error': "SauceNAO lookup failed after 3 attempts",
                        'stub':  True
                    }
        res['saucenao'] = sauce_result
    else:
        res['saucenao'] = {'stub': True}

    return res


@app.route('/api/health', methods=['GET', 'OPTIONS'])
def health():
    if request.method == 'OPTIONS':
        return '', 200

    status = 'ok'
    if OPENAI_AVAILABLE and not os.getenv('OPENAI_API_KEY'):
        status = 'warning: no OPENAI key'
    return make_json_response({'status': status})


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8081))
    logging.info(f"Running on port {port}")
    app.run('0.0.0.0', port=port)
