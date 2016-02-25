#!bin/bash


for (( c=1; c<=3; c++ ))
do
	./no_fdw_inheritance.sh
	sleep 20
done
for (( c=1; c<=3; c++ ))
do
	./no_fdw_inheritance_1.sh
	sleep 20
done
for (( c=1; c<=3; c++ ))
do
	./no_fdw_inheritance_2.sh
	sleep 20
done
for (( c=1; c<=3; c++ ))
do
	./no_fdw_inheritance_3.sh
	sleep 20
done
