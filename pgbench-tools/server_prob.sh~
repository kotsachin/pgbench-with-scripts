#!/bin/bash

for (( scale=1; scale<=4; scale++ ))
do
	ip_parent=xxx.xxx.xxx.xxx
	port=5434
	pg_user=sachin
	echo "Server is starting...."
        ssh -n $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start -m fast 1>/dev/null" 2>error.log
	sleep 5
	/home/sachin/postgres_install/bin/dropdb -p $port -h $ip_parent -U $pg_user pgbench
        /home/sachin/postgres_install/bin/createdb -p $port -h $ip_parent -U $pg_user pgbench

	echo "Server is stopping...."
        ssh -n $ip_parent "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop -m fast 1>/dev/null" 2>error.log
	sleep 5
done

