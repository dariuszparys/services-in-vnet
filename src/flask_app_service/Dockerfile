FROM python:3.8

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV FLASK_APP=app.py
ENV FLASK_DEBUG=0
ENV FLASK_ENV=production

COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY . /app

EXPOSE 5000

CMD [ "gunicorn", "app:app", "--bind", "0.0.0.0:5000", "--timeout", "240" ]
