#!/bin/bash

	pg_scale=2000
	cnt=$((pg_scale*100000))
        cnt=$((cnt/10))
        count1=1
        count2=$((cnt+1))

        for (( c=1; c<=10; c++ ))
        do
        #	echo $count1
	        echo $count2
		#psql -d pgbench -p 5434 -c "COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=$count1 AND aid<$count2) TO '/home/sachin/fix_scale_fdw/child108-$c.csv' WITH DELIMITER ',' CSV HEADER;"
		#psql -d pgbench -p 5434 -c "COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=$count1 AND aid<$count2) TO STDOUT" | psql -d pgbench -h xxx.xxx.xxx.xxx -p 5434 -c "COPY pgbench_accounts_1 FROM STDIN"
		count1=$count2
        	count2=$((cnt+count2))

	done


