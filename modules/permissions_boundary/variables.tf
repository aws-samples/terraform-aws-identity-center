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
}
