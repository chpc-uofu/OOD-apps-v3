#!/bin/bash

filepath=$HOME/ondemand/data

> ${filepath}/cluster.txt
> ${filepath}/account.txt
> ${filepath}/partition.txt

clusters=()
accounts=()
partitions=()

for allocation in `/uufs/chpc.utah.edu/sys/bin/myallocation | grep "Account:" | awk '{print $(NF-4) ":" $(NF-2) ":" $NF}'`; do

	cluster=`cut -d: -f1 <<< $allocation`
	cluster=${cluster:7:-5}
	if [[ " ${clusters[@]} " != *" $cluster "* ]]; then
		echo $cluster >> ${filepath}/cluster.txt
		clusters+=($cluster)
	fi

	account=`cut -d: -f2 <<< $allocation`
	account=${account:7:-5}
	if [[ " ${accounts[@]} " != *" $account "* ]]; then
		echo $account >> ${filepath}/account.txt
		accounts+=($account)
	fi

	partition=`cut -d: -f3 <<< $allocation`
	partition=${partition:7:-4}
	if [[ " ${partitions[@]} " != *" $partition "* ]]; then
		echo $partition >> ${filepath}/partition.txt
		partitions+=($partition)
	fi
done
