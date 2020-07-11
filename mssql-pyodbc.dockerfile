FROM mcr.microsoft.com/mssql/server:2017-CU20-ubuntu-16.04

RUN apt-get update && \
    apt-get install -y software-properties-common build-essential unixodbc-dev

RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update && \
    apt-get install -y python3.8 python3.8-dev python3.8-venv

WORKDIR /work
RUN python3.8 -m venv venv && venv/bin/pip install pyodbc
