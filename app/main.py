from fastapi import FastAPI
from fastapi.responses import JSONResponse

from app.api.routes import router
from app.core.config import APP_NAME

from app.observability.telemetry import (
    configure_telemetry,
)

app = FastAPI(title=APP_NAME)

configure_telemetry(app)

app.include_router(router)


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):

    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )