from fastapi import APIRouter
from fastapi.responses import JSONResponse
from prometheus_client import generate_latest
from starlette.responses import Response

from observability.logging import logger
from observability.metrics import REQUEST_COUNTER

router = APIRouter()


@router.get("/")
async def root():

    REQUEST_COUNTER.inc()

    logger.info(
        "root_endpoint_called"
    )

    return {
        "message": "Challenge DevOps API"
    }


@router.get("/health")
async def health():

    logger.info(
        "healthcheck_called"
    )

    return {
        "status": "healthy"
    }


@router.get("/metrics")
async def metrics():

    return Response(
        generate_latest(),
        media_type="text/plain"
    )