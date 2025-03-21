# terraform-aws-identity-center

Manage AWS IAM Identity Center permission sets and account assignments with Terraform.

This pattern is twinned with [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups).

## Module Inputs
```hcl
module "idc" {
  source              = "aws-samples/identity-center-users-and-groups/aws"
  version             = "1.0.0"
  permission_sets     = "./permission_sets.yml"
  account_assignments = "./account_assignments.yml"
}
```
`permission_sets` and `account_assignments` are defined using yaml templates. These module inputs should point at the yaml file location. Example [permission_sets.yml](./examples/permission_sets.yml) and [account_assignments.yml](./examples/account_assignments.yml).

## Optional Inputs
```hcl
module "idc" {
  ... 
  policies = "./policies/"
}
```

`policies` is used for inline policies on permission sets. This input should point at a directory of IAM policy json files. Example [policies directory](./examples/policies/). 

## Users and groups

This pattern does not setup users and groups. These are typically handled by an external Identity Provider (IdP). 

If you are not using an IdP and want to create groups in Identity Center, use this pattern: [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups).


We have deliberately segregated the two patterns:
- You may be using an external IdP
- You may be planning to use an external IdP and want to build a pattern that can be de-coupled in the future
- At scale, any explicit or implicit dependencies (`depends_on`) between account assignments and group membership can have unintended consequences.
  - Example: with a dependency, adding a user to a group can cause terraform to refresh all account assignments that feature that group (into the 100s or 1000s depending on the scale of your AWS Organization).

## Delegation

This pattern can be used with [delegated administration](https://docs.aws.amazon.com/singlesignon/latest/userguide/delegated-admin.html) in Identity Center. Separate instances of the pattern would need to be deployed to the management account and delegated account. 

## Related Resources 

- [AWS IAM Identity User Guide](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- [Terraform Registry](https://registry.terraform.io/modules/aws-samples/identity-center/aws/latest)

## Security
See [CONTRIBUTING](./CONTRIBUTING.md) for more information.

## License
This library is licensed under the MIT-0 License. See the LICENSE file.
