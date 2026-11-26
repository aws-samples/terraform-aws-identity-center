// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// principal_ids from resources in the same apply. The AWS provider is mocked.

mock_provider "aws" {
  mock_data "aws_ssoadmin_instances" {
    defaults = {
      arns               = ["arn:aws:sso:::instance/ssoins-0000000000000000"]
      identity_store_ids = ["d-0000000000"]
    }
  }

  mock_data "aws_partition" {
    defaults = { partition = "aws" }
  }

  // same IDs as the lookups, so switching keeps principal_id unchanged
  mock_data "aws_identitystore_group" {
    defaults = { group_id = "00000000-0000-0000-0000-000000000001" }
  }

  mock_data "aws_identitystore_user" {
    defaults = { user_id = "00000000-0000-0000-0000-000000000002" }
  }

  mock_resource "aws_identitystore_group" {
    defaults = { group_id = "00000000-0000-0000-0000-000000000001" }
  }

  mock_resource "aws_identitystore_user" {
    defaults = { user_id = "00000000-0000-0000-0000-000000000002" }
  }

  mock_resource "aws_ssoadmin_permission_set" {
    defaults = { arn = "arn:aws:sso:::permissionSet/ssoins-0000000000000000/ps-0000000000000000" }
  }
}

// IDs are unknown at plan time; the plan must still succeed
run "plan_with_unknown_ids" {
  command = plan

  module {
    source = "./tests/setup/users_and_groups"
  }
}

// existing deployment using lookups
run "apply_with_lookups" {
  command = apply

  module {
    source = "./tests/setup/users_and_groups"
  }

  variables {
    pass_ids = false
  }
}

// switching to passed IDs leaves assignments unchanged
run "switch_to_ids" {
  command = apply

  module {
    source = "./tests/setup/users_and_groups"
  }
}

// an unrelated new group leaves assignments untouched
run "unrelated_group_added" {
  command = plan

  module {
    source = "./tests/setup/users_and_groups"
  }

  variables {
    extra_groups = ["NewTeam"]
  }
}
