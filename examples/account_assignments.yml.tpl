# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

Admin:
  principal: Admin
  principal_type: Group
  permission_sets: 
    - Admin
    - ReadOnly 
  account_list: 
    - ${management}
    - ${audit}
