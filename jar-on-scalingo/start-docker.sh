#! /bin/bash

function source_environment() {
    echo -n "sourcing the buildpack injected files... "
    for aFile in $HOME/.profile.d/*
    do
        source $aFile
    done
    echo "done"
}

/wait-for-it.sh --host=app-redis --port=6379 -- echo "redis READY"
/wait-for-it.sh --host=app-postgresql --port=5432 -- echo "postgresql READY"
/wait-for-it.sh --host=app-influx --port=8086 -- echo "influx READY"

source_environment
# read the procfile to start the web line
./forego start web