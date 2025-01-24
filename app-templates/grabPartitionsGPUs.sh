#!/bin/bash

# cron does not have path to sinfo
PATH="/uufs/notchpeak.peaks/sys/installdir/slurm/std/bin:$PATH"

# File to store the output
OUTPUT_FILE="/uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/gpus.txt"

# File containing the list of clusters
CLUSTER_FILE="/uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/cluster.txt"

# Empty the output file
> $OUTPUT_FILE

# Special case for notchpeak-shared-short
SPECIAL_PARTITION=( "notchpeak-shared-short" "efd-np" "tbicc-np" "civil-np" "efd-shared-np" "tbicc-shared-np" "civil-shared-np" "notchpeak-eval" "granite-gpu" )

# Function to process a partition
process_partition() {
    local cluster=$1
    local partition=$2
    echo $partition >> $OUTPUT_FILE
    # Run command for each partition and process the output
    sinfo -M $cluster -N -p $partition --Format='nodehost,gres:50,gresused:50' | awk 'NR > 1 {print $2}' | tr ',' '\n' | awk -F ':' '{print $2}' | sort | uniq | sed '/^$/d' >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE # Add extra line between partitions
}

# Iterate over each cluster
while read cluster; do
    # Get a list of partitions for current cluster
    partitions=$(sinfo -M $cluster | grep gpu | awk '{print $1}' | uniq)

    # Add shared-short to the list
    for part in  ${SPECIAL_PARTITION[@]}; do
        if sinfo -M $cluster -p $part | grep -q $part; then
            partitions="$partitions $part"
        fi
    done

    # Iterate over each partition
    for partition in $partitions; do
        process_partition $cluster $partition
    done
done < $CLUSTER_FILE


