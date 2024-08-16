FROM --platform=linux/amd64 python:3.12

RUN mkdir /app && \
    mkdir /root/.aws && \
    mkdir /app/log
    
WORKDIR /app

COPY aws_config /root/.aws/config
COPY . .

CMD [ "server-root" ]