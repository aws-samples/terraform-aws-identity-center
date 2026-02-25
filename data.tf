// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_identitystore_group" "assignment_groups" {
  for_each = { for assignment in local.account_assignments : assignment.principal => assignment if upper(assignment.principal_type) == "GROUP" }

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.key
    }
  }
}

data "aws_identitystore_user" "assignment_users" {
  for_each = { for assignment in local.account_assignments : assignment.principal => assignment if upper(assignment.principal_type) == "USER" }

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}
