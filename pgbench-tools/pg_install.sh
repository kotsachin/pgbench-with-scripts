#!/bin/bash


scale_temp=2
c=1
exec<ip_list.conf
while read ip_child[$c]
do
        echo ${ip_child[$c]}
	scp -r postgres_install/ sachin@${ip_child[$c]}:	

	ssh -n ${ip_child[$c]} "mkdir -p postgres_data"
	ssh -n ${ip_child[$c]} "/home/sachin/postgres_install/bin/initdb -D /home/sachin/postgres_data/ 1>/dev/null" 2>>error.log
	ssh -n ${ip_child[$c]} "echo "listen_addresses = '*'" >> /home/sachin/postgres_data/postgresql.conf 1>/dev/null" 2>>error.log

	ssh -n ${ip_child[$c]} "echo "host    all             all             xxx.xxx.xxx.xxx/32            trust" >> /home/sachin/postgres_data/pg_hba.conf 1>/dev/null" 2>>error.log
	ssh -n ${ip_child[$c]} "echo "host    all             all             xxx.xxx.xxx.xxx/32            trust" >> /home/sachin/postgres_data/pg_hba.conf 1>/dev/null" 2>>error.log

	ssh -n ${ip_child[$c]} "/home/sachin/postgres_install/bin/pg_ctl -D /home/sachin/postgres_data/ start 1>/dev/null" 2>>error.log
        scale_temp=$((scale_temp-1))
        c=$((c+1))
        if [ $scale_temp -le 0 ]
        then
                break
        fi
done



