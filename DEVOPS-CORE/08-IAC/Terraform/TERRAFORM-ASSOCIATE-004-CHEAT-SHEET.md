# ⚡ TERRAFORM ASSOCIATE — COMPLETE EXAM CHEAT SHEET (004)

**Exam Details:** 57 Questions · 60 Minutes · 70% to Pass · Multiple Choice

---

## 1. 🏗️ IaC CONCEPTS

### Core Concepts
- **Infrastructure as Code (IaC)** — Manage & provision infrastructure via machine-readable config files instead of manual processes
- **Declarative** — You define WHAT the end state should be; Terraform figures out HOW to get there
- **Imperative** — You define HOW step-by-step (not Terraform's approach)
- **Idempotent** — Running the same config multiple times always produces the same result

### Infrastructure Lifecycle
- **Day 0** — Initial provisioning of brand-new infrastructure
- **Day 1+** — Ongoing changes and maintenance of existing infrastructure
- **Immutable Infra** — Replace resources when changes are needed (Terraform's approach)
- **Mutable Infra** — Update resources in-place (traditional approach)

---

## 2. ⚙️ CORE WORKFLOW COMMANDS

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize directory; download providers & modules |
| `terraform init -upgrade` | Upgrade providers to latest allowed version |
| `terraform init -reconfigure` | Reconfigure backend, ignore existing state |
| `terraform plan` | Preview changes — shows create/change/destroy |
| `terraform plan -out=tfplan` | Save plan to file for deterministic apply |
| `terraform apply` | Execute plan; prompts for approval |
| `terraform apply -auto-approve` | Skip interactive approval (use in CI/CD) |
| `terraform apply tfplan` | Apply a previously saved plan file |
| `terraform apply -replace=ADDR` | Force replacement of a specific resource |
| `terraform destroy` | Destroy ALL managed infrastructure |
| `terraform destroy -target=ADDR` | Destroy only a specific resource |
| `terraform fmt` | Reformat .tf files to canonical HCL style |
| `terraform fmt -check` | Check formatting without changing files |
| `terraform validate` | Check syntax and internal consistency |
| `terraform show` | Display current state or a saved plan |
| `terraform output` | Show all output values |
| `terraform output NAME` | Show a specific output value |
| `terraform refresh` | ⚠️ DEPRECATED → use `-refresh-only` |
| `terraform apply -refresh-only` | Safer replacement for terraform refresh |
| `terraform import ADDR ID` | Import existing resource into state |
| `terraform get` | Download and update child modules |
| `terraform console` | Interactive console for evaluating expressions |
| `terraform graph` | Generate visual dependency graph |
| `terraform providers` | Show providers required by current config |
| `terraform version` | Print current Terraform version |
| `terraform taint` | ⚠️ DEPRECATED — use `-replace` flag instead |

---

## 3. 📝 HCL CONFIGURATION & SYNTAX

### Block Types

| Block | Purpose | Example |
|-------|---------|---------|
| `resource` | Managed infrastructure object | `resource "aws_instance" "web" { ... }` |
| `data` | Read-only data source | `data "aws_ami" "ubuntu" { ... }` |
| `variable` | Input parameters | `variable "region" { default = "us-east-1" }` |
| `output` | Export values | `output "ip" { value = aws_instance.web.public_ip }` |
| `locals` | Local named values | `locals { env = "prod" }` |
| `module` | Call a reusable module | `module "vpc" { source = "./modules/vpc" }` |
| `terraform` | Settings & backend config | `terraform { required_version = ">= 1.0" }` |
| `provider` | Configure a provider plugin | `provider "aws" { region = "us-east-1" }` |

### Meta-Arguments
- `count = N` — Create N copies; use `count.index` to differentiate
- `for_each = map/set` — One resource per item; use `each.key` / `each.value`
- `depends_on = [list]` — Explicit dependency on another resource/module
- `provider = alias` — Use alternate provider config (e.g. multi-region)
- `lifecycle { }` — Control resource creation/destruction behavior

### Lifecycle Options
- `create_before_destroy = true` — Create new before destroying old (zero-downtime)
- `prevent_destroy = true` — Block destroy; Terraform errors if attempted
- `ignore_changes = [list]` — Ignore changes to specified attributes after creation
- `replace_triggered_by = [list]` — Replace resource when referenced value changes

### Variable Types

| Type | Example |
|------|---------|
| `string` | `"hello"` |
| `number` | `42` / `3.14` |
| `bool` | `true` / `false` |
| `list(T)` | `["a", "b", "c"]` |
| `map(T)` | `{ key = "value" }` |
| `set(T)` | Like list but unordered & unique |
| `object()` | Complex structured type with named attributes |
| `tuple()` | Fixed-length sequence with mixed types |
| `any` | Accepts any type — use sparingly |

### Variable Precedence (lowest → highest)
1. Default value in variable block
2. `terraform.tfvars` (auto-loaded)
3. `*.auto.tfvars` (auto-loaded, alphabetical order)
4. `-var-file` flag on command line
5. `-var` flag on command line
6. `TF_VAR_name` environment variables ← **highest**

---

## 4. 💾 STATE MANAGEMENT

### State Files
- `terraform.tfstate` — Default local file storing current infrastructure state
- `terraform.tfstate.backup` — Previous state backup; auto-created before each apply
- **Remote state** — Store state in S3, GCS, or Terraform Cloud — required for teams
- **State locking** — Prevents concurrent modifications; supported by S3+DynamoDB, TF Cloud, GCS
- ⚠️ **Sensitive data warning** — State may contain secrets & passwords — always secure it!

### State Commands

| Command | Purpose |
|---------|---------|
| `terraform state list` | List all resources tracked in state |
| `terraform state show ADDR` | Show details of a specific resource |
| `terraform state mv SRC DST` | Move/rename resource in state without destroying |
| `terraform state rm ADDR` | Remove from state (does NOT destroy real resource) |
| `terraform state pull` | Download and output current remote state |
| `terraform state push` | Upload local state to remote backend (use carefully) |
| `terraform force-unlock ID` | Manually release a stuck state lock |

### Backends

| Backend | Notes |
|---------|-------|
| `local` | Default — state on local disk |
| `s3` | AWS S3; add DynamoDB table for locking |
| `gcs` | Google Cloud Storage |
| `azurerm` | Azure Blob Storage |
| `http` | Generic REST client |
| `Terraform Cloud` | Full locking, history, collaboration |
| `consul` | HashiCorp Consul KV store |

---

## 5. 🔌 PROVIDERS & REGISTRY

### Provider Concepts
- **Provider** — Plugin that lets Terraform interact with external APIs (AWS, Azure, GCP…)
- **Terraform Registry** — `registry.terraform.io` — public source for providers & modules
- **Official provider** — Maintained by HashiCorp; labeled "official" (e.g. `hashicorp/aws`)
- **Partner provider** — Maintained by tech company partner (e.g. `datadog/datadog`)
- **Community provider** — Maintained by community members — use with caution
- `.terraform.lock.hcl` — Records exact provider versions selected; commit to VCS!
- **Provider alias** — Use multiple configs of same provider (e.g. two AWS regions)

### Version Constraint Operators

| Operator | Meaning |
|----------|---------|
| `>= 1.0` | Greater than or equal to 1.0 |
| `<= 1.0` | Less than or equal to 1.0 |
| `~> 1.0` | Allows 1.x but NOT 2.0 (pessimistic constraint) |
| `~> 1.0.4` | Allows 1.0.x but NOT 1.1.0 |
| `!= 1.2.0` | Exclude a specific version |
| `>= 1.0, < 2.0` | Intersection — combine multiple constraints |

---

## 6. 📦 MODULES

### Module Concepts
- **Module** — Container for multiple resources used together as a logical unit
- **Root module** — Your main working directory with .tf files (always exists)
- **Child module** — Any module called/referenced by another module
- **Published module naming** — Must follow: `<NAMESPACE>/<MODULE_NAME>/<PROVIDER>`
- **Module inputs** — Variables passed INTO the module
- **Module outputs** — Values returned FROM the module; access via `module.NAME.OUTPUT`

### Module Sources

| Source Type | Example |
|-------------|---------|
| Local path | `./modules/vpc` |
| Terraform Registry | `hashicorp/consul/aws` |
| GitHub HTTPS | `github.com/hashicorp/example` |
| GitHub SSH | `git@github.com:hashicorp/example.git` |
| Generic Git | `git::https://example.com/vpc.git?ref=v1.2.0` |
| S3 Bucket | `s3::https://s3.amazonaws.com/bucket/vpc.zip` |
| GCS Bucket | `gcs::https://storage.googleapis.com/bucket/vpc.zip` |

---

## 7. ☁️ TERRAFORM CLOUD & ENTERPRISE

### Key Features
- **Terraform Cloud (TFC)** — SaaS for remote state, runs, team collaboration, policy enforcement
- **Terraform Enterprise** — Self-hosted TFC for air-gapped or compliance requirements
- **Workspace** — Isolated environment with its own state, variables, and run history
- **Remote backend** — Stores state in TFC; runs can also execute in TFC infrastructure
- **Sentinel** — Policy-as-code framework (Team & Governance / Plus plan)
- **OPA** — Open Policy Agent — alternative policy enforcement supported by TFC
- **Private Registry** — Host private modules & providers within your TFC organization
- **VCS Integration** — Connect to GitHub/GitLab/Bitbucket; auto-trigger runs on Git push
- **Agent Pools** — Self-hosted runners that execute Terraform runs in your environment
- **Air Gap** — Terraform Enterprise can operate with no internet access
- **Cost Estimation** — Estimate infra cost before applying (TFC feature)
- **SSO** — SAML 2.0 single sign-on (Enterprise)
- **Audit Logging** — Full audit trail of all actions (Enterprise)

---

## 8. 🔧 BUILT-IN FUNCTIONS (KEY ONES)

### String Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `tostring(val)` | Convert to string | `tostring(42)` → `"42"` |
| `format(fmt, args)` | String formatting | `format("Hello, %s!", "World")` |
| `lower/upper(str)` | Change case | `lower("HELLO")` → `"hello"` |
| `trimspace(str)` | Remove whitespace | `trimspace(" hi ")` → `"hi"` |
| `split(sep, str)` | Split into list | `split(",", "a,b")` → `["a","b"]` |
| `join(sep, list)` | Join into string | `join(",", ["a","b"])` → `"a,b"` |
| `replace(str,old,new)` | Replace substring | `replace("a-b", "-", "_")` |
| `substr(str,off,len)` | Extract substring | `substr("hello", 0, 3)` → `"hel"` |

### Collection Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `length(val)` | Count items | `length(["a","b"])` → `2` |
| `flatten(list)` | Flatten nested lists | `flatten([[1,2],[3]])` → `[1,2,3]` |
| `distinct(list)` | Remove duplicates | `distinct([1,1,2])` → `[1,2]` |
| `concat(lists...)` | Combine lists | `concat([1,2],[3,4])` → `[1,2,3,4]` |
| `merge(maps...)` | Merge maps | `merge({a=1},{b=2})` → `{a=1,b=2}` |
| `keys/values(map)` | Extract keys or values | `keys({a=1,b=2})` → `["a","b"]` |
| `lookup(map,key,def)` | Safe map lookup | `lookup(var.m, "k", "default")` |
| `contains(list,val)` | Check if value exists | `contains([1,2,3], 2)` → `true` |
| `element(list,idx)` | Get by index (wraps) | `element(["a","b"], 0)` → `"a"` |
| `toset(list)` | Convert to set | `toset(["a","a","b"])` → `{"a","b"}` |

### Filesystem & Encoding Functions

| Function | Purpose |
|----------|---------|
| `file(path)` | Read file contents as string |
| `templatefile(path, vars)` | Render template file with variables |
| `filebase64(path)` | Read file as base64 string |
| `jsonencode(val)` | Encode value as JSON string |
| `jsondecode(str)` | Decode JSON string to value |
| `base64encode/decode` | Base64 encoding/decoding |

### Type & Logic Functions

| Function | Purpose |
|----------|---------|
| `can(expr)` | Returns true if expression produces no error |
| `try(exprs...)` | Returns first successful expression value |
| `tonumber/tobool/tostring` | Type conversion functions |

### Network Functions

| Function | Purpose |
|----------|---------|
| `cidrsubnet(prefix,newbits,num)` | Calculate subnet CIDR |
| `cidrhost(prefix, hostnum)` | Calculate host IP within CIDR |

---

## 9. 🔄 EXPRESSIONS, LOOPS & DYNAMIC BLOCKS

### Expression Types
- **Conditional (ternary)** — `condition ? true_val : false_val`
- **for (list)** — `[for item in list : upper(item)]`
- **for (map)** — `{for k, v in map : k => upper(v)}`
- **for with filter** — `[for s in var.list : s if s != "skip"]`
- **Splat expression** — `var.list[*].id` (shorthand for extracting attribute from all items)
- **String interpolation** — `"Hello ${var.name}!"`
- **Heredoc** — `<<EOT ... EOT` for multi-line strings
- **dynamic block** — Generate repeated nested blocks using `for_each` inside a block
- **sensitive()** — Mark a value as sensitive to suppress from output
- **nonsensitive()** — Unmark a value previously marked as sensitive

---

## 10. 📍 RESOURCE ADDRESSING & DEPENDENCIES

### Addressing Formats

| Format | Example |
|--------|---------|
| Basic resource | `aws_instance.web` |
| With module | `module.vpc.aws_instance.web` |
| Nested module | `module.parent.module.child.aws_instance.web` |
| With count index | `aws_instance.web[0]` |
| With for_each key | `aws_instance.web["key_name"]` |
| Data source | `data.aws_ami.ubuntu.id` |
| Module output | `module.vpc.subnet_id` |
| Local value | `local.env_name` |
| Variable | `var.region` |
| Self reference | `self.id` (in provisioners/lifecycle) |

### Dependencies
- **Implicit dependency** — Auto-detected via resource attribute references (preferred)
- **Explicit dependency** — `depends_on = [resource]` — use only when no attribute ref exists

---

## 11. 🐛 DEBUGGING, LOGGING & ENV VARIABLES

| Variable | Purpose |
|----------|---------|
| `TF_LOG` | Log level: TRACE, DEBUG, INFO, WARN, ERROR |
| `TF_LOG_PATH` | Write logs to a file instead of stderr |
| `TF_VAR_name` | Set variable value (e.g. `TF_VAR_region=us-east-1`) |
| `TF_CLI_ARGS` | Default CLI arguments for all commands |
| `TF_CLI_ARGS_plan` | Default arguments for terraform plan specifically |
| `TF_INPUT=false` | Disable interactive input prompts |
| `TF_IN_AUTOMATION` | Adjust output for CI/CD contexts |
| `TF_DATA_DIR` | Override .terraform directory location |
| `TF_WORKSPACE` | Set active workspace via env variable |
| `CHECKPOINT_DISABLE` | Disable version check service |

---

## 12. 🗂️ WORKSPACES

### Workspace Commands

| Command | Purpose |
|---------|---------|
| `terraform workspace list` | List all workspaces |
| `terraform workspace new NAME` | Create a new workspace |
| `terraform workspace select NAME` | Switch to a workspace |
| `terraform workspace show` | Show current workspace |
| `terraform workspace delete NAME` | Delete a workspace (can't be active) |

### Workspace Concepts
- **Default workspace** — Always exists; called "default"; cannot be deleted
- **State per workspace** — Each workspace has its own isolated state file
- `terraform.workspace` — Built-in variable containing current workspace name
- **Use case** — Manage dev/staging/prod from one config
- ⚠️ **CLI workspaces ≠ Terraform Cloud workspaces** (TFC workspaces are more feature-rich)

---

## 13. ⚡ PROVISIONERS (LAST RESORT ONLY)

⚠️ **HashiCorp recommends avoiding provisioners** — prefer `user_data`, `cloud-init`, or purpose-built providers.

### Provisioner Types
- `local-exec` — Runs a command on the machine running Terraform
- `remote-exec` — Runs commands on the remote resource via SSH or WinRM
- `file` — Copies files/directories to the remote resource

### Provisioner Options
- `when = destroy` — Provisioner runs only on resource destruction
- `on_failure = continue` — Continue even if provisioner fails
- `on_failure = fail` — Taint resource and fail (default behavior)
- `connection` block — Defines SSH/WinRM connection details

---

## 14. 🔒 SENSITIVE VALUES & SECURITY

### Security Best Practices
- `sensitive = true` — Mark variable or output; Terraform redacts from CLI output
- `sensitive()` function — Mark any value as sensitive programmatically
- **State contains secrets** — State stores ALL values including sensitive ones — secure it!
- **Vault provider** — HashiCorp Vault integration for dynamic secrets
- **Environment variables** — Use `TF_VAR_*` to pass secrets without storing in files

### Always .gitignore These:
```
terraform.tfvars
*.tfstate
*.tfstate.backup
.terraform/
```

### Backend Encryption
- **S3 backend** supports server-side encryption (SSE) at rest

---

## 15. ⚠️ EXAM TRAPS & GOTCHAS

### Deprecated Commands
- ❌ `terraform taint` → ✅ Use `terraform apply -replace=RESOURCE_ADDRESS`
- ❌ `terraform refresh` → ✅ Use `terraform apply -refresh-only`

### Common Pitfalls
- **count vs for_each** — `count` uses index (fragile on delete); `for_each` uses keys (more stable)
- **terraform.tfvars auto-loaded** — also `*.auto.tfvars`; other .tfvars need explicit `-var-file`
- **.terraform.lock.hcl** — Commit to VCS! Ensures consistent provider versions across team
- **~> 3.0** — Allows 3.x but NOT 4.0; `~> 3.0.0` allows 3.0.x only
- **Backend config not in plan** — Plan only shows resource changes, not backend config
- **CLI workspace ≠ TFC workspace** — Conceptually different things
- **Data sources evaluated at plan time** — Not just at apply
- **No partial apply** — Terraform applies all changes; no partial rollback
- **terraform import requires config** — Must have resource block BEFORE importing
- **-target flag** — Not recommended for routine use; use only in emergencies
- **Implicit over explicit deps** — Prefer attribute references; use `depends_on` only when no attribute ref exists

---

## 16. 🎯 EXAM OBJECTIVE WEIGHTINGS

| Domain | Weight |
|--------|--------|
| IaC Concepts | 16% |
| Terraform's Purpose | 9% |
| Terraform Basics | 32% |
| Terraform State | 16% |
| Terraform Cloud | 25% |
| Advanced Concepts | 2% |

---

## 📚 Quick Reference Tips

### Before the Exam
1. ✅ Understand the difference between declarative vs imperative
2. ✅ Know all core workflow commands by heart
3. ✅ Practice with workspaces and remote backends
4. ✅ Understand state management thoroughly
5. ✅ Know when to use `count` vs `for_each`
6. ✅ Memorize variable precedence order
7. ✅ Understand provider versioning constraints
8. ✅ Know the key built-in functions
9. ✅ Practice with modules and module sources
10. ✅ Understand Terraform Cloud features

### During the Exam
- Read questions carefully — look for keywords like "best practice", "recommended", "deprecated"
- Eliminate obviously wrong answers first
- Watch for traps around deprecated commands
- Remember: Terraform is declarative and idempotent
- When in doubt, choose the answer that follows HashiCorp's recommendations

---

**Good luck with your Terraform Associate 004 certification! 🚀**
