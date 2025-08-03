import os
import sys
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "endpoint_publish"))
from publish_api_data import app

API_KEY = os.getenv("API_KEY")
client = TestClient(app)


def test_customers_endpoint_valid_key():
    response = client.get("/raw_api_persona", headers={"x-api-key": API_KEY})
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_customers_endpoint_invalid_key():
    response = client.get("/raw_api_persona", headers={"x-api-key": "wrong"})
    assert response.status_code == 401


def test_sales_endpoint_valid_key():
    response = client.get("/raw_api_sales_tracking", headers={"x-api-key": API_KEY})
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_sales_endpoint_invalid_key():
    response = client.get("/raw_api_sales_tracking", headers={"x-api-key": "wrong"})
    assert response.status_code == 401


def test_customers_endpoint_rate_limit():
    for _ in range(6):  # Exceed the limit of 5 requests/minute
        response = client.get("/raw_api_persona", headers={"x-api-key": API_KEY})
    assert response.status_code == 429  # Expect rate limit exceeded


def test_sales_endpoint_rate_limit():
    for _ in range(6):
        response = client.get("/raw_api_sales_tracking", headers={"x-api-key": API_KEY})
    assert response.status_code == 429
