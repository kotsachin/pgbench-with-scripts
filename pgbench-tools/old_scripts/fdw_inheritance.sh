#!/bin/bash

scale=2
runtime=1800
dtime=$((runtime+10))
count1=1
count2=10000001
port=5434
ip_driver=xxx.xxx.xxx.xxx
ip_parent=xxx.xxx.xxx.xxx
pg_user=sachin

#-------------------------
scp postgresql.conf $pg_user@$ip_parent:/home/sachin/postgres_data/postgresql.conf 1>/dev/null 2>>error.log
scp pg_hba.conf $pg_user@$ip_parent:/home/sachin/postgres_data/pg_hba.conf 1>/dev/null 2>>error.log
sleep 5
ssh $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>error.log
sleep 5

/home/sachin/postgres_install/bin/dropdb -p $port -h $ip_parent -U $pg_user pgbench
/home/sachin/postgres_install/bin/createdb -p $port -h $ip_parent -U $pg_user pgbench
/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/init_tables.sql
#/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -c "vacuum full;"

#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_accounts;"
#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_history;"
#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_tellers;"
#/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "DELETE  FROM pgbench_branches;"

#-------------------------
scale_temp=$scale
c=1
exec<ip_list.conf
while read ip_child[$c]
do
        echo ${ip_child[$c]}
        scale_temp=$((scale_temp-1))
        c=$((c+1))
        if [ $scale_temp -le 0 ]
        then
                break
        fi
done
#-------------------------

for (( c=1; c<=$scale; c++ ))
do
        scp postgresql.conf $pg_user@${ip_child[$c]}:/home/sachin/postgres_data/postgresql.conf 1>/dev/null 2>>error.log
        scp pg_hba.conf $pg_user@${ip_child[$c]}:/home/sachin/postgres_data/pg_hba.conf 1>/dev/null 2>>error.log
	sleep 5
        ssh -n ${ip_child[$c]}  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>>error.log
        sleep 5

       /home/sachin/postgres_install/bin/dropdb -h ${ip_child[$c]} -p $port pgbench
       /home/sachin/postgres_install/bin/createdb -h ${ip_child[$c]} -p $port pgbench
       /home/sachin/postgres_install/bin/psql -d pgbench -h ${ip_child[$c]} -p $port -c "CREATE TABLE pgbench_accounts_$c(aid  bigint, bid  integer, abalance integer , filler character(84), check (aid >= '$count1' AND aid < '$count2') );"
       
       count1=$((count1+10000000))
       count2=$((count2+10000000))
done

#-------------------------
/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE EXTENSION postgres_fdw;"


for (( c=1; c<=$scale; c++ ))
do
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE SERVER server_$c FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${ip_child[$c]}', port '$port', dbname 'pgbench');"
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE USER MAPPING FOR PUBLIC SERVER server_$c OPTIONS (password '');"
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE FOREIGN TABLE pgbench_accounts_f_$c (aid  bigint, bid  integer, abalance integer , filler character(84)) INHERITS (pgbench_accounts) SERVER server_$c OPTIONS (table_name 'pgbench_accounts_$c');"

done

#-------------------------
case "$scale" in

2)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/triggers/trigger2.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user < /home/sachin/pgbench-tools/pgbench_scale-200.dump
    ;;
5)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/triggers/trigger5.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user < /home/sachin/pgbench-tools/pgbench_scale-500.dump
    ;;
8) /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/triggers/trigger10.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user < /home/sachin/pgbench-tools/pgbench_scale-1000.dump
    ;;
*) echo "Scale is not correct"
   ;;
esac

/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/alter_tables.sql
#-------------------------

#cp /home/sachin/pgbench-tools/config /home/sachin/pgbench-tools/config_temp

#CONFIG=/home/sachin/pgbench-tools/config_temp
#echo "SCALES=$scale" >> $CONFIG
#echo "# Test/result database connection" >> $CONFIG
#echo "TESTHOST=$ip_parent" >> $CONFIG
#echo "TESTUSER=$pg_user" >> $CONFIG
#echo "TESTPORT=$port" >> $CONFIG
#echo "TESTDB=pgbench" >> $CONFIG
#echo "RUNTIME=$runtime" >> $CONFIG
#-------------------------
#ssh $ip_parent "rm -f parent_dstat.csv" 2>> error.log

#for (( c=1; c<=$scale; c++ ))
#do
#        ssh -n ${ip_child[$c]}  "rm -f child_dstat_$c.csv" 2>>error.log
        
#done
#-------------------------

#ssh $ip_parent "dstat -tvfn --output parent_dstat.csv 1 $dtime" 1> /dev/null &
#dstat -tvfn --output driver_dstat.csv 1 $dtime 1> /dev/null &
#for (( c=1; c<=$scale; c++ ))
#do
#        ssh -n ${ip_child[$c]}  "dstat -tvfn --output child_dstat_$c.csv 1 $dtime" 1> /dev/null &
        
#done
#-------------------------
#. ./runset


#RESULTPSQL="psql -d results -p $port -h $ip_driver -U $pg_user"
#TEST=`$RESULTPSQL -A -t -c "select max(test) from tests"`

#echo "Test: $TEST"

#-------------------------
#mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/parent
#mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/driver
#ssh $ip_parent "scp parent_dstat.csv $pg_user@$ip_driver:/home/sachin/pgbench-tools/results/$TEST/report/parent/ " 2>> error.log
#mv driver_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/driver

#for (( c=1; c<=$scale; c++ ))
#do
#	mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/child$c
#        ssh -n ${ip_child[$c]}  "scp child_dstat_$c.csv $pg_user@$ip_driver:/home/sachin/pgbench-tools/results/$TEST/report/child$c/" 2>> error.log
#done


#/home/sachin/pgbench-tools/dstat2graphs/dstat2graphs.pl /home/sachin/pgbench-tools/results/$TEST/report/remote/r_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/remote/ 512 192 0 0 0 0

#/home/sachin/pgbench-tools/dstat2graphs/dstat2graphs.pl /home/sachin/pgbench-tools/results/$TEST/report/local/l_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/local/ 512 192 0 0 0 0


#cp -rf results /var/www/html/
#mv /home/sachin/pgbench-tools/config_temp /home/sachin/pgbench-tools/results/

#/home/sachin/postgres_install/bin/pg_basebackup -x -h localhost -p 5434 -D /home/sachin/backup

#cp -r backup/ postgres_data1

