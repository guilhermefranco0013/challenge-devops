import os

from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor


def configure_telemetry(app: FastAPI) -> None:

    resource = Resource.create(
        {
            "service.name": os.getenv(
                "OTEL_SERVICE_NAME",
                "challenge-devops-api",
            ),
            "deployment.environment": os.getenv(
                "DEPLOYMENT_ENVIRONMENT",
                "dev",
            ),
        }
    )

    tracer_provider = TracerProvider(
        resource=resource,
    )

    trace.set_tracer_provider(tracer_provider)

    otel_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT")

    if otel_endpoint:

        tracer_provider.add_span_processor(
            BatchSpanProcessor(
                OTLPSpanExporter(
                    endpoint=f"{otel_endpoint}/v1/traces",
                )
            )
        )

    FastAPIInstrumentor.instrument_app(app)
