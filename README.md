# terraform-aws-identity-center

Manage AWS IAM Identity Center permission sets and account assignments with Terraform.

This pattern is twinned with [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups).

## Module Inputs
```hcl
module "idc" {
  source              = "aws-samples/identity-center/aws"
  version             = "~> 1.3"
  permission_sets     = "./permission_sets.yml"
  account_assignments = "./account_assignments.yml"
}
```
`permission_sets` and `account_assignments` are defined using yaml templates. These module inputs should point at the yaml file location. Example [permission_sets.yml](./examples/permission_sets.yml) and [account_assignments.yml](./examples/account_assignments.yml).

Each grant (principal, account, permission set) must appear only once across all account assignment blocks. See [duplicate assignments](./docs/duplicate_assignments.md).

### Optional Inputs
```hcl
module "idc" {
  ... 
  policies = "./policies/"
}
```

`policies` is used for inline policies on permission sets. This input should point at a directory of IAM policy json files. Example [policies directory](./examples/policies/). 

### Users and Groups

Users and groups can be created with: [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups). the modules are de-coupled for aws customers using an external identity provider (idp).

If you are using [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups), you can pass its `principal_ids` output instead of using a `depends_on` to link the two modules. 

```hcl
module "idc" {
  ...
  principal_ids = module.idc_users_and_groups.principal_ids
}
```

With `depends_on`, any change to users or groups can replace every account assignment. With `principal_ids`, only assignments for changed principals are affected. Principals not in `principal_ids` are still looked up.

To build it yourself, key on configured names so keys are known at plan time:

```hcl
principal_ids = {
  groups = { for g in aws_identitystore_group.this : g.display_name => g.group_id }
  users  = { for u in aws_identitystore_user.this : u.user_name => u.user_id }
}
```

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
    relay_state      = "https://eu-west-3.console.aws.amazon.com"
  }
}
```
`template_variables` inserts variables into template files. See [permission_sets.yml.tpl](./examples/permission_sets.yml.tpl) and [account_assignments.yml.tpl](./examples/account_assignments.yml.tpl) for examples with the above inputs. See [template files](./docs/template_files.md) for suggestions. 

## Related Resources 

- [AWS IAM Identity User Guide](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- [Terraform Registry: aws-samples/identity-center/aws](https://registry.terraform.io/modules/aws-samples/identity-center/aws/latest)

## Security
See [CONTRIBUTING](./CONTRIBUTING.md) for more information.

## License
This library is licensed under the MIT-0 License. See the LICENSE file.
