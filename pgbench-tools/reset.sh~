#!/bin/bash


/home/sachin/postgres_install/bin/dropdb -p 5434 -h xxx.xxx.xxx.xxx -U sachin results
/home/sachin/postgres_install/bin/createdb -p 5434 -h xxx.xxx.xxx.xxx -U sachin results
psql -f init/resultdb.sql -p 5434 -d results
./newset 'Initial Config'
