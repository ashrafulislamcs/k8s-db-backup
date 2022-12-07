FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends wget lsb-release hostname gnupg dirmngr

RUN set -eux; \
# gpg: key 3A79BD29: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
	key='859BE8D7C586F538430B19C2467B942D3A79BD29'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	mkdir -p /etc/apt/keyrings; \
	gpg --batch --export "$key" > /etc/apt/keyrings/mysql.gpg; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"

ENV MYSQL_MAJOR 8.0
ENV MYSQL_VERSION 8.0.30-1debian10

RUN echo 'deb [ signed-by=/etc/apt/keyrings/mysql.gpg ] http://repo.mysql.com/apt/debian/ buster mysql-8.0' > /etc/apt/sources.list.d/mysql.list

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN { \
		echo mysql-community-server mysql-community-server/data-dir select ''; \
		echo mysql-community-server mysql-community-server/root-pass password ''; \
		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
		echo mysql-community-server mysql-community-server/remove-test-db select false; \
	} | debconf-set-selections \
	&& apt-get update &&  DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get install -y mysql-client="${MYSQL_VERSION}"  mysql-community-client="${MYSQL_VERSION}"  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip && apt-get remove -y wget lsb-release gnupg dirmngr && apt autoremove -y && rm -rf /var/lib/apt/lists/*

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