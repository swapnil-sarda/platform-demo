import json
import logging
import sys

from fastapi import FastAPI, Request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest
from starlette.responses import Response


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        return json.dumps(
            {
                "level": record.levelname,
                "logger": record.name,
                "message": record.getMessage(),
            }
        )


logger = logging.getLogger("payments-api")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
logger.handlers = [handler]
logger.propagate = False

REQUESTS_TOTAL = Counter(
    "payments_api_requests_total",
    "Total HTTP requests served by payments-api",
    ["path", "method"],
)

app = FastAPI(title="payments-api", version="0.1.0")


@app.middleware("http")
async def log_request(request: Request, call_next):
    response = await call_next(request)
    REQUESTS_TOTAL.labels(path=request.url.path, method=request.method).inc()
    logger.info(
        "request_completed path=%s method=%s status_code=%s",
        request.url.path,
        request.method,
        response.status_code,
    )
    return response


@app.get("/")
def root():
    return {
        "service": "payments-api",
        "message": "Platform Paved Path is working",
    }


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/metrics")
def metrics():
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)
