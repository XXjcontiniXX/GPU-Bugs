# GPU-Bugs
## amd-wgbarrier-1
  Empirical testing suggests that work_group_barrier() fails to propagate local variable initialization to threads outside of the subgroup where it was initialized, when the local variable was initialized in the first subgroup- and the rest of the setup shown is present. This issue occurs on both the open source and proprietary drivers of both the discrete and integrated AMD gpus on waterthrush.
