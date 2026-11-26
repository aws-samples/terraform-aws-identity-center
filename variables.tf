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
  type        = any
  default     = {}
}

variable "principal_ids" {
  description = "Group and user IDs by name, e.g. the users and groups module's principal_ids output. Others are looked up by name."
  type = object({
    groups = optional(map(string), {})
    users  = optional(map(string), {})
  })
  default = {}
}
