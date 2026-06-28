# ========================== #
# Builder Stage              #
# ========================== #

FROM python:3.12-slim AS builder

# Instalar uv (Python Package Manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Copiar arquivos de dependências
COPY app/requirements.txt .

# Instalar dependências usando uv (mais rápido e confiável)
RUN uv pip install \
    --no-cache-dir \
    --system \
    -r requirements.txt

# ========================== #
# Runtime Stage              #
# ========================== #

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copiar dependências instaladas do builder
COPY --from=builder /usr/local /usr/local

# Criar usuário não-root (compatível com Linux)
RUN useradd \
    --system \
    --uid 10001 \
    --create-home \
    appuser

# Copiar código da aplicação
COPY . /app

# Ajustar permissões
RUN chown -R appuser:appuser /app

# Mudar para usuário não-root (segurança)
USER appuser

EXPOSE 8000

# Healthcheck usando Python padrão (disponível na imagem base)
HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

# Comando de inicialização
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]