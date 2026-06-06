# ========================== #
# Builder Stage              #
# ========================== #

FROM python:3.12-slim AS builder

WORKDIR /app

COPY app/requirements.txt .

RUN pip install \
    --no-cache-dir \
    --user \
    -r requirements.txt

# ========================== #
# Runtime Stage              #
# ========================== #

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copia dependências instaladas no builder
COPY --from=builder /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

# Cria usuário não-root
RUN useradd \
    --system \
    --uid 10001 \
    --create-home \
    appuser

# Copia aplicação
COPY . /app

# Ajusta permissões
RUN chown -R appuser:appuser /app

# Executa como usuário não-root
USER appuser

EXPOSE 8000

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]