import os
import requests
from flask import Flask, request
from waitress import serve
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.trace import SpanKind

# Set up OpenTelemetry
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Add a ConsoleSpanExporter for demonstration purposes
span_processor = BatchSpanProcessor(ConsoleSpanExporter())
trace.get_tracer_provider().add_span_processor(span_processor)

app = Flask(__name__)

@app.route('/')
def hello():
    print("Received request at '/' endpoint")
    return 'Hello'

@app.route('/test')
def test_it():
    print("Received request at '/test' endpoint")
    return 'OK'

@app.route('/check')
def credit_check():
    customerNum = request.args.get('customernum')
    print(f"Received request at '/check' endpoint with customernum: {customerNum}")

    # Get Credit Score
    try:
        creditScoreReq = requests.get(f"http://creditprocessorservice:8899/getScore?customernum={customerNum}")
        creditScoreReq.raise_for_status()
        creditScore = int(creditScoreReq.text)
        print(f"Retrieved credit score: {creditScore}")
    except requests.exceptions.RequestException as e:
        print(f"Error retrieving credit score: {e}")
        return "Error retrieving credit score", 500

    creditScoreCategory = getCreditCategoryFromScore(creditScore)

    # Run Credit Check
    try:
        creditCheckReq = requests.get(f"http://creditprocessorservice:8899/runCreditCheck?customernum={customerNum}&score={creditScore}")
        creditCheckReq.raise_for_status()
        checkResult = str(creditCheckReq.text)
        print(f"Credit check result: {checkResult}")
    except requests.exceptions.RequestException as e:
        print(f"Error running credit check: {e}")
        return "Error running credit check", 500

    return checkResult

def getCreditCategoryFromScore(score):
    # Retrieve NODE_IP from environment variable
    node_ip = os.getenv('NODE_IP', 'localhost')  # Default to 'localhost' if NODE_IP is not set
    url = f"http://{node_ip}:8080/owners"
    print(f"Using NODE_IP: {node_ip}")

    peer_service_value = "APPDYNAMICS_AGENT_APPLICATION_NAME" # we replace this value with ansible pre-build
    
    # Manually create a span for the request
    with tracer.start_as_current_span("HTTP GET to /vet", kind=SpanKind.CLIENT) as span:
        span.set_attribute("http.url", url)
        span.set_attribute("peer.service", peer_service_value)  # Name of the external service

        try:
            print(url)
            response = requests.get(url)
            span.set_attribute("http.status_code", response.status_code)
            print(f"Response from external service: {response.text}")
        except requests.exceptions.RequestException as e:
            span.record_exception(e)
            span.set_attribute("http.status_code", 500)
            print(f"Error contacting external service: {e}")

    creditScoreCategory = ''
    match score:
        case num if num > 850:
            creditScoreCategory = 'impossible'
        case num if 800 <= num <= 850:
            creditScoreCategory = 'exceptional'
        case num if 740 <= num < 800:
            creditScoreCategory = 'very good'
        case num if 670 <= num < 740:
            creditScoreCategory = 'good'
        case num if 580 <= num < 670:
            creditScoreCategory = 'fair'
        case num if 300 <= num < 580:
            creditScoreCategory = 'poor'
        case _:
            creditScoreCategory = 'impossible'

    print(f"Credit score category: {creditScoreCategory}")
    return creditScoreCategory

if __name__ == '__main__':
    print("Starting the Flask application")
    serve(app, port=8888)
