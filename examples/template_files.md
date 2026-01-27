# template files

The module accepts template files (`.yml.tpl` or `.yaml.tpl`). These can be inputted alongside regular yaml files.  


## Basic templating 

```hcl
module "idc" {
  ...
  template_variables = {
    management    = var.management_account_id
  }
}
```

`template_variables` inserts variables into template files. 

We can make basic substitutions, like using account names rather than hardcoded account IDs in permission sets: 

```yaml
Admin:
  principal: Admin
  principal_type: Group
  permission_sets: 
    - Admin
    - ReadOnly 
  account_list: 
    - ${management}
```

## Advanced templating

### Account name to account ID mapping

Use locals and a data source to map account names to account IDs. 


```hcl
data "aws_organizations_organization" "current" {}

locals {
  account_map = {
    for account in data.aws_organizations_organization.current.accounts :
    account.name => account.id
  }
}

module "idc" {
  ...
  template_variables = {
    development = local.account_map["Development"]
    test        = local.account_map["Test"]
    production  = local.account_map["Production"]
  }
}
```

```yaml
Admin:
  principal: Admin
  principal_type: Group
  permission_sets: 
    - Admin
  account_list: 
    - ${production}
```

The lookup can also be done from within the template file. 

```hcl
data "aws_organizations_organization" "current" {}

locals {
  account_map = {
    for account in data.aws_organizations_organization.current.accounts :
    account.name => account.id
  }
}

module "idc" {
  ...
  template_variables = {
    account_map = jsonencode(local.account_map)
  }
}
```

```yaml
Admin:
  principal: Admin
  principal_type: Group
  permission_sets: 
    - Admin
  account_list: 
    - ${lookup(jsondecode(account_map), "development")}
    - ${lookup(jsondecode(account_map), "test")}
```

### Filter by account prefix

Use Terraform loops to automatically populate account lists based on account name patterns.

```hcl
data "aws_organizations_organization" "current" {}

locals {
  development_accounts = [
    for account in data.aws_organizations_organization.current.accounts :
    account.id if startswith(account.name, "development")
  ]
  
  development_accounts_yaml = join("\n    - ", local.development_accounts)
}

module "idc" {
  ...
  template_variables = {
    development_accounts = local.development_accounts_yaml
  }
}
```

```yaml
DevelopmentTeam:
  principal: DevelopmentTeam
  principal_type: Group
  permission_sets:
    - Developer
    - ReadOnly
  account_list:
    - ${development_accounts}
```

### Tag-based account access

Use account tags in account assignments. 

```hcl
data "aws_organizations_organization" "current" {}

locals {
  # Filter accounts by AccessLevel tag
  admin_accounts = [
    for account in data.aws_organizations_organization.current.accounts :
    account.id if try([for tag in account.tags : tag.value if tag.key == "AccessLevel"][0], "") == "admin"
  ]
  
  developer_accounts = [
    for account in data.aws_organizations_organization.current.accounts :
    account.id if try([for tag in account.tags : tag.value if tag.key == "AccessLevel"][0], "") == "developer"
  ]
}

module "idc" {
  ...
  account_assignments = "./account_assignments.yml.tpl"
  template_variables = {
    admin_accounts = join("\n    - ", local.admin_accounts)
    developer_accounts = join("\n    - ", local.developer_accounts)
  }
}
```

```yaml
AdminAccess:
  principal: Admins
  principal_type: Group
  permission_sets:
    - Admin
  account_list:
    - ${admin_accounts}

DeveloperAccess:
  principal: Developers
  principal_type: Group
  permission_sets:
    - Developer
  account_list:
    - ${developer_accounts}
```
