// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  permission_sets = can(regex("\\.tpl$", var.permission_sets)) ? yamldecode(templatefile(var.permission_sets, var.template_variables)) : yamldecode(file(var.permission_sets))

  account_assignments = can(regex("\\.tpl$", var.account_assignments)) ? yamldecode(templatefile(var.account_assignments, var.template_variables)) : yamldecode(file(var.account_assignments))

  instance_arn      = length(var.instance_arn) > 1 ? var.instance_arn : tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = length(var.identity_store_id) > 1 ? var.identity_store_id : tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}
