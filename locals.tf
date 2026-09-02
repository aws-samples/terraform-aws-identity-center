// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  permission_set_defaults = {
    description               = null
    tags                      = null
    relay_state               = null
    session_duration          = null
    inline_policy             = null
    aws_managed_policies      = null
    customer_managed_policies = null
    permissions_boundary      = null
  }

  permission_sets_raw = can(regex("\\.tpl$", var.permission_sets)) ? yamldecode(templatefile(var.permission_sets, var.template_variables)) : yamldecode(file(var.permission_sets))

  // merge raw and defaults. enables users to create yaml files with just the minimum key value pairs
  permission_sets = {
    for name, permission_set in local.permission_sets_raw :
    name => merge(local.permission_set_defaults, permission_set)
  }

  account_assignments = can(regex("\\.tpl$", var.account_assignments)) ? yamldecode(templatefile(var.account_assignments, var.template_variables)) : yamldecode(file(var.account_assignments))
}
