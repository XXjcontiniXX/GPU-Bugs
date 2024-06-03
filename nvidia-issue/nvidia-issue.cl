__kernel void prefix_scan(
  __global atomic_uint *partition,
  __global uint * debug) {

  __local uint workgroup_id;
  if (get_local_id(0) == 0) {
    workgroup_id = atomic_load_explicit(partition, memory_order_relaxed);
  }
  work_group_barrier(CLK_LOCAL_MEM_FENCE);


  __local uint exclusive_prefix;
  if (get_local_id(0) == 0) {
    exclusive_prefix = 1;
  }


  if (workgroup_id == 0) {
    if (get_sub_group_id() == 0) {
      sub_group_barrier(CLK_LOCAL_MEM_FENCE);
      uint scanned_prefix = sub_group_scan_exclusive_add(get_sub_group_local_id());
      if (get_sub_group_local_id() == get_sub_group_size() - 1) {
            exclusive_prefix = scanned_prefix;}}

    // ensure all threads in the block see exclusive_prefix  
    work_group_barrier(CLK_LOCAL_MEM_FENCE);
    if (get_sub_group_id() == 0)
      {debug[0] = exclusive_prefix;}
    if (get_sub_group_id() == 1) 
      {debug[1] = exclusive_prefix;}}}
