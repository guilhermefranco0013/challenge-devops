import os

from opentelemetry import trace

from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider

from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
)

from opentelemetry.exporter.otlp.proto.http.trace_exporter import (
    OTLPSpanExporter,
)

from opentelemetry.instrumentation.fastapi import (
    FastAPIInstrumentor,
)


def configure_telemetry(app):

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

    trace.set_tracer_provider(
        TracerProvider(
            resource=resource,
        )
    )

    tracer_provider = trace.get_tracer_provider()

    otel_endpoint = os.getenv(
        "OTEL_EXPORTER_OTLP_ENDPOINT"
    )

    if otel_endpoint:

        tracer_provider.add_span_processor(
            BatchSpanProcessor(
                OTLPSpanExporter(
                    endpoint=otel_endpoint,
                )
            )
        )

    FastAPIInstrumentor.instrument_app(app)