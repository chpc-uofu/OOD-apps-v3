#!/bin/bash
# VERSION: 0.7
# BLAME: Jason <yalim@asu.edu>
# BLAME: MC <m.cuma@utah.edu>
#set -x
set -euo pipefail

readonly working_dir="/uufs/chpc.utah.edu/sys/ondemand/chpc-apps/chpc-kingspeak-status"
cd "$working_dir"

readonly density_limit=10 # save one per ten minutes
readonly snapshot_dir="/uufs/chpc.utah.edu/sys/ondemand/node-usage-snapshots/snapshot-kp"
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
  <(/uufs/notchpeak.peaks/sys/installdir/slurm/std/bin/sinfo -M kingspeak --Node -o "$sinfo_short_fmt" | grep -v CLUSTER | sed -e s/\"/\\\\\"/g -e s/\'/\"/g ) \
  <(/uufs/notchpeak.peaks/sys/installdir/slurm/std/bin/sinfo -M kingspeak --Node -O "$sinfo_long_fmt" | grep -v CLUSTER ) \
  > "$snapshot_dat"
./bin/plot-kp-node-status.py "$snapshot_dat" "$snapshot_job_stats_dat"

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
      print "<script>\nconst element = document.querySelector(\".plotly-graph-div\");\nconst dataKey = element.id + \"PlotData\"\nconst layoutKey = element.id + \"layoutData\"\nfunction clearCache(pages) {\n    const currentURL = window.location.href;\n    if (pages.some(page => currentURL.includes(page))) {\n        localStorage.removeItem(dataKey);\n        localStorage.removeItem(layoutKey);\n    }\n}\nfunction resetCache(element) {\n    if (element) {\n        const gd = document.getElementById(element.id);\n        localStorage.setItem(dataKey, JSON.stringify(gd.data));\n        localStorage.setItem(layoutKey, JSON.stringify(gd.layout));\n    }\n}\nwindow.addEventListener(\"beforeunload\", function() {\n    clearCache([\"chpc-lonepeak-status\", \"chpc-ash-status\", \"chpc-kingspeak-status\", \"chpc-notchpeak-status\"]);\n});\nresetCache(element);\nif (!localStorage.getItem(dataKey)) {\n    const gd = document.getElementById(element.id);\n    localStorage.setItem(dataKey, JSON.stringify(gd.data));\n    localStorage.setItem(layoutKey, JSON.stringify(gd.layout));\n}\nconst gd = document.getElementById(element.id);\nconst customdata = gd.data;\nconst nodePartitionList = new Map();\nfor (let i = 0; i < customdata.length; i++) {\n    let section = customdata[i].customdata;\n    for (let j = 0; j < section.length; j++) {\n        nodePartitionList.set(section[j][0], section[j][2])\n    }\n}\nconst uniquePartitions = new Set();\nfor (let value of nodePartitionList.values()) {\n    let partitions = value.split(\",\");\n    partitions.forEach(partition => {\n        if (!partition.includes(\"shared\") || partition === \"notchpeak-shared-short\") {\n            uniquePartitions.add(partition);\n        }\n    });\n}\nconst partitionSelector = document.getElementById(\"partitionSelector\");\nuniquePartitions.forEach(partition => {\n    const option = document.createElement(\"option\");\n    option.value = partition;\n    option.textContent = partition;\n    partitionSelector.appendChild(option);\n});\ndocument.getElementById(\"partitionSelector\").addEventListener(\"change\", function() {\n    const originalData = JSON.parse(localStorage.getItem(dataKey));\n    const originalLayout = JSON.parse(localStorage.getItem(layoutKey));\n    Plotly.react(element.id, originalData, originalLayout);\n    const filteredNodes = new Set();\n    const selectedPartition = this.value;\n    if (selectedPartition === \"all\") {\n        Plotly.react(element.id, originalData, originalLayout);\n        return;\n    }\n    nodePartitionList.forEach(function(value, key) {\n        if (value.includes(selectedPartition))\n            filteredNodes.add(key);\n    });\n    for (let i = 0; i < customdata.length; i++) {\n        let tempIndexes = [];\n        let tempNodes = customdata[i].text;\n        for (let j = 0; j < tempNodes.length; j++) {\n            if (filteredNodes.has(tempNodes[j])) {\n                tempIndexes.push(j);\n            }\n        }\n        const filteredCustomData = tempIndexes.map(index => customdata[i].customdata[index]);\n        const filteredText = tempIndexes.map(index => customdata[i].text[index]);\n        const filteredX = tempIndexes.map(index => customdata[i].x[index]);\n        const filteredY = tempIndexes.map(index => customdata[i].y[index]);\n        const update = {\n            customdata: [filteredCustomData],\n            text: [filteredText],\n            x: [filteredX],\n            y: [filteredY]\n        };\n        Plotly.update(element.id, update, {}, i);\n    }\n   });\n</script>"
    }
  }
' sol2.html \
  | sed -e 's/<body>/<body style="background-color:#eee;">/' \
        -e 's/class="plotly-graph-div" style="/&margin:auto;/' \
  > kp.html
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
