// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "account_assignments" {
  type        = string
  description = "Path to YAML file containing account assignments"
}

variable "permission_sets" {
  type        = string
  description = "Path to YAML file containing permission sets"
}

// optional

variable "policies" {
  type        = string
  default     = "./policies/"
  description = "Path to directory containing inline policy JSON files"
}
