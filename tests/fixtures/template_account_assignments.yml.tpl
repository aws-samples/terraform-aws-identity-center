Admin:
  principal: Admin
  principal_type: Group
  permission_sets:
    - Admin
  account_list:
    - "${account_map["management"]}"
Workloads:
  principal: Developers
  principal_type: User
  permission_sets:
    - Admin
  account_list: ${workload_accounts}
