from fastapi import FastAPI, Depends, Header, HTTPException, Request
from fastapi.responses import JSONResponse
from typing import Optional, List
from pydantic import BaseModel, field_validator
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
import json
import os
import logging
from pathlib import Path

app = FastAPI(title="Attribute Broadcast API")
data_path = Path(__file__).resolve().parent

API_KEY = os.getenv("API_KEY")

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_middleware(SlowAPIMiddleware)


@app.exception_handler(RateLimitExceeded)
async def rate_limit_exceeded_handler(request, exc):
    return JSONResponse(
        status_code=429,
        content={"detail": "Rate limit exceeded. Please try again later."},
    )


def verify_api_key(api_key: Optional[str] = Header(None, alias="x-api-key")):
    if not api_key or api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key. Unauthorised")
    return True


class CustomerAttributes(BaseModel):
    cst_id: Optional[int]
    personality: Optional[str]
    average_income: Optional[float]
    credit_score: Optional[int]
    urban_rural: Optional[str]

    @field_validator("cst_id", "credit_score", "average_income", mode="before")
    def empty_str_to_none(cls, v):
        return None if v == "" else v

    class Config:
        extra = "allow"


class SalesTrackingAttributes(BaseModel):
    sls_ord_num: Optional[str]
    sls_quantity: Optional[int]
    tracking_id: Optional[str]
    carrier: Optional[str]
    shipping_fee: Optional[float]

    @field_validator("sls_quantity", "shipping_fee", mode="before")
    @classmethod
    def empty_str_to_none(cls, v):
        return None if v == "" else v

    class Config:
        extra = "allow"


def load_and_validate(file_path: Path, model):
    with open(file_path) as f:
        data = json.load(f)

    validated_data = []
    for row in data:
        try:
            validated_data.append(model(**row).dict())
        except Exception as e:
            logging.warning(f"Schema warning for row: {row} | Error: {e}")
            validated_data.append(row)  # Ingest raw anyway
    return validated_data


@app.get(
    "/raw_api_persona",
    response_model=List[CustomerAttributes],
    dependencies=[Depends(verify_api_key)],
)
@limiter.limit("5/minute")
def get_customers(request: Request):
    return load_and_validate(
        data_path / "cust_info_with_attributes.json", CustomerAttributes
    )


@app.get(
    "/raw_api_sales_tracking",
    response_model=List[SalesTrackingAttributes],
    dependencies=[Depends(verify_api_key)],
)
@limiter.limit("5/minute")
def get_sales(request: Request):
    return load_and_validate(
        data_path / "sales_details_with_attributes.json", SalesTrackingAttributes
    )
