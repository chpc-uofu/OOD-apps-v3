## System Status for CHPC

This app displays the current system status of available system clusters.

Customized [OSC System Status app](https://github.com/OSC/osc-systemstatus).

### Installation using OnDemand 1.8+

1. Git clone this repository
2. Run setup to verify app install

    ```bash
    scl enable ondemand -- bin/setup
    ```

3. If error, install gem dependencies in app directory

    ```bash
    scl enable ondemand -- bin/bundle install --path vendor/bundle
    ```

### CHPC modifications

- split resources reporting to general and owner
- added GPU counts
- added GPU running jobs count
- modified `app.rb` CLUSTERS to add preferred cluster ordering:
```
 CLUSTERS = OodCore::Clusters.new(OodCore::Clusters.load_file(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d').select(&:job_allow?)
   .select { |c| c.custom_config[:moab] || c.job_config[:adapter] == "slurm" }
   .reject { |c| c.metadata.hidden }
   .sort_by {|cluster| [cluster.metadata.priority.to_i, cluster.id]}
 )
```
and then in `/etc/ood/config/clusters.d`, add
```
  metadata:
    title: "Notchpeak"
    priority: 1
```

### Caveats

#### Cluster order

- I can not figure out how to order clusters. Ideally in the order notchpeak, kingspeak, lonepeak, ash, tangent. Even simple alphabetical ordering does not work, e.g. in app.rb, try
```
  CLUSTERS.sort_by{ |cluster| cluster.metadata.title.downcase }
```

- owner and general methods are more-less similar, except for a few parameters, so, the code could be simplified if we passed a variable to the method that would differentiate general/owner. I did not spend time trying to figure out how to do that. Ruby experts are welcome to give feedback on this. Example of this are methods `sinfo` and `sinfo_owner` in `lib/slurm_squeue_client.rb`.


### Debugging notes to self

- after modifying the rb files, do ```touch tmp/restart.txt```

- if object has been modified in the source file (e.g. adding new variables), restart the web server

- to write out variables to a file, use File.write:
```
File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{CLUSTERS.inspect}\n", mode: "a")
```

