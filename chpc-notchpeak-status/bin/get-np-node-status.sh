#!/bin/bash
# VERSION: 0.7
# BLAME: Jason <yalim@asu.edu>
# BLAME: MC <m.cuma@utah.edu>
#set -x
set -euo pipefail

readonly working_dir="/uufs/chpc.utah.edu/sys/ondemand/chpc-apps/chpc-notchpeak-status"
cd "$working_dir"

readonly density_limit=10 # save one per ten minutes
readonly snapshot_dir="/uufs/chpc.utah.edu/sys/ondemand/node-usage-snapshots/snapshot-np"
readonly snapshot_dat=$(date "+${snapshot_dir}/node-status-%FT%T.csv")
readonly snapshot_job_stats_dat=$(date "+${snapshot_dir}/job-stats-%FT%T.csv")
readonly snapshot_density_proc="${snapshot_dir}/.snapshot_modulo.do.not.delete"
# short format is necessary to be able to easily parse the Reason column later
# %N: NodeList, %C: Cores (A/I/O/T), %P: Partition, %T: State Extended
# %O: CPU Load, %c: Cores on Node, %f: features, %E: Reason
readonly sinfo_short_fmt="%N %C %P %T %O %c %f '%E'"
# long format necessary since some fields are not availabe in the short fmt.
#   N.B.: GresUsed req. fmt. :: undoc. limit of 21 char. 
readonly sinfo_long_fmt='FreeMem,AllocMem,Memory,GresUsed:300,Gres:300,Timestamp'

! [[ -d "$snapshot_dir" ]] && mkdir -p "$snapshot_dir" || :
! [[ -e "$snapshot_density_proc" ]] && echo 0 > "$snapshot_density_proc" || :

./bin/local-sq-stats > "$snapshot_job_stats_dat"

paste                                   \
  <(/uufs/notchpeak.peaks/sys/installdir/slurm/std/bin/sinfo -M notchpeak --Node -o "$sinfo_short_fmt" | grep -v CLUSTER | sed -e s/\"/\\\\\"/g -e s/\'/\"/g ) \
  <(/uufs/notchpeak.peaks/sys/installdir/slurm/std/bin/sinfo -M notchpeak --Node -O "$sinfo_long_fmt" | grep -v CLUSTER  ) \
  > "$snapshot_dat"
./bin/plot-np-node-status.py "$snapshot_dat" "$snapshot_job_stats_dat"

# Exit if the python script crashed, e.g. due to missing sinfo data
if test $? -ne 0
then
  echo "Page generation failed"
  exit 1
fi
# Inject refresh attribute into output plotly html
awk '
  { 
    if ( NR == 2 ) { 
      print "<head><meta http-equiv=\"refresh\" content=\"30\"/></head>" 
    } else {
      print
    }
  }
' sol2.html \
  | sed -e 's/<body>/<body style="background-color:#eee;">/' \
        -e 's/class="plotly-graph-div" style="/&margin:auto;/' \
  > np.html
rm sol2.html

readonly count=$(awk 'NR==1 {print ++$1}' "$snapshot_density_proc")

# Save and compress every <density_limit> steps
if (( count == density_limit )); then
  echo 0 > "$snapshot_density_proc"
  zstd -19 --rm "$snapshot_dat"
  zstd -19 --rm "$snapshot_job_stats_dat"
else
  echo $count > "$snapshot_density_proc"
  rm "$snapshot_dat" "$snapshot_job_stats_dat"
fi
