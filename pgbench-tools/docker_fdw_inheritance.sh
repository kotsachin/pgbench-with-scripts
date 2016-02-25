#!/bin/bash

scale=5
port=5432
count1=1
count2=100001

#sudo docker run -d -p 5433 -t centos-postgresql-source /bin/bash

CONTAINER=$(sudo docker run -d -p $port -t v1-centos-postgresql-source /bin/bash)
CONTAINER_IP=$(sudo docker inspect $CONTAINER | grep IPAddress | awk '{ print $2 }' | tr -d ',"')
sudo docker exec $CONTAINER  /etc/init.d/postgresql start
#sudo docker exec $CONTAINER  yum install sysstat -y
sudo docker exec $CONTAINER  yum install dstat -y
#sudo docker exec $CONTAINER  yum install gnuplot -y

sleep 5

#/home/sachin/postgres_install/bin/dropdb -p $port -h $CONTAINER_IP -U docker pgbench
/home/sachin/postgres_install/bin/createdb -p $port -h $CONTAINER_IP -U docker pgbench
/home/sachin/postgres_install/bin/pgbench -i -p $port -h $CONTAINER_IP -U docker -d pgbench

/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "DELETE  FROM pgbench_accounts;"
/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "DELETE  FROM pgbench_history;"
/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "DELETE  FROM pgbench_tellers;"
/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "DELETE  FROM pgbench_branches;"


for (( c=1; c<=$scale; c++ ))
do

	CON=$(sudo docker run -d -p $port -t v1-centos-postgresql-source /bin/bash)
	CON_IP[$c]=$(sudo docker inspect $CON | grep IPAddress | awk '{ print $2 }' | tr -d ',"')
 	echo ${CON_IP[$c]}       

        sleep 5
	sudo docker exec $CON  /etc/init.d/postgresql start
	#sudo docker exec $CON  yum install sysstat -y
	#sudo docker exec $CON  yum install dstat -y
	#sudo docker exec $CON  yum install gnuplot -y
	sleep 5        
	/home/sachin/postgres_install/bin/createdb -p $port -h ${CON_IP[$c]} -U docker pgbench
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h ${CON_IP[$c]} -U docker -c "CREATE TABLE pgbench_accounts_$c(aid  integer, bid  integer, abalance integer , filler character(84), check (aid >= '$count1' AND aid < '$count2') );"
        
        count1=$((count1+100000))
        count2=$((count2+100000))

done

#/home/sachin/postgres_install/bin/psql -d pgbench -p 5433 -c "CREATE TABLE pgbench_accounts_1(aid  integer, bid  integer, abalance integer , filler character(84), check (aid >= '1' AND aid < '50001') );"

#--------------
/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "CREATE EXTENSION postgres_fdw;"


for (( c=1; c<=$scale; c++ ))
do
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "CREATE SERVER server_$c FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${CON_IP[$c]}', port '$port', dbname 'pgbench');"
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "CREATE USER MAPPING FOR PUBLIC SERVER server_$c OPTIONS (password '');"
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "CREATE FOREIGN TABLE pgbench_accounts_f_$c (aid  integer, bid  integer, abalance integer , filler character(84)) INHERITS (pgbench_accounts) SERVER server_$c OPTIONS (table_name 'pgbench_accounts_$c');"

done

#----------
case "$scale" in

2)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -f /home/sachin/triggers/trigger2.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker < /home/sachin/pgbench_scale-2.dump
    ;;
5)  /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -f /home/sachin/triggers/trigger5.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker < /home/sachin/pgbench_scale-5.dump
    ;;
10) /home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -f /home/sachin/triggers/trigger10.sql
	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker -c "CREATE TRIGGER pgbench_accounts_insert BEFORE INSERT ON pgbench_accounts FOR EACH ROW EXECUTE PROCEDURE pgbench_accounts_insert_trigger();"

	/home/sachin/postgres_install/bin/psql -d pgbench -p $port -h $CONTAINER_IP -U docker < /home/sachin/pgbench_scale-10.dump
    ;;
*) echo "Scale is not correct"
   ;;
esac

mkdir -p /dev/shm/dstat2graphs
chown apache:apache /dev/shm/dstat2graphs

cp /home/sachin/pgbench-tools/config /home/sachin/pgbench-tools/config_temp

CONFIG=/home/sachin/pgbench-tools/config_temp
echo "SCALES=$scale" >> $CONFIG
echo "# Test/result database connection" >> $CONFIG
echo "TESTHOST=$CONTAINER_IP" >> $CONFIG
echo "TESTUSER=docker" >> $CONFIG
echo "TESTPORT=5432" >> $CONFIG
echo "TESTDB=pgbench" >> $CONFIG

sudo docker exec $CONTAINER dstat -tvfn --output r_dstat.csv 1 > /dev/null &
r_dstat=$!

dstat -tvfn --output l_dstat.csv 1 > /dev/null &
dstat=$!


. ./runset

sudo docker exec $CONTAINER kill -9 $r_dstat
kill -9 $dstat

RESULTPSQL="psql -h localhost -U sachin -p 5432 -d results"
TEST=`$RESULTPSQL -A -t -c "select max(test) from tests"`
echo "$TEST"

mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/
mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/local/
mkdir -p /home/sachin/pgbench-tools/results/$TEST/report/remote/

sudo docker cp $CONTAINER:/r_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/remote/
cp l_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/local/

rm -f /home/sachin/pgbench-tools/l_dstat.csv 

/home/sachin/pgbench-tools/dstat2graphs/dstat2graphs.pl /home/sachin/pgbench-tools/results/$TEST/report/remote/r_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/remote/ 512 192 0 0 0 0

/home/sachin/pgbench-tools/dstat2graphs/dstat2graphs.pl /home/sachin/pgbench-tools/results/$TEST/report/local/l_dstat.csv /home/sachin/pgbench-tools/results/$TEST/report/local/ 512 192 0 0 0 0


sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)


#cp -rf results /var/www/html/
rm /home/sachin/pgbench-tools/config_temp
