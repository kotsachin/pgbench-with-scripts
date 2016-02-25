#!/bin/bash
	
	scale=7
	runtime=1800
	dtime=$((runtime+10))
	port=5434
	ip_driver=xxx.xxx.xxx.xxx
	ip_parent=xxx.xxx.xxx.xxx
	pg_user=sachin
	pg_scale=7000

	ssh -n $ip_parent "rm -rf /home/sachin/postgres_data/*" 2>>error.log
	ssh -n $ip_parent "/home/sachin/postgres_install/bin/initdb -D /home/sachin/postgres_data/ 1>/dev/null" 2>error.log
	sleep 10
	scp postgresql.conf $pg_user@$ip_parent:/home/sachin/postgres_data/postgresql.conf 1>/dev/null 2>>error.log
	scp pg_hba.conf $pg_user@$ip_parent:/home/sachin/postgres_data/pg_hba.conf 1>/dev/null 2>>error.log
	ssh -n $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>error.log
	sleep 10

	#/home/sachin/postgres_install/bin/dropdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/createdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/init_tables.sql

#-------------------------
	cnt=$((pg_scale*100000))
        cnt=$((cnt/scale))
        count1=1
        count2=$((cnt+1))

        for (( c=1; c<=$scale; c++ ))
        do
               
		/home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "CREATE TABLE pgbench_accounts_$c( primary key (aid), check (aid >= '$count1' AND aid < '$count2') ) INHERITS (pgbench_accounts);"
		/home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "CREATE INDEX pgbench_index_$c ON pgbench_accounts_$c(aid);"


		psql -d pgbench -p 5434 -c "COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=$count1 AND aid<$count2) TO STDOUT" | psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_accounts_$c FROM STDIN"
		
		count1=$count2
                count2=$((count2+cnt))

        done

#-------------------------


        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger.sql

        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	psql -d pgbench -p 5434 -c "COPY (SELECT bid, bbalance, filler from pgbench_branches WHERE bid >=1 AND bid<=$pg_scale) TO STDOUT" | psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN"

	tg_scale=$((pg_scale*10))

	psql -d pgbench -p 5434 -c "COPY (SELECT tid, bid, tbalance, filler from pgbench_tellers WHERE tid >=1 AND tid<=$tg_scale) TO STDOUT" | psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN"


/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/alter_tables.sql
#-------------------------

cp /home/sachin/pgbench-tools/config /home/sachin/pgbench-tools/config_temp

CONFIG=/home/sachin/pgbench-tools/config_temp
echo "SCALES=\"$pg_scale\" " >> $CONFIG
echo "# Test/result database connection" >> $CONFIG
echo "TESTHOST=$ip_parent" >> $CONFIG
echo "TESTUSER=$pg_user" >> $CONFIG
echo "TESTPORT=$port" >> $CONFIG
echo "TESTDB=pgbench" >> $CONFIG
echo "RUNTIME=$runtime" >> $CONFIG
#-------------------------
ssh -n $ip_parent "rm -f parent_dstat.csv" 2>> error.log
#-------------------------

ssh -n $ip_parent "dstat -tvfn --output parent_dstat.csv 1 $dtime" 1> /dev/null &
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
ssh -n $ip_parent "scp parent_dstat.csv $pg_user@$ip_driver:/home/sachin/pgbench-tools/results/$TEST/report/parent/ " 2>> error.log

#------------------
echo "----------Database size---------" >> /home/sachin/pgbench-tools/results/$TEST/results.txt
db_size=`psql -d 'pgbench' -p "$port" -h "$ip_parent" -c "select pg_size_pretty(pg_database_size('pgbench'))  as Database_size"`
echo "Parent $db_size" >> /home/sachin/pgbench-tools/results/$TEST/results.txt
echo "----------Sharding with increase in Data Size---------" >> /home/sachin/pgbench-tools/results/$TEST/results.txt
#------------------

mv driver_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/driver


mv /home/sachin/pgbench-tools/config_temp /home/sachin/pgbench-tools/results/$TEST/

ssh -n $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -mi 1>/dev/null" 2>error.log
        sleep 20


