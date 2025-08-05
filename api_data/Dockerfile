FROM python:3.11-slim

WORKDIR /app

RUN pip install -U pip
RUN pip install pipenv

COPY [ "Pipfile", "Pipfile.lock", "./" ]

RUN pipenv install --system --deploy


COPY [ "./endpoint_publish/publish_api_data.py", "./" ]

EXPOSE 8000

CMD ["uvicorn", "publish_api_data:app", "--host", "0.0.0.0", "--port", "8000"]

