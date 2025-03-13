// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_ssoadmin_instances" "this" {}

resource "aws_ssoadmin_permission_set" "this" {
  for_each         = yamldecode(file(var.permission_sets))
  name             = each.key
  description      = each.value.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  tags             = each.value.tags
  session_duration = each.value.session_duration
  relay_state      = lookup(each.value, "relay_state", null)
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = { for ps, values in yamldecode(file(var.permission_sets)) : ps => values if values.inline_policy != null }
  inline_policy      = file("${var.policies}${each.value.inline_policy}.json")
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}

module "aws_managed_policies" {
  source             = "./modules/aws_managed_policies"
  for_each           = { for ps, values in yamldecode(file(var.permission_sets)) : ps => values if values.aws_managed_policies != null }
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  name               = each.value.aws_managed_policies
}

module "customer-managed_policies" {
  source             = "./modules/customer_managed_policies"
  for_each           = ({ for ps, values in yamldecode(file(var.permission_sets)) : ps => values if values.customer_managed_policies != null })
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  name               = each.value.customer_managed_policies
}

module "aws_permissions_boundary" {
  for_each             = { for ps, values in yamldecode(file(var.permission_sets)) : ps => values if values.permissions_boundary != null }
  source               = "./modules/permissions_boundary"
  instance_arn         = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn   = aws_ssoadmin_permission_set.this[each.key].arn
  permissions_boundary = each.value.permissions_boundary
}

module "account_assignment" {
  depends_on = [
    aws_ssoadmin_permission_set.this
  ]
  source             = "./modules/assignments"
  for_each           = yamldecode(file(var.account_assignments))
  principal          = each.value.principal
  principal_type     = each.value.principal_type
  permission_sets    = each.value.permission_sets
  account_assignment = each.value.account_list
  instances_arns     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id  = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}
