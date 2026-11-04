// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "account_assignment" {
  type = list(string)

  validation {
    condition     = alltrue([for account in var.account_assignment : can(regex("^[0-9]{12}$", account))])
    error_message = "Every account_list entry must be a 12-digit AWS account ID, quoted as a string (got ${jsonencode(var.account_assignment)})."
  }
}

variable "identity_store_id" {
  type = string
}

variable "instances_arns" {
  type = string
}

variable "permission_set_arns" {
  type = map(string)
}

variable "principal" {
  type = string
}

variable "principal_type" {
  type = string

  validation {
    condition     = contains(["USER", "GROUP"], upper(var.principal_type))
    error_message = "principal_type must be \"User\" or \"Group\" (got \"${var.principal_type}\")."
  }
}
