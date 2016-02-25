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
#		sleep 10

	/home/sachin/postgres_install/bin/dropdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/createdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/init_tables.sql

	echo "$pg_scale"

#/home/sachin/postgres_install/bin/pgbench -p $port -h $ip_parent -U $pg_user -i -s $pg_scale -d pgbench

#-------------------------

        for (( c=1; c<=$scale; c++ ))
        do
		/home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "CREATE INDEX pgbench_index ON pgbench_accounts(aid);"
                cat /home/sachin/200_scale_csv_files/child$c.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_accounts(aid, bid, abalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

                count1=$((count1+20000000))
                count2=$((count2+20000000))
        done
#--------------------
case "$scale" in

        1)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        2)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        3)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        4)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        5)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        6)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        7)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        8)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        9)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        10)  cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

        cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
        ;;

        *) echo "Scale is not correct"
        ;;
esac

/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/alter_tables.sql
#----------------------
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
mv driver_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/driver


mv /home/sachin/pgbench-tools/config_temp /home/sachin/pgbench-tools/results/$TEST/

#/home/sachin/postgres_install/bin/pg_basebackup -x -h localhost -p 5434 -D /home/sachin/backup
#cp -r backup/ postgres_data1


ssh -n $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -mi 1>/dev/null" 2>error.log
        sleep 20

done
