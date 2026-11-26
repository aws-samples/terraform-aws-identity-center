// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  // normalised so "group", "Group" and "GROUP" all work
  principal_type = upper(var.principal_type)

  // only keys must be known at plan time, so IDs can come from the same apply
  principal_id_provided = contains(keys(var.principal_ids), var.principal)

  principal_id = (
    local.principal_id_provided ? var.principal_ids[var.principal] :
    local.principal_type == "USER" ? data.aws_identitystore_user.this[0].user_id :
    data.aws_identitystore_group.this[0].group_id
  )

  account_permission_set = flatten([
    for account in var.account_assignment : [
      for permission_set, arn in var.permission_set_arns : {
        account            = account
        permission_set     = permission_set
        permission_set_arn = arn
      }
    ]
  ])

}
