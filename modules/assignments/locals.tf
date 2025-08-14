// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  principal_type_upper = upper(var.principal_type)
  principal_type_lower = lower(var.principal_type)

  data_source = var.principal_type == "User" ? data.aws_identitystore_user.this[0].user_id : data.aws_identitystore_group.this[0].group_id

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
