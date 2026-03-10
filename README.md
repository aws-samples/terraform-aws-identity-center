# terraform-aws-identity-center

Manage AWS IAM Identity Center permission sets and account assignments with Terraform.

This pattern is twinned with [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups).

## Module Inputs
```hcl
module "idc" {
  source              = "aws-samples/identity-center/aws"
  version             = "1.2.2"
  permission_sets     = "./permission_sets.yml"
  account_assignments = "./account_assignments.yml"
}
```
`permission_sets` and `account_assignments` are defined using yaml templates. These module inputs should point at the yaml file location. Example [permission_sets.yml](./examples/permission_sets.yml) and [account_assignments.yml](./examples/account_assignments.yml).

### Optional Inputs
```hcl
module "idc" {
  ... 
  identity_store_id = "d-1234567890" // or tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0] 
  instance_arn      = "arn:aws:sso:::instance/ssoins-112233445566" // or tolist(data.aws_ssoadmin_instances.this.arns)[0] 
  policies          = "./policies/"
}
```

`identity_store_id` is the Identity Center identity store id. [Data Source: aws_ssoadmin_instances](https://registry.terraform.io/providers/hashicorp/awS/latest/docs/data-sources/ssoadmin_instances) can be used to fetch it. This optional input will likely become mandatory in a future build as it reduces unecessary resource refreshes.

`instance_arn" is the Identity Center instance arn. [Data Source: aws_ssoadmin_instances](https://registry.terraform.io/providers/hashicorp/awS/latest/docs/data-sources/ssoadmin_instances) can be used to fetch it. This optional input will likely become mandatory in a future build as it reduces unecessary resource refreshes.


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
`template_variables` inserts variables into template files. See [permission_sets.yml.tpl](./examples/permission_sets.yml.tpl) and [account_assignments.yml.tpl](./examples/account_assignments.yml.tpl) for examples with the above inputs. See [template files](./docs/template_files.md) for suggestions. 

## Users and groups

Users and groups can be created with: [terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups). The modules are de-coupled for AWS customers using an external Identity Provider (IdP).

## Related Resources 

- [AWS IAM Identity User Guide](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- [Terraform Registry: aws-samples/identity-center/aws](https://registry.terraform.io/modules/aws-samples/identity-center/aws/latest)

## Security
See [CONTRIBUTING](./CONTRIBUTING.md) for more information.

## License
This library is licensed under the MIT-0 License. See the LICENSE file.
