#!/bin/bash

	#scale=2
	#ssh $ip_parent "rm -rf /home/sachin/postgres_data/*" 2>>error.log
	#ssh $ip_parent "cp -r /home/sachin/backup/* /home/sachin/postgres_data/" 2>>error.log
#-------------------------

for (( scale=5; scale<=10; scale++ ))
do

	runtime=1800
	dtime=$((runtime+10))
	port=5434
	ip_driver=xxx.xxx.xxx.xxx
	ip_parent=xxx.xxx.xxx.xxx
	pg_user=sachin
	count1=1
	count2=20000001
	pg_scale=$((scale*200))

	ssh -n $ip_parent "rm -rf /home/sachin/postgres_data/*" 2>>error.log
	ssh -n $ip_parent "/home/sachin/postgres_install/bin/initdb -D /home/sachin/postgres_data/ 1>/dev/null" 2>error.log
	sleep 10
	scp postgresql.conf $pg_user@$ip_parent:/home/sachin/postgres_data/postgresql.conf 1>/dev/null 2>>error.log
	scp pg_hba.conf $pg_user@$ip_parent:/home/sachin/postgres_data/pg_hba.conf 1>/dev/null 2>>error.log
	ssh -n $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>error.log
	sleep 10
#	ssh -n $ip_driver "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>error.log
#	sleep 10

	/home/sachin/postgres_install/bin/dropdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/createdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/init_tables.sql

#-------------------------

        for (( c=1; c<=$scale; c++ ))
        do
               
		/home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "CREATE TABLE pgbench_accounts_$c( primary key (aid), check (aid >= '$count1' AND aid < '$count2') ) INHERITS (pgbench_accounts);"
		/home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "CREATE INDEX pgbench_index_$c ON pgbench_accounts_$c(aid);"

                cat /home/sachin/200_scale_csv_files/child$c.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_accounts_$c(aid, bid, abalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

                count1=$((count1+20000000))
                count2=$((count2+20000000))
        done

#-------------------------

case "$scale" in

        1)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger1.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        2)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger2.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        3)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger3.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        4)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger4.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        5)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger5.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        6)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger6.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        7)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger7.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        8)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger8.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        9)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger9.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        10)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/new_triggers/trigger10.sql
        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        *) echo "Scale is not correct"
        ;;
esac


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

#for (( c=1; c<=$scale; c++ ))
#do
#        ssh -n ${ip_child[$c]}  "rm -f child_dstat_$c.csv" 2>>error.log
        
#done
#-------------------------

ssh -n $ip_parent "dstat -tvfn --output parent_dstat.csv 1 $dtime" 1> /dev/null &
dstat -tvfn --output driver_dstat.csv 1 $dtime 1> /dev/null &
#for (( c=1; c<=$scale; c++ ))
#do
#        ssh -n ${ip_child[$c]}  "dstat -tvfn --output child_dstat_$c.csv 1 $dtime" 1> /dev/null &
        
#done
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
mv driver_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/driver

#for (( c=1; c<=$scale; c++ ))
#do
#	mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/child$c
#        ssh -n ${ip_child[$c]}  "scp child_dstat_$c.csv $pg_user@$ip_driver:/home/sachin/pgbench-tools/results/$TEST/report/child$c/" 2>> error.log
#done


mv /home/sachin/pgbench-tools/config_temp /home/sachin/pgbench-tools/results/$TEST/

#/home/sachin/postgres_install/bin/pg_basebackup -x -h localhost -p 5434 -D /home/sachin/backup
#cp -r backup/ postgres_data1



ssh -n $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -mi 1>/dev/null" 2>error.log
        sleep 20


done
