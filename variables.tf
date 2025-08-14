// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "permission_sets" {
  type = string
}

variable "account_assignments" {
  type = string
}

// optional

variable "policies" {
  type    = string
  default = "./policies/"
}
