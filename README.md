# GPU-Bugs
## Dependencies
  You will need clspv. Once installed `make all` and `/build/[VENDOR]-issue.run` to observe the bugs. 
  
### amd-issue
  Testing suggests that work_group_barrier() fails to propagate local variable initialization in the first subgroup to threads in higher subgroups when  the rest of the setup shown is present. This issue occurs on both the open source and proprietary drivers of both the discrete and integrated AMD gpus on waterthrush.
  * AMD Radeon 7900 XT, AMD Ryzen 7 5700G Radeon Graphics
    * AMD open and proprietary driver version 2.0.270


  
### nvidia-issue
  A combination of dynamically loading the partition buffer and calling the subgroup barrier with subgroup 0 causes the work_group_barrier to fail to propogate exclusive prefix from the last thread of subgroup 0 to threads in higher subgroups. This issue occurs on the discrete Nvidia GPU on Shrike.
  * NVIDIA GTX 4070
    * Proprietary driver version 535.171.4.0
  
#### Notes
  When compiling an error: `MESA-INTEL: warning: cannot initialize blitter engine` occurs but this can be ignored.
