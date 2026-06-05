from fastapi import FastAPI
from fastapi.responses import JSONResponse

from app.api.routes import router
from app.core.config import APP_NAME

from app.observability.metrics import REQUEST_COUNTER
from app.observability.telemetry import configure_telemetry

app = FastAPI(title=APP_NAME)

configure_telemetry(app)


@app.middleware("http")
async def request_counter_middleware(
    request,
    call_next,
):
    excluded_paths = {
        "/metrics",
        "/docs",
        "/redoc",
        "/openapi.json",
        "/favicon.ico",
    }

    if request.url.path not in excluded_paths:
        REQUEST_COUNTER.inc()

    response = await call_next(request)

    return response


app.include_router(router)


@app.exception_handler(Exception)
async def global_exception_handler(
    request,
    exc,
):
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
        },
    )