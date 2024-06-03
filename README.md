# GPU-Bugs
## Description
  
### amd-issue
  Empirical testing suggests that work_group_barrier() fails to propagate local variable initialization to threads outside of the subgroup where it was initialized, when the local variable was initialized in the first subgroup- and the rest of the setup shown is present. This issue occurs on both the open source and proprietary drivers of both the discrete and integrated AMD gpus on waterthrush.
  
### nvidia-issue
  A combination of dynamically loading the partition buffer and calling the subgroup barrier with subgroup 0 causes the work_group_barrier to fail to propogate exclusive prefix from the last thread of subgroup 0 to threads in higher subgroups. This issue occurs on the NVIDA GTX 4070 on Shrike.
  
#### Notes
  When compiling an error: `MESA-INTEL: warning: cannot initialize blitter engine` occurs but this can be ignored.