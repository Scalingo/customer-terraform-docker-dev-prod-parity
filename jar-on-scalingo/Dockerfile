FROM scalingo/scalingo-18:latest
ENV HOME=/app
WORKDIR /app

## FETCH DEPENDENCIES
# download tool to wait for database readyness
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh
# download tool to read the Procfile
RUN curl -L https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz | tar -xzvf -
# download the JVM buildpack
RUN curl -L https://github.com/Scalingo/buildpack-jvm-common/archive/master.tar.gz | tar -C /tmp -xzvf -

## COPY CODE FILES
COPY . /app

## INSTALL DEPENDENCIES
# execute the buildpack installation commands and make java available
RUN /tmp/buildpack-jvm-common-master/bin/compile /app /tmp/cache

CMD /app/start-docker.sh