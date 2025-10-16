# ---------- Dockerfile (CPU) ----------
# Base estable con ruedas recientes
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PADDLE_HOME=/models/paddle \
    PYTHONUNBUFFERED=1

# Paquetes del sistema necesarios para OpenCV, PyMuPDF y utilidades
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    jq \
    poppler-utils \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    libopenblas0 \
    && rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /app

# Herramientas de build + versiones de wheels compatibles
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

# Copia tu código (incluye app.py y healthcheck.py del repo)
COPY . .

# Puerto expuesto por la app
EXPOSE 8000

# Volumen para cachear modelos de PaddleOCR
VOLUME ["/models"]

# Healthcheck: usa tu healthcheck.py que consulta /health
HEALTHCHECK --interval=30s --timeout=5s \
  CMD python healthcheck.py || exit 1

# --- ARRANQUE ---
# Flask con waitress escuchando en 0.0.0.0:8000
# (tu app.py debe tener "app = Flask(__name__)")
CMD ["waitress-serve", "--listen=0.0.0.0:8000", "app:app"]
# ---------- fin Dockerfile ----------
