// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = toset(var.name)
  instance_arn       = var.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  permission_set_arn = var.permission_set_arn

  lifecycle {
    ignore_changes = [instance_arn]
  }
}

