#!bin/bash


for (( c=1; c<=3; c++ ))
do
	./partitioning.sh
	sleep 20
done
for (( c=1; c<=3; c++ ))
do
	./partitioning_1.sh
	sleep 20
done
for (( c=1; c<=3; c++ ))
do
	./partitioning_2.sh
	sleep 20
done
for (( c=1; c<=3; c++ ))
do
	./partitioning_3.sh
	sleep 20
done
