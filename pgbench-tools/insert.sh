#!/bin/bash


#echo "\COPY pgbench_accounts FROM '/home/sachin/100000.csv' WITH DELIMITER ',' CSV HEADER;" | psql -d pgbench -h 1xxx.xxx.xxx.xxx -p 5434


count1=1
count2=100000001
#time psql -d pgbench -p 5434 -c "COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=$count1 AND aid<$count2) TO STDOUT" | psql -d pgbench -h 1xxx.xxx.xxx.xxx -p 5434 -c "COPY pgbench_accounts FROM STDIN"

time psql -d pgbench -h xxx.xxx.xxx.xxx -p 5434 -c "\COPY pgbench_accounts FROM '/home/sachin/100000000.csv' WITH DELIMITER ',' CSV HEADER;"
time psql -d pgbench -h xxx.xxx.xxx.xxx -p 5434 -c "delete from pgbench_accounts where aid >=$count1 AND aid<$count2;"
#sleep 5
#sh v5_fdw_inheritance.sh
#sleep 10

