# terraform-aws-identity-center

Manage AWS IAM Identity Center permission sets and account assignments with Terraform.

This pattern is twinned with [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups).

## Module Inputs
```hcl
module "idc" {
  source              = "aws-samples/identity-center/aws"
  version             = "1.1.0"
  permission_sets     = "./permission_sets.yml"
  account_assignments = "./account_assignments.yml"
}
```
`permission_sets` and `account_assignments` are defined using yaml templates. These module inputs should point at the yaml file location. Example [permission_sets.yml](./examples/permission_sets.yml) and [account_assignments.yml](./examples/account_assignments.yml).

### Optional Inputs
```hcl
module "idc" {
  ... 
  policies = "./policies/"
}
```

`policies` is used for inline policies on permission sets. This input should point at a directory of IAM policy json files. Example [policies directory](./examples/policies/). 

### Template Files

The module accepts template files (`.yml.tpl` or `.yaml.tpl`). These can be inputted alongside regular yaml files.  
```hcl
module "idc" {
  ...
  permission_sets     = "./permission_sets.yml"
  account_assignments = "./account_assignments.yml.tpl"
  template_variables = {
    management       = var.management_account_id
    audit            = var.audit_account_id
    session_duration = "8"
  }
}
```
`template_variables` inserts variables into template files. See [permission_sets.yml.tpl](./examples/permission_sets.yml.tpl) and [account_assignments.yml.tpl](./examples/account_assignments.yml.tpl) for examples with the above inputs. 

See [template files](./examples/template_files.md) for suggestions. 

## Users and groups

This pattern does not setup users and groups. These are typically handled by an external Identity Provider (IdP). If you are not using an IdP and want to create groups in Identity Center, use this pattern: [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups).

## Delegated Administration

This pattern can be used with [delegated administration](https://docs.aws.amazon.com/singlesignon/latest/userguide/delegated-admin.html) in Identity Center. The module would need to be deployed to both the management account and delegated account. 

## Related Resources 

- [AWS IAM Identity User Guide](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- [Terraform Registry: aws-samples/identity-center/aws](https://registry.terraform.io/modules/aws-samples/identity-center/aws/latest)

## Security
See [CONTRIBUTING](./CONTRIBUTING.md) for more information.

## License
This library is licensed under the MIT-0 License. See the LICENSE file.
