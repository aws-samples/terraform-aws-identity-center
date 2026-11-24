// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// Tests for modules/assignments. The AWS provider is mocked.

mock_provider "aws" {
  mock_data "aws_identitystore_group" {
    defaults = { group_id = "00000000-0000-0000-0000-000000000001" }
  }

  mock_data "aws_identitystore_user" {
    defaults = { user_id = "00000000-0000-0000-0000-000000000002" }
  }
}

variables {
  identity_store_id = "d-0000000000"
  instances_arns    = "arn:aws:sso:::instance/ssoins-0000000000000000"
  principal         = "Developers"
  principal_type    = "Group"
  permission_set_arns = {
    Developer = "arn:aws:sso:::permissionSet/ssoins-0000000000000000/ps-0000000000000001"
    ReadOnly  = "arn:aws:sso:::permissionSet/ssoins-0000000000000000/ps-0000000000000002"
  }
  account_assignment = ["012345678901", "112233445566"]
}

run "expands_accounts_by_permission_sets" {
  command = apply

  module {
    source = "./modules/assignments"
  }

  assert {
    condition = toset(keys(aws_ssoadmin_account_assignment.this)) == toset([
      "012345678901-Developer", "012345678901-ReadOnly",
      "112233445566-Developer", "112233445566-ReadOnly",
    ])
    error_message = "Expected one assignment per account and permission set."
  }

  assert {
    condition     = aws_ssoadmin_account_assignment.this["012345678901-Developer"].principal_id == "00000000-0000-0000-0000-000000000001"
    error_message = "Group principal should be looked up from the identity store."
  }

  assert {
    condition     = aws_ssoadmin_account_assignment.this["012345678901-Developer"].principal_type == "GROUP"
    error_message = "principal_type should be normalised to upper case."
  }

  assert {
    condition     = length(data.aws_identitystore_user.this) == 0
    error_message = "User lookup should not run for a group principal."
  }
}

run "user_principal_lowercase" {
  command = apply

  module {
    source = "./modules/assignments"
  }

  variables {
    principal_type = "user"
  }

  assert {
    condition     = aws_ssoadmin_account_assignment.this["012345678901-Developer"].principal_id == "00000000-0000-0000-0000-000000000002"
    error_message = "User principal should be looked up from the identity store."
  }

  assert {
    condition     = aws_ssoadmin_account_assignment.this["012345678901-Developer"].principal_type == "USER"
    error_message = "principal_type should be normalised to upper case."
  }
}

run "invalid_principal_type_fails" {
  command = plan

  module {
    source = "./modules/assignments"
  }

  variables {
    principal_type = "Role"
  }

  expect_failures = [var.principal_type]
}

run "short_account_id_fails" {
  command = plan

  module {
    source = "./modules/assignments"
  }

  // what an unquoted 012345678901 becomes after yamldecode
  variables {
    account_assignment = ["12345678901"]
  }

  expect_failures = [var.account_assignment]
}

run "non_numeric_account_id_fails" {
  command = plan

  module {
    source = "./modules/assignments"
  }

  variables {
    account_assignment = ["management"]
  }

  expect_failures = [var.account_assignment]
}

run "empty_account_list_fails" {
  command = plan

  module {
    source = "./modules/assignments"
  }

  variables {
    account_assignment = []
  }

  expect_failures = [var.account_assignment]
}

run "null_account_entry_fails" {
  command = plan

  module {
    source = "./modules/assignments"
  }

  // what "account_list:\n  - " becomes when a template variable is empty
  variables {
    account_assignment = [null]
  }

  expect_failures = [var.account_assignment]
}
