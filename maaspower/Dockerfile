FROM docker.io/library/python:3-alpine

WORKDIR /app
ADD requirements.txt /app/requirements.txt
RUN python -m venv /app \
    && python -m ensurepip \
    && source /app/bin/activate \
    && pip install -r /app/requirements.txt

ENTRYPOINT ["/app/bin/maaspower"]
CMD ["--version"]
