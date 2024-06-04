__kernel void nvidia_issue(
  __global atomic_uint *partition,
  __global uint * debug) {

  // Dynamically load buffer into local memory.
  // As a part of prefix-scan, atomic_load_explicit is actually an atomic_fetch_add, used to dynamically assign workgroup_ids.
  __local uint workgroup_id;
  if (get_local_id(0) == 0) {
    workgroup_id = atomic_load_explicit(partition, memory_order_relaxed);
  }
  work_group_barrier(CLK_LOCAL_MEM_FENCE);


  // Local memory variable declared then intialized to 1 by thread one of first subgroup.
  __local uint exclusive_prefix;
  if (get_local_id(0) == 0) {
    exclusive_prefix = 1;
  }

  // workgroup 0 and subgroup 0
  if (workgroup_id == 0) {    
    if (get_sub_group_id() == 0) {
      
      // All threads of subgroup 0 should now be able to observe exclusive_prefix for use on line 30.
      sub_group_barrier(CLK_LOCAL_MEM_FENCE);
      // Perform subgroup wide scan based on thread's id within the subgroup.
      uint scanned_prefix = sub_group_scan_exclusive_add(get_sub_group_local_id());
      // Last thread of subgroup 0 updates local memory.
      if (get_sub_group_local_id() == get_sub_group_size() - 1) {
            exclusive_prefix = scanned_prefix;}}


    // Observe bug //
    /////////////////
    // Propogate local memory set on line 30, by a member of subgroup 0, to the rest of the workgroup.   
    work_group_barrier(CLK_LOCAL_MEM_FENCE);
    // Subgroup 0 observes exclusive_prefix as changed by line 30, debug[0] = 465.
    if (get_local_id(0) == 0)
      {debug[0] = exclusive_prefix;}
    // Subgroup 1 does not observe exclusive_prefix as changed by line 30, debug[1] = 1. 
    if (get_local_id(0) == 32) 
      {debug[1] = exclusive_prefix;}
  }

  // work_group_barrier fails to propogate exclusive_prefix to higher subgroups as a result of
  // a combination of dynamically loading the partition buffer and calling the subgroup barrier inside of the lookback phase. 
}
