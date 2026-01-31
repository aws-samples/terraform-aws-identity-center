# Template files

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

### Lookup Account IDs

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
    account_map = local.account_map
  }
}
```

```yaml
CloudOps:
  principal: CloudOperaations
  principal_type: Group
  permission_sets: 
    - PowerUser
  account_list: 
    - "${account_map["workload1"}" // quotes used to ensure string is kept intact, otherwise leading 0s may be trimmed
    - "${account_map["workload2"}"
```


### Filter by account prefix

```hcl
data "aws_organizations_organization" "current" {}

locals {
  test_accounts = [
    for account in data.aws_organizations_organization.current.accounts :
    account.id if startswith(account.name, "test")
  ]
  test_accounts_yaml = join("\n    - ", local.test_accounts)
}

module "idc" {
  ...
  template_variables = {
    test_accounts = local.test_accounts_yaml
  }
}
```

```yaml
QAT:
  principal: TestingTeam
  principal_type: Group
  permission_sets:
    - Developer
    - ReadOnly
  account_list:
    - ${test_accounts}
```

### Tag-based account access

```hcl
data "aws_organizations_organization" "current" {}

locals {
  sandbox_accounts = [
    for account in data.aws_organizations_organization.current.accounts :
    account.id if try([for tag in account.tags : tag.value if tag.key == "Env"][0], "") == "Sandbox"
  ]
  sandbox_accounts_yaml = join("\n    - ", local.sandbox_accounts)
}

module "idc" {
  ...
  account_assignments = "./account_assignments.yml.tpl"
  template_variables = {
    sandbox_accounts = local.sandbox_accounts_yaml
  }
}
```

```yaml
DeveloperSandboxAccess:
  principal: Developers
  principal_type: Group
  permission_sets:
    - Developer
  account_list:
    - ${sandbox_accounts}
```
