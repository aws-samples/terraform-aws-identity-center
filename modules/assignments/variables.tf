// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "permission_sets" {
  type = map(string)
}

variable "principal" {
  type = string
}

variable "principal_type" {
  type = string
}

variable "account_assignment" {
  type = list(string)
}

variable "instances_arns" {
  type = string
}

variable "identity_store_id" {
  type = string
}
