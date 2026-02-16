// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each           = toset(var.name)
  instance_arn       = var.instance_arn
  permission_set_arn = var.permission_set_arn
  customer_managed_policy_reference {
    name = each.key
    path = "/"
  }

  lifecycle {
    ignore_changes = [instance_arn]
  }
}

