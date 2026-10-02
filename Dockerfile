# Python 3.12, slim version (pydub breaks on Python 3.13+)
FROM python:3.12-slim

# pydub needs ffmpeg, which pip can't install; remove the apt cache to keep the image small
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies first, so this layer is reused when only the code changes
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app files (.dockerignore filters out what we don't need)
COPY . .

EXPOSE 5000

# app.py hard-codes port 3000, so run it with gunicorn on port 5000 instead.
# 0.0.0.0 lets Docker's port mapping reach the app inside the container.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
