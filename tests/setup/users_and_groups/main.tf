// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// Test-only: creates groups and users alongside the module and passes their IDs in.

variable "pass_ids" {
  description = "Pass IDs instead of using lookups."
  type        = bool
  default     = true
}

variable "extra_groups" {
  description = "Extra groups, to simulate an unrelated change."
  type        = list(string)
  default     = []
}

resource "aws_identitystore_group" "this" {
  for_each          = toset(concat(["Developers"], var.extra_groups))
  identity_store_id = "d-0000000000"
  display_name      = each.key
}

resource "aws_identitystore_user" "this" {
  for_each          = toset(["UserA"])
  identity_store_id = "d-0000000000"
  user_name         = each.key
  display_name      = each.key

  name {
    given_name  = "User"
    family_name = "A"
  }
}

module "idc" {
  source = "../../.."

  permission_sets     = "./tests/fixtures/minimal_permission_sets.yml"
  account_assignments = "./tests/fixtures/principal_ids_account_assignments.yml"
  policies            = "./tests/fixtures/policies/"

  // same shape as the users and groups module output
  principal_ids = {
    groups = var.pass_ids ? { for g in aws_identitystore_group.this : g.display_name => g.group_id } : {}
    users  = var.pass_ids ? { for u in aws_identitystore_user.this : u.user_name => u.user_id } : {}
  }
}
