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
# install pgtap, pg_prove and tap-harness-junit and its dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends git gcc make curl unzip patch perl ca-certificates libexpat1-dev libwww-perl \
    && curl -Lo pgtap.zip https://api.pgxn.org/dist/pgtap/0.99.0/pgtap-0.99.0.zip \
    && unzip pgtap.zip \
    && apt-get install -y postgresql-server-dev-9.5 postgresql-common \
    && cd pgtap-0.99.0 && make && make install && cpan TAP::Parser::SourceHandler::pgTAP \
    && cd ../ && git clone --branch 1.128 --depth 1 https://github.com/rjbs/Test-Deep.git \
    && git clone --branch v0.42 --depth 1 https://github.com/clarifyhealth/tap-harness-junit.git \
    && cpan Test::Tester XML::Parser XML::Simple \
    && cd Test-Deep && perl Makefile.PL && make && make test && make install \
    && cd ../tap-harness-junit && perl Build.PL && ./Build && ./Build install \
    && cd ../ && echo 'CREATE EXTENSION IF NOT EXISTS pgtap;' > create_extension_pgtap.sql \
    && mv create_extension_pgtap.sql /docker-entrypoint-initdb.d \
    && rm -rf /var/lib/apt/lists/* Test-Deep tap-harness-junit pgtap.zip pgtap-0.99.0 \
    && apt-get purge -y --auto-remove git gcc make curl unzip patch ca-certificates
