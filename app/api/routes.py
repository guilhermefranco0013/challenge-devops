from fastapi import APIRouter
from prometheus_client import generate_latest
from starlette.responses import Response

from app.core.config import APP_ENV
from app.observability.logging import logger

router = APIRouter()


@router.get("/")
async def root():

    logger.info("root_endpoint_called")

    return {
        "status": "ok",
        "message": "Service is healthy",
        "service": "challenge-devops",
        "version": "1.0.0",
        "uptime": "0d 0h 0m",
        "environment": APP_ENV,
    }


@router.get("/health")
async def health():

    logger.info("healthcheck_called")

    return {
        "status": "ok",
        "message": "Service is completely healthy",
        "service": "challenge-devops",
        "version": "1.0.0",
        "uptime": "0d 0h 0m",
        "environment": APP_ENV,
    }


@router.get("/metrics")
async def metrics():

    return Response(
        generate_latest(),
        media_type="text/plain",
    )
