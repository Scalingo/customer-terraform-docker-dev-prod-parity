#! /bin/bash -uex

ENV=${TF_VAR_environment:-dev}
PREFIX=demo-${ENV}
REGION=osc-fr1
SCALINGO_OPTS="--region $REGION"
COMPONENT_NB=3
PACKAGE_PATH=../jar-on-scalingo.tar.gz

postgres_url=$(scalingo env $SCALINGO_OPTS --app $PREFIX-component-0 | rg --pcre2 -o '(?<=SCALINGO_POSTGRESQL_URL=).+$')
influx_url=$(scalingo env $SCALINGO_OPTS --app $PREFIX-component-0 | rg --pcre2 -o '(?<=SCALINGO_INFLUX_URL=).+$')

for i in $(seq 0 $(($COMPONENT_NB - 1)))
do
    appname=$PREFIX-component-$i
    scalingo env-set $SCALINGO_OPTS --app $appname "DATABASE_URL=$postgres_url" "INFLUX_URL=$influx_url"
    scalingo deploy $SCALINGO_OPTS --app $appname $PACKAGE_PATH
done
scalingo deploy $SCALINGO_OPTS --app $PREFIX-grafana https://github.com/Scalingo/grafana-scalingo/archive/master.tar.gz
scalingo deploy $SCALINGO_OPTS --app $PREFIX-metabase https://github.com/Scalingo/metabase-scalingo/archive/master.tar.gz
