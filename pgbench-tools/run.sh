#!bin/bash


for (( c=1; c<=3; c++ ))
do
	./copy_fdw_inheritance.sh
	sleep 5
	sh stop_servers.sh
	sleep 20
done

for (( c=1; c<=3; c++ ))
do
	./copy_fdw_inheritance_1.sh
	sleep 5
	sh stop_servers_1.sh
	sleep 20
done
	
for (( c=1; c<=3; c++ ))
do
	./copy_fdw_inheritance_2.sh
	sleep 5
	sh stop_servers_2.sh
	sleep 20
done

for (( c=1; c<=3; c++ ))
do
	./copy_fdw_inheritance_3.sh
	sleep 5
	sh stop_servers_3.sh
	sleep 20
done
