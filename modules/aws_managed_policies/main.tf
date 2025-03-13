// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = { for idx, policy in var.name : 
               policy => policy if policy != null 
             }
  
  instance_arn       = var.instance_arn
  permission_set_arn = var.permission_set_arn
  managed_policy_arn = startswith(each.value, "arn:") ? each.value : "arn:aws:iam::aws:policy/${each.value}"
}

