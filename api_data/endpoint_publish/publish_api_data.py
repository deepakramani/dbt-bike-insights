from fastapi import FastAPI
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import json
import os


# --- 1. Define File Paths ---
PERSONA_DATA_FILE = "../cust_info_with_attributes.json"
TRACKING_DATA_FILE = "../sales_details_with_attributes.json"

# --- 2. Load Data on Startup (Consider reloading if files change frequently) ---
# Using global variables for simplicity in this local setup.
# In production, consider caching strategies or database access.
persona_data_cache = []
tracking_data_cache = []


def load_data():
    """Loads data from JSON files into global cache variables."""
    global persona_data_cache, tracking_data_cache

    # Load Persona Data
    if os.path.exists(PERSONA_DATA_FILE):
        try:
            with open(PERSONA_DATA_FILE, "r") as f:
                persona_data_cache = json.load(f)
            print(f"Loaded {len(persona_data_cache)} persona records.")
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON from {PERSONA_DATA_FILE}: {e}")
            persona_data_cache = []
        except Exception as e:
            print(f"Unexpected error loading {PERSONA_DATA_FILE}: {e}")
            persona_data_cache = []
    else:
        print(
            f"Warning: File {PERSONA_DATA_FILE} not found. /persona endpoint will return empty list."
        )
        persona_data_cache = []

    # Load Tracking Data
    if os.path.exists(TRACKING_DATA_FILE):
        try:
            with open(TRACKING_DATA_FILE, "r") as f:
                tracking_data_cache = json.load(f)
            print(f"Loaded {len(tracking_data_cache)} tracking records.")
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON from {TRACKING_DATA_FILE}: {e}")
            tracking_data_cache = []
        except Exception as e:
            print(f"Unexpected error loading {TRACKING_DATA_FILE}: {e}")
            tracking_data_cache = []
    else:
        print(
            f"Warning: File {TRACKING_DATA_FILE} not found. /tracking endpoint will return empty list."
        )
        tracking_data_cache = []


# --- 3. Load Data on App Startup ---
# This ensures data is loaded when the server starts
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager to load data when the app starts."""
    print("Loading data files...")
    load_data()
    print("Data loading complete.")
    yield


# --- 4. Initialize FastAPI App ---
app = FastAPI(
    title="Customer Data Enrichment API",
    description="This API provides access to enriched customer data.",
    version="1.0.0",
    lifespan=lifespan,
    # docs_url="/docs", # Uncomment if you want Swagger UI at /docs
    # redoc_url="/redoc" # Uncomment if you want ReDoc at /redoc
)

# --- 5. Define API Endpoints ---


@app.get("/")
async def root():
    """Root endpoint providing basic API information."""
    return {
        "message": "Welcome to the Customer Data Enrichment API",
        "endpoints": {
            "/persona": "GET - Retrieve all enriched customer persona data",
            "/tracking": "GET - Retrieve all enriched sales tracking data",
        },
        "docs": "/docs",  # Link to interactive API docs (Swagger UI)
        "redoc": "/redoc",  # Link to alternative API docs (ReDoc)
    }


@app.get(
    "/persona",
    summary="Get Customer Personas",
    description="Retrieves the list of all customers with their enriched persona attributes.",
)
async def get_persona_data():
    """
    Returns the list of enriched customer persona data.
    """
    # In a more complex app, you might add query parameters for filtering/pagination
    # e.g., @app.get("/persona/") async def get_persona_data(skip: int = 0, limit: int = 100):
    # return persona_data_cache[skip : skip + limit]

    # For now, return all data
    # FastAPI automatically serializes Python objects (like lists/dicts) to JSON
    return JSONResponse(content=persona_data_cache)


@app.get(
    "/tracking",
    summary="Get Sales Tracking Info",
    description="Retrieves the list of all sales records with their enriched tracking attributes.",
)
async def get_tracking_data():
    """
    Returns the list of enriched sales tracking data.
    """
    # Similar to /persona, could add filtering/pagination later
    return JSONResponse(content=tracking_data_cache)


# --- 6. Optional: Add Health Check Endpoint (Zalando-like practice) ---
@app.get(
    "/health",
    summary="Health Check",
    description="Checks if the API is running and dependencies are healthy.",
)
async def health_check():
    """
    Performs a basic health check.
    Returns 200 OK if the API is running.
    Could be extended to check file accessibility, database connections, etc.
    """
    # Basic check: if the app started, it's healthy enough for this simple case
    # You could add checks for file existence, data loading success, etc.
    health_status = {
        "status": "UP",
        "details": {
            "data_files": {
                "persona_file_loaded": len(persona_data_cache) > 0,
                "tracking_file_loaded": len(tracking_data_cache) > 0,
                "persona_file_path": PERSONA_DATA_FILE,
                "tracking_file_path": TRACKING_DATA_FILE,
            }
        },
    }
    return JSONResponse(content=health_status)
