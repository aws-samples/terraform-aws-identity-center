// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "instance_arn" {
  type = string
}

variable "permission_set_arn" {
  type = string
}

variable "permissions_boundary" {
  type = map(string)

  validation {
    condition = (
      length(var.permissions_boundary) == 1 &&
      length(setintersection(keys(var.permissions_boundary), ["aws_managed_policy", "customer_managed_policy"])) == 1
    )
    error_message = "permissions_boundary must have exactly one key, either aws_managed_policy or customer_managed_policy (got ${jsonencode(keys(var.permissions_boundary))})."
  }
}
