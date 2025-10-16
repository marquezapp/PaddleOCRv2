# ---------- Dockerfile (CPU) ----------
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PADDLE_HOME=/models/paddle \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    curl wget jq poppler-utils \
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 libgomp1 libopenblas0 \
    && rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /app

RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
        numpy==1.26.4 \
        opencv-python-headless==4.9.0.80 \
        pillow==10.3.0 \
        PyMuPDF==1.24.9 \
        flask==3.0.3 \
        waitress==2.1.2 \
        paddlepaddle==2.6.1 \
        paddleocr==2.8.1 \
        requests==2.32.3

COPY . .

EXPOSE 8000
VOLUME ["/models"]

# Healthcheck robusto
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8000/health | grep -q '"status":"ok"' || exit 1

# Arranque Flask con Waitress en 8000
CMD ["waitress-serve", "--listen=0.0.0.0:8000", "app:app"]
# ---------- fin Dockerfile ----------
