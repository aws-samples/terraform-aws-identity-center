# Duplicate account assignments

Each grant (principal, account, permission set) must appear only once across all blocks in your account assignments file. The module fails the plan if a grant is repeated:

```
Account assignments grant the same principal, account and permission set more than once.
Remove the duplicates so each grant appears once: GROUP Admin / 112233445566 / ReadOnly (in AdminLZ, ReadOnlyLZ).
```

## Why

AWS identifies an account assignment by its principal, account and permission set. The module creates one Terraform resource per grant per block, so a repeated grant becomes two Terraform resources managing one AWS assignment. That causes two problems:

- The second resource fails to create with `already exists`.
- If both resources end up in state, removing either one deletes the real assignment. The principal loses access until the next apply recreates it.

`principal_type` is compared without case, so `Group` and `GROUP` are the same principal.

## Fixing a duplicate

Remove the grant from all but one block. For example, take `ReadOnly` out of `AdminLZ` when `ReadOnlyLZ` already grants it on the same accounts.

If the module has never been applied with the duplicate, that's all you need to do.

If the assignments already exist, check which copies Terraform is tracking **before** removing anything. Removing a copy that is in state deletes the real assignment.

```sh
terraform state pull > backup.tfstate   # keep a backup before changing state
terraform state list | grep aws_ssoadmin_account_assignment
```

Each copy's address looks like:

```
module.<your module name>.module.account_assignment["<block name>"].aws_ssoadmin_account_assignment.this["<account>-<permission set>"]
```

Then follow the case that matches.

### Only one copy is in state

This is the usual case, because the second copy failed with `already exists`.

- **Keep the block whose copy is in state:** remove the grant from the other block. Nothing changes in AWS.
- **Keep the other block instead:** move the state entry to the block you are keeping, then remove the grant from the block whose copy is in state:

  ```sh
  terraform state mv \
    'module.idc.module.account_assignment["AdminLZ"].aws_ssoadmin_account_assignment.this["112233445566-ReadOnly"]' \
    'module.idc.module.account_assignment["ReadOnlyLZ"].aws_ssoadmin_account_assignment.this["112233445566-ReadOnly"]'
  ```

### Both copies are in state

Tell Terraform to stop tracking the copy you are removing, without deleting it in AWS, then remove the grant from that block:

```sh
terraform state rm \
  'module.idc.module.account_assignment["AdminLZ"].aws_ssoadmin_account_assignment.this["112233445566-ReadOnly"]'
```

### Check before applying

Run `terraform plan`. It should show no changes to `aws_ssoadmin_account_assignment` resources. If it plans to destroy one, stop: that would remove access. Recheck which copies are in state.
