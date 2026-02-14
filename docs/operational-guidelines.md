# Operational Guidelines (SQL Server DACPAC CI/CD)

This project uses **SSDT + DACPAC** (state-based deployments) promoted through:
Dev → QA → Staging → Prod (Docker containers locally), with approvals on Staging/Prod.

## 1) State-based model (how it works)
- The SSDT project represents the **desired schema state**.
- The pipeline builds a **DACPAC** from SSDT.
- `SqlPackage /Action:Publish` compares:
  - Source (DACPAC desired state)
  - Target (existing database)
- It generates and executes a deployment plan to make the target match the DACPAC.

### Safety control
- Deployments use: `BlockOnPossibleDataLoss=True`
- This blocks changes that would likely cause data loss (e.g., drop table/column).

## 2) Environment promotion rules
- **Dev**: automatic deployments
- **QA**: automatic deployments (developer-friendly)
- **Staging**: requires approval
- **Prod**: requires approval

## 3) Renames (do NOT break history)
### Golden rule
DACPAC is state-based, so **renames can look like DROP + CREATE** unless explicitly handled.

### Recommended approach
Use `sp_rename` in a **Pre-Deployment** script when renaming:
- tables
- columns
- constraints
- indexes

#### Example: rename a column
```sql
EXEC sp_rename 'dbo.Customer.OldColumnName', 'NewColumnName', 'COLUMN';
```

#### Example: rename an index
```sql
EXEC sp_rename 'dbo.Customer.IX_OldIndexName', 'IX_NewIndexName', 'INDEX';
```
Keep renames in pre-deploy scripts so the deployment engine understands the object is the same, not a drop/create.

## 4) Drift avoidance (single source of truth)

### Rule
**Never** apply schema changes directly in the Docker SQL containers using SSMS, Azure Data Studio, or `sqlcmd`.

All schema changes must:
1. Be made in the **SSDT project**
2. Be committed to **GitHub**
3. Be deployed through the **CI/CD pipeline**

### Why this matters

Direct manual changes create **schema drift**.

Schema drift means:
- The database no longer matches the SSDT project
- The next DACPAC deployment may:
  - Fail
  - Attempt unintended drops
  - Generate unexpected deployment plans

### How to prevent drift

- Disable direct access to higher environments (recommended in real systems)
- Enforce code reviews for schema changes
- Periodically generate a schema comparison report (optional enhancement)

### Professional rule

> The SSDT project is the **single source of truth**.  
> The database is a deployed artifact, not the design authority.

---

## 5) Rollback strategy (schema rollbacks)

DACPAC deployments are **forward-only by design**.

Rollback is handled through **Git version control**, not manual database scripts.

### Standard rollback procedure

1. Identify the last known-good commit in Git.
2. Revert or checkout that commit.
3. Rebuild the DACPAC from that commit.
4. Redeploy through the pipeline.

### Important considerations

- `BlockOnPossibleDataLoss=True` prevents destructive changes.
- If a destructive change was intentionally approved, rollback may require:
  - A controlled migration plan
  - Restoring from backup (in real production systems)

### Enterprise principle

> Rollback is a version control operation, not a manual database fix.

---

## 6) Pre/Post deployment scripts

### When to use Pre-Deployment scripts

Use Pre-Deployment scripts for:

- Object renames (`sp_rename`)
- Data transformations
- Feature toggles
- Controlled structural adjustments
- Operations DACPAC cannot infer safely

### When to use Post-Deployment scripts

Use Post-Deployment scripts for:

- Seed reference data (if ever allowed)
- Validation checks
- Metadata stamping
- Permission adjustments

### Best practices

- Keep scripts **small**
- Keep them **reviewable**
- Make them **idempotent** where possible
- Avoid embedding large migration logic inside DACPAC

### Example: idempotent pattern

