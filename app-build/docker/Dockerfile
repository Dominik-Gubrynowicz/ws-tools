FROM --platform=linux/amd64 python:3.12

RUN apt-get update -y && \
    apt-get install openssh-server nano -y

RUN mkdir /app && \
    mkdir /root/.aws && \
    mkdir /app/log && \
    mkdir -p /root/.ssh

COPY id_rsa.pub /root/.ssh/authorized_keys

RUN chmod 600 /root/.ssh/authorized_keys

WORKDIR /app

COPY app-build/src/aws_config /root/.aws/config
COPY app-build/src/app .

COPY app-build/src/start.sh /app/

RUN ln -sf /dev/stdout /app/log/log.log

ENTRYPOINT [ "" ]
CMD [ "./start.sh" ]