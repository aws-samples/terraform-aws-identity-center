// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  permission_sets = can(regex("\\.tpl$", var.permission_sets)) ? yamldecode(templatefile(var.permission_sets, var.template_variables)) : yamldecode(file(var.permission_sets))

  account_assignments = can(regex("\\.tpl$", var.account_assignments)) ? yamldecode(templatefile(var.account_assignments, var.template_variables)) : yamldecode(file(var.account_assignments))
}
