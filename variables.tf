// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "account_assignments" {
  type = string
}

variable "permission_sets" {
  type = string
}

// optional

variable "policies" {
  type    = string
  default = "./policies/"
}

variable "template_variables" {
  description = "Variables to substitute in yaml templates (.yml.tpl and .yaml.tpl files)"
  type        = map(any)
  default     = {}
}
