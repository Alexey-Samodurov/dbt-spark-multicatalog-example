FROM apache/spark-py:latest

USER root

COPY ../requirements.txt requirements.txt

RUN pip3 install -qr requirements.txt

WORKDIR /workspace
