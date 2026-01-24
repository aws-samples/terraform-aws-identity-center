// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "account_assignments" {
  type        = string
  description = "Path to YAML file containing account assignments"

  validation {
    condition     = can(regex("\\.(yml|yaml)$", var.account_assignments))
    error_message = "Account assignments file must have .yml or .yaml extension."
  }
}

variable "permission_sets" {
  type        = string
  description = "Path to YAML file containing permission sets"

  validation {
    condition     = can(regex("\\.(yml|yaml)$", var.permission_sets))
    error_message = "Permission sets file must have .yml or .yaml extension."
  }
}

// optional

variable "policies" {
  type        = string
  default     = "./policies/"
  description = "Path to directory containing inline policy JSON files"
}
