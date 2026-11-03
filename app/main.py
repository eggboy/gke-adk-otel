"""Entry point: load .env, then serve the ADK chat web UI.

ADK reads the CR-injected OTEL_EXPORTER_OTLP_* env vars and sets up
OTLP/HTTP exporters plus GenAI instrumentation on its own (google-adk[otel]).
"""

import logging
import os

from dotenv import load_dotenv

load_dotenv()
logging.basicConfig(level=logging.INFO)

from google.adk.cli.fast_api import get_fast_api_app  # noqa: E402

AGENTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "agents")

app = get_fast_api_app(agents_dir=AGENTS_DIR, web=True)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", "8080")))
