Changes we had to make at CHPC (not exhaustive list)

- remove ssh.erb and rsh.erb from templates/bin as we are using standard ssh to talk between the nodes
- modify custom MPI start method in template/script.sh.erb
- modify cfx_assets/start-methods.ccl.erb to add I_MPI_FABRICS=tcp for Ethernet only clusters
- 17.1 does not get the Host Architecture String right for nodes 2+, for that reason only use 18.2

- TODO - allow to set both # of nodes and # of tasks

- ask OOD
 - multiple clusters through some dynamic form variable
 - tasks vs nodes
