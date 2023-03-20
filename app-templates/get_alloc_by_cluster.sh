#!/bin/bash

# input parameter = cluster name

for allocation in `/uufs/chpc.utah.edu/sys/bin/myallocation | grep "Account:" | grep $1 | awk '{print $(NF-4) ":" $(NF-2) ":" $NF}'`; do

	account=`cut -d: -f2 <<< $allocation`
	account=${account:7:-5}

	partition=`cut -d: -f3 <<< $allocation`
	partition=${partition:7:-4}

	echo ${account}:${partition}
done
sync
