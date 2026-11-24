// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "policy_names" {
  value = keys(aws_ssoadmin_customer_managed_policy_attachment.this)
}
