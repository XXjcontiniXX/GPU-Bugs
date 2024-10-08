// 1 workgroup // 128 threads

__kernel void amd_issue(__global uint * debug) {

  __local uint local_var;

  // must be ONLY first sub group - without if, bug is not induced 
  if (get_sub_group_id() == 0) { 
    sub_group_barrier(CLK_LOCAL_MEM_FENCE); // (workgroup barrier also stimulates bug)
  }

  // issue occurs only if local var is set by thread in first subgroup
  if (get_sub_group_id() == 0 && get_sub_group_local_id() == 0) {
    local_var = 0;
    debug[0] = local_var;
  }

  // any false predicate, but nothing to simple or whole things gets optmized away
  if (get_sub_group_id() > 20) {
    local_var = 5;
  }

  work_group_barrier(CLK_LOCAL_MEM_FENCE);

  // observe trash in debug[1]
  if (get_sub_group_id() == 1 && get_sub_group_local_id() == 0) { // works for values under 64 // workgroup_barrier only propogates to subgroup
    debug[1] = local_var;
  }
}
