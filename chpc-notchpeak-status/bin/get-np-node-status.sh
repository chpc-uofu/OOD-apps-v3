#!/bin/bash
# VERSION: 0.7
# BLAME: Jason <yalim@asu.edu>
# BLAME: MC <m.cuma@utah.edu>
# BLAME: Kai <kai.ebira@utah.edu>
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
      print "<head><meta http-equiv=\"refresh\" content=\"300\"/></head>\n<select id=\"partitionSelector\">\n    <option value=\"all\">All Partitions</option>\n</select>"
    } else {
      print
    }
    if ( NR == 5 ) {
      print "<script>"
      print "const element = document.querySelector(\".plotly-graph-div\");"
      print "const dataKey = element.id + \"PlotData\""
      print "const layoutKey = element.id + \"layoutData\""
      print "function clearCache(pages) {"
      print "    const currentURL = window.location.href;"
      print "    if (pages.some(page => currentURL.includes(page))) {"
      print "        localStorage.removeItem(dataKey);"
      print "        localStorage.removeItem(layoutKey);"
      print "    }"
      print "}"
      print "function resetCache(element) {"
      print "    if (element) {"
      print "        const gd = document.getElementById(element.id);"
      print "        localStorage.setItem(dataKey, JSON.stringify(gd.data));"
      print "        localStorage.setItem(layoutKey, JSON.stringify(gd.layout));"
      print "    }"
      print "}"
      print "window.addEventListener(\"beforeunload\", function() {"
      print "    clearCache([\"chpc-lonepeak-status\", \"chpc-ash-status\", \"chpc-kingspeak-status\", \"chpc-notchpeak-status\"]);"
      print "});"
      print "resetCache(element);"
      print "if (!localStorage.getItem(dataKey)) {"
      print "    const gd = document.getElementById(element.id);"
      print "    localStorage.setItem(dataKey, JSON.stringify(gd.data));"
      print "    localStorage.setItem(layoutKey, JSON.stringify(gd.layout));"
      print "}"
      print "const gd = document.getElementById(element.id);"
      print "const customdata = gd.data;"
      print "const nodePartitionList = new Map();"
      print "for (let i = 0; i < customdata.length; i++) {"
      print "    let section = customdata[i].customdata;"
      print "    let nodes = customdata[i].text;"
      print "    for (let j = 0; j < section.length; j++) {"
      print "        nodePartitionList.set(nodes[j], section[j][2])"
      print "    }"
      print "}"
      print "const uniquePartitions = new Set();"
      print "for (let value of nodePartitionList.values()) {"
      print "    let partitions = value.split(\",\");"
      print "    partitions.forEach(partition => uniquePartitions.add(partition));"
      print "}"
      print "const partitionSelector = document.getElementById(\"partitionSelector\");"
      print "uniquePartitions.forEach(partition => {"
      print "    const option = document.createElement(\"option\");"
      print "    option.value = partition;"
      print "    option.textContent = partition;"
      print "    partitionSelector.appendChild(option);"
      print "});"
      print "document.getElementById(\"partitionSelector\").addEventListener(\"change\", function() {"
      print "    const originalData = JSON.parse(localStorage.getItem(dataKey));"
      print "    const originalLayout = JSON.parse(localStorage.getItem(layoutKey));"
      print "    Plotly.react(element.id, originalData, originalLayout);"
      print "    const filteredNodes = new Set();"
      print "    const selectedPartition = this.value;"
      print "    if (selectedPartition === \"all\") {"
      print "        Plotly.react(element.id, originalData, originalLayout);"
      print "        return;"
      print "    }"
      print "    nodePartitionList.forEach(function(value, key) {"
      print "        if (value.includes(selectedPartition))"
      print "            filteredNodes.add(key);"
      print "    });"
      print "    for (let i = 0; i < customdata.length; i++) {"
      print "        let tempIndexes = [];"
      print "        let tempNodes = customdata[i].text;"
      print "        for (let j = 0; j < tempNodes.length; j++) {"
      print "            if (filteredNodes.has(tempNodes[j])) {"
      print "                tempIndexes.push(j);"
      print "            }"
      print "        }"
      print "        const filteredCustomData = tempIndexes.map(index => customdata[i].customdata[index]);"
      print "        const filteredText = tempIndexes.map(index => customdata[i].text[index]);"
      print "        const filteredX = tempIndexes.map(index => customdata[i].x[index]);"
      print "        const filteredY = tempIndexes.map(index => customdata[i].y[index]);"
      print "        const update = {"
      print "            customdata: [filteredCustomData],"
      print "            text: [filteredText],"
      print "            x: [filteredX],"
      print "            y: [filteredY]"
      print "        };"
      print "        Plotly.update(element.id, update, {}, i);"
      print "    }"
      print "});"
      print "</script>"
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
