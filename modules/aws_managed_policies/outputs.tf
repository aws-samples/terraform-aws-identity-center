// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "policy_arns" {
  value = [for attachment in aws_ssoadmin_managed_policy_attachment.this : attachment.managed_policy_arn]
}
