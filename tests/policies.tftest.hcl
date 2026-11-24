// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// Tests for the policy and permissions boundary child modules. The AWS
// provider is mocked.

mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = { partition = "aws-us-gov" }
  }
}

variables {
  instance_arn       = "arn:aws:sso:::instance/ssoins-0000000000000000"
  permission_set_arn = "arn:aws:sso:::permissionSet/ssoins-0000000000000000/ps-0000000000000001"
}

run "aws_managed_policies_use_partition" {
  command = apply

  module {
    source = "./modules/aws_managed_policies"
  }

  variables {
    name = ["ReadOnlyAccess", "job-function/ViewOnlyAccess"]
  }

  assert {
    condition     = aws_ssoadmin_managed_policy_attachment.this["ReadOnlyAccess"].managed_policy_arn == "arn:aws-us-gov:iam::aws:policy/ReadOnlyAccess"
    error_message = "Managed policy ARN should use the current partition."
  }

  assert {
    condition     = aws_ssoadmin_managed_policy_attachment.this["job-function/ViewOnlyAccess"].managed_policy_arn == "arn:aws-us-gov:iam::aws:policy/job-function/ViewOnlyAccess"
    error_message = "Managed policies with a path should keep the path."
  }
}

run "customer_managed_policies" {
  command = apply

  module {
    source = "./modules/customer_managed_policies"
  }

  variables {
    name = ["PolicyA", "PolicyB"]
  }

  assert {
    condition     = toset(keys(aws_ssoadmin_customer_managed_policy_attachment.this)) == toset(["PolicyA", "PolicyB"])
    error_message = "Expected one attachment per customer managed policy."
  }
}

run "aws_managed_boundary" {
  command = apply

  module {
    source = "./modules/permissions_boundary"
  }

  variables {
    permissions_boundary = { aws_managed_policy = "ReadOnlyAccess" }
  }

  assert {
    condition     = length(aws_ssoadmin_permissions_boundary_attachment.managed) == 1 && length(aws_ssoadmin_permissions_boundary_attachment.custom) == 0
    error_message = "Only the AWS managed boundary should be created."
  }

  assert {
    condition     = aws_ssoadmin_permissions_boundary_attachment.managed[0].permissions_boundary[0].managed_policy_arn == "arn:aws-us-gov:iam::aws:policy/ReadOnlyAccess"
    error_message = "Boundary ARN should use the current partition."
  }
}

run "customer_managed_boundary" {
  command = apply

  module {
    source = "./modules/permissions_boundary"
  }

  variables {
    permissions_boundary = { customer_managed_policy = "Boundary" }
  }

  assert {
    condition     = length(aws_ssoadmin_permissions_boundary_attachment.custom) == 1 && length(aws_ssoadmin_permissions_boundary_attachment.managed) == 0
    error_message = "Only the customer managed boundary should be created."
  }

  assert {
    condition     = aws_ssoadmin_permissions_boundary_attachment.custom[0].permissions_boundary[0].customer_managed_policy_reference[0].name == "Boundary"
    error_message = "Customer managed boundary name not passed through."
  }
}

run "boundary_with_two_keys_fails" {
  command = plan

  module {
    source = "./modules/permissions_boundary"
  }

  variables {
    permissions_boundary = { aws_managed_policy = "ReadOnlyAccess", customer_managed_policy = "Boundary" }
  }

  expect_failures = [var.permissions_boundary]
}

run "boundary_with_unknown_key_fails" {
  command = plan

  module {
    source = "./modules/permissions_boundary"
  }

  variables {
    permissions_boundary = { managed_policy = "ReadOnlyAccess" }
  }

  expect_failures = [var.permissions_boundary]
}
