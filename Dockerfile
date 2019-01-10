FROM postgres:9.5

MAINTAINER Cayle Sharrock<cayle@nimbustech.biz>

# Override this in your docker run command to customize
ADD ./ssl.conf /etc/postgresql-common/ssl.conf
# Add the ssl config setup script
COPY pg_hba.conf /usr/share/postgresql/9.5/pg_hba.conf.sample
COPY postgresql.conf /usr/share/postgresql/9.5/postgresql.conf.sample
COPY server.crt server.key /var/ssl/
RUN chown postgres.postgres /usr/share/postgresql/9.5/pg_hba.conf.sample \
                            /usr/share/postgresql/9.5/postgresql.conf.sample \
                            /var/ssl/server.key \
                            /var/ssl/server.crt && \
    chmod 600 /var/ssl/server.key
# install pgtap and its dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends git gcc make curl unzip patch ca-certificates \
    && curl -Lo pgtap.zip https://api.pgxn.org/dist/pgtap/0.99.0/pgtap-0.99.0.zip \
    && unzip pgtap.zip \
    && apt-get install -y postgresql-server-dev-9.5 postgresql-common \
    && cd pgtap-0.99.0 && make && make install \
    && cd ../ && rm -rf /var/lib/apt/lists/* pgtap.zip pgtap-0.99.0 \
    && apt-get purge -y --auto-remove git gcc make curl unzip patch ca-certificates
