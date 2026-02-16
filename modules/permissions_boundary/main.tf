// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_ssoadmin_permissions_boundary_attachment" "managed" {
  count              = local.permissions_boundary_type == "aws_managed_policy" ? 1 : 0
  instance_arn       = var.instance_arn
  permission_set_arn = var.permission_set_arn
  permissions_boundary {
    managed_policy_arn = "arn:aws:iam::aws:policy/${var.permissions_boundary.aws_managed_policy}"
  }

  lifecycle {
    ignore_changes = [instance_arn]
  }
}

resource "aws_ssoadmin_permissions_boundary_attachment" "custom" {
  count              = local.permissions_boundary_type == "customer_managed_policy" ? 1 : 0
  instance_arn       = var.instance_arn
  permission_set_arn = var.permission_set_arn
  permissions_boundary {
    customer_managed_policy_reference {
      name = var.permissions_boundary.customer_managed_policy
      path = "/"
    }
  }

  lifecycle {
    ignore_changes = [instance_arn]
  }
}
