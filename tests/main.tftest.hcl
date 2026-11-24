// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// Root module tests. The AWS provider is mocked, so no credentials or AWS
// account are needed and nothing is created.

mock_provider "aws" {
  override_data {
    target = data.aws_ssoadmin_instances.this
    values = {
      arns               = ["arn:aws:sso:::instance/ssoins-0000000000000000"]
      identity_store_ids = ["d-0000000000"]
    }
  }

  // random mock values fail the provider's own ID/ARN validation
  mock_data "aws_partition" {
    defaults = { partition = "aws" }
  }

  mock_data "aws_identitystore_group" {
    defaults = { group_id = "00000000-0000-0000-0000-000000000001" }
  }

  mock_data "aws_identitystore_user" {
    defaults = { user_id = "00000000-0000-0000-0000-000000000002" }
  }

  mock_resource "aws_ssoadmin_permission_set" {
    defaults = { arn = "arn:aws:sso:::permissionSet/ssoins-0000000000000000/ps-0000000000000000" }
  }
}

run "examples" {
  command = apply

  variables {
    permission_sets     = "./examples/permission_sets.yml"
    account_assignments = "./examples/account_assignments.yml"
    policies            = "./examples/policies/"
  }

  assert {
    condition     = length(aws_ssoadmin_permission_set.this) == 4
    error_message = "Expected 4 permission sets from examples/permission_sets.yml."
  }

  assert {
    condition     = aws_ssoadmin_permission_set.this["Admin"].session_duration == "PT8H"
    error_message = "Admin session_duration not passed through."
  }

  assert {
    condition     = toset(keys(aws_ssoadmin_permission_set_inline_policy.this)) == toset(["ReadOnly"])
    error_message = "Only ReadOnly should have an inline policy."
  }

  assert {
    condition     = toset(keys(module.aws_permissions_boundary)) == toset(["ReadOnly", "SecurityAdmin"])
    error_message = "Permissions boundaries should only be attached to ReadOnly and SecurityAdmin."
  }

  assert {
    condition     = length(module.account_assignment) == 4
    error_message = "Expected 4 account assignment blocks."
  }
}

run "minimal_yaml_uses_defaults" {
  command = apply

  variables {
    permission_sets     = "./tests/fixtures/minimal_permission_sets.yml"
    account_assignments = "./tests/fixtures/minimal_account_assignments.yml"
    policies            = "./tests/fixtures/policies/"
  }

  assert {
    condition     = aws_ssoadmin_permission_set.this["Developer"].description == null && aws_ssoadmin_permission_set.this["Developer"].relay_state == null
    error_message = "Omitted keys should default to null."
  }

  assert {
    condition     = toset(keys(module.aws_managed_policies)) == toset(["Developer"])
    error_message = "Only Developer has AWS managed policies."
  }

  assert {
    condition     = length(module.customer-managed_policies) == 0 && length(module.aws_permissions_boundary) == 0
    error_message = "No customer managed policies or boundaries were defined."
  }

  assert {
    condition     = jsondecode(aws_ssoadmin_permission_set_inline_policy.this["Inline"].inline_policy).Statement[0].Action == "sts:GetCallerIdentity"
    error_message = "Inline policy should be read from tests/fixtures/policies/Test.json."
  }
}

run "policies_path_without_trailing_slash" {
  command = plan

  variables {
    permission_sets     = "./tests/fixtures/minimal_permission_sets.yml"
    account_assignments = "./tests/fixtures/minimal_account_assignments.yml"
    policies            = "./tests/fixtures/policies"
  }

  assert {
    condition     = length(aws_ssoadmin_permission_set_inline_policy.this) == 1
    error_message = "policies should work without a trailing slash."
  }
}

run "templates_with_mixed_variable_types" {
  command = apply

  variables {
    permission_sets     = "./tests/fixtures/template_permission_sets.yml.tpl"
    account_assignments = "./tests/fixtures/template_account_assignments.yml.tpl"
    template_variables = {
      relay_state       = "https://eu-west-2.console.aws.amazon.com"
      session_duration  = 4
      account_map       = { management = "012345678901" }
      workload_accounts = jsonencode(["023456789012", "112233445566"])
    }
  }

  assert {
    condition     = aws_ssoadmin_permission_set.this["Admin"].session_duration == "PT4H"
    error_message = "session_duration not substituted."
  }

  assert {
    condition     = aws_ssoadmin_permission_set.this["Admin"].relay_state == "https://eu-west-2.console.aws.amazon.com"
    error_message = "relay_state not substituted."
  }

  assert {
    condition     = toset(keys(module.account_assignment)) == toset(["Admin", "Workloads"])
    error_message = "Both templated assignment blocks should be created."
  }
}

run "undefined_permission_set_fails" {
  command = plan

  variables {
    permission_sets     = "./tests/fixtures/minimal_permission_sets.yml"
    account_assignments = "./tests/fixtures/undefined_account_assignments.yml"
    policies            = "./tests/fixtures/policies/"
  }

  expect_failures = [data.aws_ssoadmin_instances.this]
}
