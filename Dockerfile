FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends hostname default-mysql-client python3 python3-pip \
&& apt autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN groupadd -g 1000 mybck
RUN useradd -d /app/ -s /bin/bash -g mybck -u 1000 mybck && chown -R mybck:mybck /app/
RUN mkdir /backup && chown -R mybck:mybck /backup

COPY ./k8s-db-backup /usr/local/bin/k8s-db-backup

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

USER mybck

COPY ./requirements.txt ./
RUN pip3 install --user --no-cache-dir -r requirements.txt\
    && rm -rf ./requirements.txt

CMD ["k8s-db-backup"]