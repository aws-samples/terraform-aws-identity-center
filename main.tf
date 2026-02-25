// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_ssoadmin_instances" "this" {}

resource "aws_ssoadmin_permission_set" "this" {
  for_each         = local.permission_sets
  name             = each.key
  description      = each.value.description
  instance_arn     = local.instance_arn
  tags             = each.value.tags
  session_duration = each.value.session_duration

  lifecycle {
    ignore_changes = [instance_arn]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = { for ps, values in local.permission_sets : ps => values if values.inline_policy != null }
  inline_policy      = file("${var.policies}${each.value.inline_policy}.json")
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn

  lifecycle {
    ignore_changes = [instance_arn]
  }
}

module "aws_managed_policies" {
  source             = "./modules/aws_managed_policies"
  for_each           = { for ps, values in local.permission_sets : ps => values if values.aws_managed_policies != null }
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  name               = each.value.aws_managed_policies
}

module "customer-managed_policies" {
  source             = "./modules/customer_managed_policies"
  for_each           = ({ for ps, values in local.permission_sets : ps => values if values.customer_managed_policies != null })
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  name               = each.value.customer_managed_policies
}

module "aws_permissions_boundary" {
  for_each             = { for ps, values in local.permission_sets : ps => values if values.permissions_boundary != null }
  source               = "./modules/permissions_boundary"
  instance_arn         = local.instance_arn
  permission_set_arn   = aws_ssoadmin_permission_set.this[each.key].arn
  permissions_boundary = each.value.permissions_boundary
}

module "account_assignment" {
  source                = "./modules/assignments"
  for_each              = local.account_assignments
  principal             = each.value.principal
  principal_type        = each.value.principal_type
  permission_set_arns   = { for ps in each.value.permission_sets : ps => aws_ssoadmin_permission_set.this[ps].arn }
  account_assignment    = each.value.account_list
  instances_arns        = local.instance_arn
  identity_store_id     = local.identity_store_id
  resolved_principal_id = upper(each.value.principal_type) == "GROUP" ? data.aws_identitystore_group.assignment_groups[each.value.principal].group_id : data.aws_identitystore_user.assignment_users[each.value.principal].user_id
}

