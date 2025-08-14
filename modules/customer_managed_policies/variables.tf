// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "instance_arn" {
  description = ""
  type        = string
}

variable "name" {
  type = list(string)
}

variable "permission_set_arn" {
  description = ""
  type        = string
}
