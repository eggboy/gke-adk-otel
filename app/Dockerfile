FROM python:3.13-slim

WORKDIR /app

COPY pyproject.toml ./
RUN pip install --no-cache-dir uv && uv pip install --system -r pyproject.toml

COPY main.py ./
COPY agents/ ./agents/

ENV PORT=8080
EXPOSE 8080

CMD ["python", "main.py"]
