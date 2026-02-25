// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for account_set in local.account_permission_set : "${account_set.account}-${account_set.permission_set}" => account_set }

  instance_arn       = var.instances_arns
  permission_set_arn = each.value.permission_set_arn
  principal_id       = var.resolved_principal_id
  principal_type     = local.principal_type_upper
  target_id          = each.value.account
  target_type        = "AWS_ACCOUNT"

  lifecycle {
    ignore_changes = [
      instance_arn,
      permission_set_arn,
      principal_id
    ]
  }
}
