#!/bin/bash

scale=5
runtime=1800
dtime=$((runtime+10))
count1=1
count2=10000001
port=5434
ip_driver=xxx.xxx.xxx.xxx
ip_parent=xxx.xxx.xxx.xxx
pg_user=sachin

#-------------------------

#ssh $ip_parent "rm -rf /home/sachin/postgres_data/*" 2>>error.log
#ssh $ip_parent "cp -r /home/sachin/backup/* /home/sachin/postgres_data/" 2>>error.log
scp postgresql.conf $pg_user@$ip_parent:/home/sachin/postgres_data/postgresql.conf 1>/dev/null 2>>error.log
scp pg_hba.conf $pg_user@$ip_parent:/home/sachin/postgres_data/pg_hba.conf 1>/dev/null 2>>error.log
sleep 5
ssh $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>error.log
sleep 5

/home/sachin/postgres_install/bin/dropdb -p $port -h $ip_parent -U $pg_user pgbench
/home/sachin/postgres_install/bin/createdb -p $port -h $ip_parent -U $pg_user pgbench
#/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/init_tables.sql


/home/sachin/postgres_install/bin/pgbench -p $port -h $ip_parent -U $pg_user -i -s 500 -d pgbench

#/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -c "vacuum full;"

#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_accounts;"
#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_history;"
#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_tellers;"
#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_branches;"

#-------------------------

cp /home/sachin/pgbench-tools/config /home/sachin/pgbench-tools/config_temp

CONFIG=/home/sachin/pgbench-tools/config_temp
echo "SCALES=\"$scale\" " >> $CONFIG
echo "# Test/result database connection" >> $CONFIG
echo "TESTHOST=$ip_parent" >> $CONFIG
echo "TESTUSER=$pg_user" >> $CONFIG
echo "TESTPORT=$port" >> $CONFIG
echo "TESTDB=pgbench" >> $CONFIG
echo "RUNTIME=$runtime" >> $CONFIG
#-------------------------
ssh $ip_parent "rm -f parent_dstat.csv" 2>> error.log

#-------------------------

ssh $ip_parent "dstat -tvfn --output parent_dstat.csv 1 $dtime" 1> /dev/null &
dstat -tvfn --output driver_dstat.csv 1 $dtime 1> /dev/null &
#-------------------------
sleep 10
. ./runset


RESULTPSQL="psql -d results -p $port -h $ip_driver -U $pg_user"
TEST=`$RESULTPSQL -A -t -c "select max(test) from tests"`

echo "Test: $TEST"

#-------------------------
mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/parent
mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/driver
ssh $ip_parent "scp parent_dstat.csv $pg_user@$ip_driver:/home/sachin/pgbench-tools/results/$TEST/report/parent/ " 2>> error.log
mv driver_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/driver


mv /home/sachin/pgbench-tools/config_temp /home/sachin/pgbench-tools/results/$TEST/

#/home/sachin/postgres_install/bin/pg_basebackup -x -h localhost -p 5434 -D /home/sachin/backup
#cp -r backup/ postgres_data1

ssh -n xxx.xxx.xxx.xxx  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop 1>/dev/null" 2>error.log