```sql
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE name = 'NewColumn' 
               AND object_id = OBJECT_ID('dbo.Customer'))
BEGIN
    ALTER TABLE dbo.Customer ADD NewColumn INT NULL;
END;

## 7) Constraint naming policy (required)

All database constraints **must be explicitly named**.

Auto-generated constraint names are not allowed.

### Why explicit naming is mandatory

If constraints are not named:

- SQL Server generates random names
- Names differ across environments
- DACPAC deployments may attempt unnecessary drops/recreates
- Schema comparisons become noisy
- Drift becomes harder to detect
- Rollbacks become unpredictable

Explicit naming ensures:

- Deterministic deployments
- Clean diffs
- Professional schema structure
- Repeatable builds

---

### Naming standards

| Constraint Type | Naming Pattern |
|-----------------|---------------|
| Primary Key     | `PK_<Table>` |
| Foreign Key     | `FK_<ChildTable>_<ParentTable>_<Column>` |
| Unique          | `UQ_<Table>_<Column>` |
| Check           | `CK_<Table>_<RuleDescription>` |
| Default         | `DF_<Table>_<Column>` |
| Index           | `IX_<Table>_<Column>` |

---

### Examples

#### Primary Key
```sql
CONSTRAINT PK_Customer 
PRIMARY KEY (CustomerId)
```
```sql
CONSTRAINT FK_Order_Customer_CustomerId
FOREIGN KEY (CustomerId)
REFERENCES dbo.Customer(CustomerId);
```

```sql
CONSTRAINT UQ_Customer_Email
UNIQUE (Email);
```

```sql
CONSTRAINT CK_Order_Amount_Positive
CHECK (Amount > 0);
```

```sql
CONSTRAINT DF_Order_CreatedDate
DEFAULT (GETDATE()) FOR CreatedDate;
```

```sql
CREATE INDEX IX_Order_CustomerId
ON dbo.[Order] (CustomerId);
```

## Professional DBA Rule

> If a constraint does not have an explicit name, it does not belong in this project.

Every schema object must be:

- Intentionally designed
- Explicitly named
- Version-controlled
- Deployable through CI/CD
- Deterministic across environments

There are no “temporary” shortcuts in production-grade systems.

---

## CI/CD Impact

Explicit constraint naming directly affects deployment stability.

Without explicit names:

- SQL Server generates random system names
- Names differ between environments
- DACPAC may attempt to drop and recreate objects unnecessarily
- Deployment plans become noisy
- Drift becomes difficult to detect
- Rollbacks become unpredictable

With explicit naming:

- Schema comparisons are clean
- Deployment plans are predictable
- Promotions between environments are stable
- Diff noise is minimized
- Releases are auditable

---

## Deterministic Deployment Principle

This CI/CD pipeline is built on one critical concept:

> A database deployment must produce the same result every time, in every environment.

That requires:

- Explicit constraint names
- Stable index names
- Stable object definitions
- No environment-specific randomness
- No manual hotfix changes

---

## Governance Standard

All schema changes must:

1. Be implemented in the SSDT project
2. Follow naming conventions
3. Be reviewed via pull request
4. Be deployed through the pipeline
5. Never be manually applied to Staging or Prod

---

## Architectural Philosophy

This repository treats:

- The SSDT project as the **design authority**
- The DACPAC as the **deployment artifact**
- The pipeline as the **control system**
- The database instance as the **runtime artifact**

Databases are not edited directly.
They are deployed.

---

---

## 8) Breaking Change Management Policy

Schema changes are classified into three categories:

### Level 1 – Non-Breaking Changes
Examples:
- Adding nullable columns
- Adding new tables
- Adding indexes
- Adding new stored procedures

Deployment:
- Allowed through normal pipeline flow.

---

### Level 2 – Potentially Breaking Changes
Examples:
- Changing column data type (compatible widening only)
- Adding NOT NULL constraints with defaults
- Modifying constraint logic
- Dropping unused indexes

Deployment:
- Requires review in Pull Request.
- Must be validated in Dev and QA.
- Approval required before Staging.

---

### Level 3 – Destructive Changes (High Risk)
Examples:
- Dropping tables
- Dropping columns
- Changing data types in a non-compatible way
- Renaming without migration plan
- Removing constraints protecting business rules

Deployment Requirements:
- Formal review required.
- Migration plan documented.
- Verified backup before deployment.
- Explicit approval in Staging and Prod.
- Must pass `BlockOnPossibleDataLoss=True`.

If a change cannot safely pass the pipeline controls, it is not production-ready.

---

## 9) Deployment Approval Checklist (Staging & Production)

Before approving a deployment to Staging or Prod, the approver must confirm:

- The build succeeded without warnings.
- QA validation completed successfully.
- No manual changes were made directly to the environment.
- No drift exists between source and target.
- Destructive changes (if any) are documented and approved.
- Rollback plan is defined.
- Backup is verified (Production only).

Approval is not a formality. It is a governance checkpoint.

---

## 10) Backup & Recovery Policy

No Production schema deployment may occur without:

1. Verified recent backup.
2. Confirmed restore test (periodic).
3. Defined rollback procedure.

### Backup Requirements

- Full database backup prior to destructive changes.
- Backup retention policy defined externally.
- Backup validation performed regularly.

### Emergency Recovery Procedure

If a deployment introduces instability:

1. Stop further promotions.
2. Identify last known good commit.
3. Redeploy prior DACPAC version OR restore backup.
4. Document incident.
5. Review root cause.

Schema rollback is not improvisation.
It is a controlled recovery operation.

---

## 11) Change Governance Model

All schema changes must:

- Be submitted via Pull Request.
- Include description of change impact.
- Identify change classification level.
- Include migration notes (if applicable).
- Be reviewed by at least one qualified approver.

No direct production modifications are permitted.

---

## 12) Production Integrity Rule

Production is not a development environment.

- No hotfixes directly in SSMS.
- No emergency manual ALTER statements.
- No undocumented changes.

All changes must move through:

Dev → QA → Staging → Prod

---

## Enterprise Deployment Principle

> Safety is enforced by process, not by memory.

The pipeline enforces control.
The documentation defines responsibility.
The approvals ensure accountability.


## Final Principle

> Databases are engineered systems, not manually maintained assets.

If a change cannot safely move through Dev → QA → Staging → Prod using this pipeline,
then the change is not production-ready.








