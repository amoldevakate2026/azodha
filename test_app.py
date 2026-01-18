import pytest
from app import app


@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_health_endpoint(client):
    """Test the /health endpoint."""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    assert data['service'] == 'azodha-api'
    assert data['version'] == '1.0.0'


def test_predict_endpoint(client):
    """Test the /predict endpoint."""
    response = client.get('/predict')
    assert response.status_code == 200
    data = response.get_json()
    assert 'score' in data
    assert data['score'] == 0.75


def test_health_endpoint_structure(client):
    """Test that /health returns the correct structure."""
    response = client.get('/health')
    data = response.get_json()
    assert isinstance(data, dict)
    assert 'status' in data
    assert 'service' in data
    assert 'version' in data


def test_predict_endpoint_structure(client):
    """Test that /predict returns the correct structure."""
    response = client.get('/predict')
    data = response.get_json()
    assert isinstance(data, dict)
    assert 'score' in data
    assert isinstance(data['score'], float)
