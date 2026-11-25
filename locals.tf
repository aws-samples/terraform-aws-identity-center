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

  undefined_permission_sets = sort(distinct([
    for ps in flatten([for assignment in local.account_assignments : assignment.permission_sets]) :
    ps if !contains(keys(local.permission_sets), ps)
  ]))

  // every principal / account / permission set grant, with the block it came from.
  // null accounts are skipped here and reported by the assignments module validation
  assignment_grants = flatten([
    for block, assignment in local.account_assignments : [
      for account in assignment.account_list : [
        for ps in assignment.permission_sets : {
          grant = "${try(upper(assignment.principal_type), "")} ${assignment.principal} / ${account} / ${ps}"
          block = block
        }
      ] if account != null
    ]
  ])

  // AWS identifies an assignment by principal, account and permission set, so the same
  // grant in two places would be two Terraform resources managing one AWS assignment
  duplicate_assignments = sort([
    for grant, blocks in { for g in local.assignment_grants : g.grant => g.block... } :
    "${grant} (in ${join(", ", distinct(blocks))})" if length(blocks) > 1
  ])
}
