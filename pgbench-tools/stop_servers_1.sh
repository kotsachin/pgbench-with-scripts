#!/bin/bash

scale=5
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


for (( c=1; c<=$scale; c++ ))
do
        #ssh $ip_child "rm -rf /home/sachin/postgres_data/*"
        #ssh $ip_child "mkdir -p /home/sachin/postgres_data/child$c"
        #ssh $ip_child "/home/sachin/postgres_install/bin/initdb -D /home/sachin/postgres_data/child$c"
        #ssh $ip_child "echo "port = $port_child" >> /home/sachin/postgres_data/child$c/postgresql.conf"
        #sleep 5
        ssh -n ${ip_child[$c]}  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop 1>/dev/null" 2>error.log
        sleep 5
done

ssh -n xxx.xxx.xxx.xxx  "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ stop 1>/dev/null" 2>error.log
