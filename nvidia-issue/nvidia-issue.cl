__kernel void nvidia_issue(
  __global atomic_uint *partition,
  __global uint * debug) {

  // Dynamically load buffer into local memory.
  // As a part of prefix-scan, atomic_load_explicit is actually an atomic_fetch_add, used to dynamically assign workgroup_ids.
  __local uint workgroup_id;
  __local uint local_scan;

  if (get_local_id(0) == 0) {
    workgroup_id = atomic_fetch_add(partition, memory_order_relaxed);
  }
  work_group_barrier(CLK_LOCAL_MEM_FENCE);


  // Local memory variable declared then intialized to 1 by thread one of first subgroup.
  if (get_local_id(0) == 0) {
    local_scan = 5;
  }

  // subgroup 0

    if (get_sub_group_id() == 0) {
      sub_group_barrier(CLK_LOCAL_MEM_FENCE);
      uint sgn = sub_group_scan_exclusive_add(1);
      if (get_sub_group_local_id() == 31) {
        local_scan = sgn;
      }
    }

    work_group_barrier(CLK_LOCAL_MEM_FENCE);


    // subgroup 0
    if (get_local_id(0) == 0)
    {
      debug[0] = local_scan;
    }
  
    // subgroup 1
    if (get_local_id(0) == 32) 
    {
      debug[1] = local_scan;
    }

    // in subgroup 0, always observe correct values.
    // in subgroup 1, always observe intial value of local_value .
  }

