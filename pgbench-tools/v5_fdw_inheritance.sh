#!/bin/bash

	scale=5
	runtime=1800
	dtime=$((runtime+10))
	port=5434
	ip_driver=xxx.xxx.xxx.xxx
	ip_parent=xxx.xxx.xxx.xxx
	pg_user=sachin
	#pg_scale=$((scale*200))
	pg_scale=1000



#-------------------------
	scale_temp=$scale
	#scale_temp=4
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

	for (( c=1; c<=$scale; c++ ))
	do
        	ssh -n ${ip_child[$c]}  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -mi 1>/dev/null" 2>error.log
	        sleep 5
	done

	ssh -n $ip_parent  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -mi 1>/dev/null" 2>error.log
        sleep 20

#-------------------------
	
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
		
		#psql -d pgbench -p 5434 -c "COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=$count1 AND aid<$count2) TO STDOUT" | psql -d pgbench -h ${ip_child[$c]} -p $port -c "COPY pgbench_accounts_$c FROM STDIN"

		echo $count1
		echo $count2
	
		count1=$count2
		count2=$((count2+cnt))
	done

	/home/sachin/postgres_install/bin/psql -p $port -h $ip_parent -U $pg_user -d pgbench -f /home/sachin/pgbench-tools/init/alter_tables.sql
#-------------------------
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE EXTENSION postgres_fdw;"

	for (( c=1; c<=$scale; c++ ))
	do
		/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE SERVER server_$c FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${ip_child[$c]}', port '$port', dbname 'pgbench');"
		/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE USER MAPPING FOR PUBLIC SERVER server_$c OPTIONS (password '');"
		/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE FOREIGN TABLE pgbench_accounts_f_$c (aid  bigint, bid  integer, abalance integer , filler character(84)) INHERITS (pgbench_accounts) SERVER server_$c OPTIONS (table_name 'pgbench_accounts_$c');"

	done

#-------------------------
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -f /home/sachin/pgbench-tools/trigger4.sql

        /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $ip_parent -U $pg_user -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

        #psql -d pgbench -p 5434 -c "COPY (SELECT bid, bbalance, filler from pgbench_branches WHERE bid >=1 AND bid<=$pg_scale) TO STDOUT" | psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_branches(bid, bbalance, filler) FROM STDIN"

        #tg_scale=$((pg_scale*10))

        #psql -d pgbench -p 5434 -c "COPY (SELECT tid, bid, tbalance, filler from pgbench_tellers WHERE tid >=1 AND tid<=$tg_scale) TO STDOUT" | psql -d pgbench -h $ip_parent -p $port -c "COPY pgbench_tellers(tid, bid, tbalance, filler) FROM STDIN"
	



