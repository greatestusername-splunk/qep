FROM python:3.11-slim

# Set working directory
WORKDIR /app
ENV PYTHONUNBUFFERED=1

# Copy requirements over
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN opentelemetry-bootstrap -a install
RUN export OTEL_SERVICE_NAME=creditcheckservice
RUN export OTEL_RESOURCE_ATTRIBUTES='deployment.environment=qep,service.version=2.0'
RUN export OTEL_PYTHON_DISABLED_INSTRUMENTATIONS=aws-lambda

# Copy main app
COPY main.py .

# Set the entrypoint command to run the application
CMD ["opentelemetry-instrument", "python3", "main.py"]
