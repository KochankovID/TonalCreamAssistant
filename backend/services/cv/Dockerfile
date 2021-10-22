FROM python:3.9

RUN apt-get update ##[edited]
RUN apt-get install ffmpeg libsm6 libxext6  -y

RUN pip install poetry==1.1.11

WORKDIR /cv
COPY ./pyproject.toml /cv/

RUN poetry config virtualenvs.create false
RUN poetry install --no-interaction

COPY . .

CMD ["bash", "./scripts/flask-entrypoint.sh"]