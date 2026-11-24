// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// keys are "<account>-<permission set>"
output "assignments" {
  value = keys(aws_ssoadmin_account_assignment.this)
}
