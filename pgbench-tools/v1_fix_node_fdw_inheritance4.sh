#!/bin/bash

	#scale=2
	#ssh $ip_parent "rm -rf /home/sachin/postgres_data/*" 2>>error.log
	#ssh $ip_parent "cp -r /home/sachin/backup/* /home/sachin/postgres_data/" 2>>error.log

#-------------------------


for (( scale=1; scale<=4; scale++ ))
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

	#/home/sachin/postgres_install/bin/dropdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/createdb -p $port -h $ip_parent -U $pg_user pgbench
	/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/init_tables.sql

#-------------------------
	#scale_temp=$scale
	scale_temp=4
	c=1
	unset ip_child
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

	cnt=$((pg_scale*100000))
	cnt=$((cnt/4))
        count1=1
        count2=$((cnt+1))
	echo $count1
	echo $count2
	
	for (( c=1; c<=4; c++ ))
	do
	#	ssh -n ${ip_child[$c]}  "rm -rf /home/sachin/postgres_data/*" 2>>error.log
	#	ssh -n ${ip_child[$c]}  "cp -r /home/sachin/backup/* /home/sachin/postgres_data/" 2>>error.log
		
		
		echo $count1
		echo $count2
		ssh -n ${ip_child[$c]} "rm -rf /home/sachin/postgres_data/*" 2>>error.log
	        ssh -n ${ip_child[$c]} "/home/sachin/postgres_install/bin/initdb -D /home/sachin/postgres_data/ 1>/dev/null" 2>error.log
        	sleep 10
	        scp postgresql.conf $pg_user@${ip_child[$c]}:/home/sachin/postgres_data/postgresql.conf 1>/dev/null 2>>error.log
		scp pg_hba.conf $pg_user@${ip_child[$c]}:/home/sachin/postgres_data/pg_hba.conf 1>/dev/null 2>>error.log
		
	        ssh -n ${ip_child[$c]}  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>>error.log
	        sleep 10

	       #/home/sachin/postgres_install/bin/dropdb -h ${ip_child[$c]} -p $port pgbench
	       /home/sachin/postgres_install/bin/createdb -h ${ip_child[$c]} -p $port pgbench
	       /home/sachin/postgres_install/bin/psql -d pgbench -h ${ip_child[$c]} -p $port -c "CREATE TABLE pgbench_accounts_$c(aid  bigint, bid  integer, abalance integer , filler character(84), check (aid >= '$count1' AND aid < '$count2') );"
	       /home/sachin/postgres_install/bin/psql -d pgbench -h ${ip_child[$c]} -p $port -c "CREATE INDEX pgbench_index_$c ON pgbench_accounts_$c(aid);"

		if [ $scale -eq 1 ]
                then
			cat /home/sachin/fix_scale_fdw/child1$c.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h ${ip_child[$c]} -p $port -c "COPY pgbench_accounts_$c(aid, bid, abalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
                fi
		if [ $scale -eq 2 ]
                then
			cat /home/sachin/fix_scale_fdw/child2$c.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h ${ip_child[$c]} -p $port -c "COPY pgbench_accounts_$c(aid, bid, abalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
                fi
		if [ $scale -eq 3 ]
                then
			cat /home/sachin/fix_scale_fdw/child3$c.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h ${ip_child[$c]} -p $port -c "COPY pgbench_accounts_$c(aid, bid, abalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
                fi
		if [ $scale -eq 4 ]
                then
			cat /home/sachin/fix_scale_fdw/child4$c.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h ${ip_child[$c]} -p $port -c "COPY pgbench_accounts_$c(aid, bid, abalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
                fi

		#count1=$((count1+20000000))
		#count2=$((count2+20000000))
		count1=$((count1+cnt))
		count2=$((count2+cnt))
	done

#-------------------------
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE EXTENSION postgres_fdw;"

	for (( c=1; c<=4; c++ ))
	do
		/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE SERVER server_$c FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${ip_child[$c]}', port '$port', dbname 'pgbench');"
		/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE USER MAPPING FOR PUBLIC SERVER server_$c OPTIONS (password '');"
		/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE FOREIGN TABLE pgbench_accounts_f_$c (aid  bigint, bid  integer, abalance integer , filler character(84)) INHERITS (pgbench_accounts) SERVER server_$c OPTIONS (table_name 'pgbench_accounts_$c');"

	done

#-------------------------
	
case "$scale" in
#case "4" in

	1)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger41.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	2)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger42.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	3)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger43.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	4)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger44.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	5)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger101.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	6)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger102.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	7)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger103.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	8)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger104.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	9)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger105.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	cat /home/sachin/200_scale_csv_files/branch_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "

	cat /home/sachin/200_scale_csv_files/teller_$scale.csv | /home/sachin/postgres_install/bin/psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN WITH DELIMITER ',' CSV HEADER "
	;;

	10)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/const_triggers/trigger106.sql
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

	for (( c=1; c<=4; c++ ))
	do
        	ssh -n ${ip_child[$c]}  "rm -f child_dstat_$c.csv" 2>>error.log
        
	done
#-------------------------

	ssh -n $ip_parent "dstat -tvfn --output parent_dstat.csv 1 $dtime" 1> /dev/null &
	dstat -tvfn --output driver_dstat.csv 1 $dtime 1> /dev/null &
	for (( c=1; c<=4; c++ ))
	do
        	ssh -n ${ip_child[$c]}  "dstat -tvfn --output child_dstat_$c.csv 1 $dtime" 1> /dev/null &
        
	done
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

	for (( c=1; c<=4; c++ ))
	do
		mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/child$c
	        ssh -n ${ip_child[$c]}  "scp child_dstat_$c.csv $pg_user@$ip_driver:/home/sachin/pgbench-tools/results/$TEST/report/child$c/" 2>> error.log
	done


	mv /home/sachin/pgbench-tools/config_temp /home/sachin/pgbench-tools/results/$TEST/

	#/home/sachin/postgres_install/bin/pg_basebackup -x -h localhost -p 5434 -D /home/sachin/backup
	#cp -r backup/ postgres_data1

	for (( c=1; c<=4; c++ ))
	do
        	ssh -n ${ip_child[$c]}  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -mi 1>/dev/null" 2>error.log
	        sleep 5
	done


	ssh -n $ip_parent  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -mi 1>/dev/null" 2>error.log
        sleep 20


done



