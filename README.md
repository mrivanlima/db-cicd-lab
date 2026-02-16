# SQL Server Database CI/CD Lab

## Overview

This repository demonstrates a production-grade CI/CD pipeline for SQL Server database schema (objects only) across multiple environments:

Dev → QA → Staging → Prod

The solution uses:

- SQL Server (Docker containers)
- SQL Database Project (SSDT)
- State-based deployment model (DACPAC)
- GitHub as source of truth
- Azure DevOps for CI/CD orchestration

---

## Architecture

All environments run locally in Docker:

- Dev
- QA
- Staging
- Prod

Azure DevOps builds the SQL project into a DACPAC and deploys it sequentially through each environment using approval gates.

GitHub stores:
- Database project
- Documentation
- CI/CD configuration
- Standards

---

## Deployment Model

This project uses a **state-based deployment model**.

The SQL Database Project represents the desired final state of the database.

Azure DevOps:
1. Builds the project
2. Generates a DACPAC
3. Compares it against the target database
4. Applies only the necessary schema changes

Safety Controls:
- BlockOnPossibleDataLoss = true
- Explicit constraint naming required
- Pull request validation before merge

---

## Environments

Each environment runs in an isolated Docker container.

Promotion Flow:

Dev → QA → Staging → Prod

No manual script execution is allowed in higher environments.

All schema changes must go through GitHub and Azure DevOps.

---

## Standards

- All constraints must be explicitly named (PK, FK, DF, UQ, CK).
- One object per file.
- No direct changes in QA, Staging, or Prod.
- All deployments are automated.
- No data deployments (schema only).

---

## Future Enhancements

- Drift detection
- Deployment reports
- Automated schema validation
- Rollback strategy
- Secrets management improvements

---

## Purpose

This repository serves as:

- A CI/CD reference implementation
- A professional portfolio artifact
- A reusable database deployment framework


# Architecture Overview

This project implements a fully documented, production-grade SQL Server schema CI/CD system using:

- SSDT (SQL Server Data Tools)
- DACPAC (state-based deployments)
- GitHub (source of truth)
- Azure DevOps (multi-stage pipeline + approvals)
- Self-hosted agent
- Dockerized SQL Server environments

The goal is deterministic, controlled, and auditable schema promotion across:

Dev → QA → Staging → Prod

---

## System Components

### 1. Source Control (GitHub)

GitHub is the **single source of truth**.

The repository contains:

- SQL Database Project (SSDT)
- CI/CD pipeline definition (`azure-pipelines.yml`)
- Docker environment configuration
- Operational documentation
- Governance standards

All schema changes must be committed to GitHub and deployed through the pipeline.

No manual changes are allowed in higher environments.

---

### 2. SQL Database Project (SSDT)

The SSDT project represents the **desired schema state**.

It contains:

- Tables
- Views
- Stored Procedures
- Functions
- Constraints (explicitly named)
- Indexes (explicitly named)

The project is compiled into a **DACPAC** artifact during the Build stage.

---

### 3. Dockerized SQL Environments

All environments run locally in Docker containers:

| Environment | Port  |
|------------|-------|
| Dev        | 14331 |
| QA         | 14332 |
| Staging    | 14333 |
| Prod       | 14334 |

Each container represents an independent SQL Server 2022 instance.

This ensures:

- Isolation
- Environment parity
- Repeatable testing
- No cloud dependency for schema validation

---

### 4. Azure DevOps Pipeline

The CI/CD pipeline is defined in:
 azure-pipelines.yml


It performs:

1. Build SSDT project
2. Generate DACPAC artifact
3. Deploy to Dev (automatic)
4. Deploy to QA (automatic)
5. Deploy to Staging (approval required)
6. Deploy to Prod (approval required)

---

## Deployment Model

This system uses a **state-based deployment model**.

Instead of applying incremental scripts, the pipeline:

1. Compares DACPAC (desired state)
2. Compares target database (current state)
3. Generates deployment plan
4. Applies only necessary changes

Safety controls:

- `BlockOnPossibleDataLoss=True`
- Encrypted connections
- TrustServerCertificate (local Docker only)
- Environment-level approvals

---

## Promotion Flow

Developer Commit
↓
GitHub (Source of Truth)
↓
Azure DevOps Pipeline
↓
Build → DACPAC
↓
Dev (Auto)
↓
QA (Auto)
↓
Staging (Approval Required)
↓
Prod (Approval Required)


---

## Governance Model

Environment control policy:

| Environment | Approval Required |
|------------|------------------|
| Dev        | No |
| QA         | No |
| Staging    | Yes |
| Prod       | Yes |

This ensures:

- Fast developer feedback loop
- Controlled integration validation
- Strict production governance

---

## Security Model

- No passwords stored in GitHub
- Secrets stored in Azure DevOps pipeline variables
- Encrypted SQL connections
- Environment-level access control
- Approval gates for higher environments

---

## Deterministic Deployment Guarantee

This architecture guarantees:

- Repeatable builds
- Predictable deployments
- No schema drift (when rules followed)
- Clean promotion between environments
- Auditable change history

---

## Architectural Principle

> The SSDT project in Git is the authority.  
> The database is a deployed artifact.  
> The pipeline is the enforcement mechanism.


## Why This Matters

### 👨‍💼 Senior DevOps Perspective

This architecture demonstrates a clear understanding of:

- Artifact-based promotion
- Controlled release governance
- Environment isolation
- CI/CD best practices
- Approval-based deployment flow
- Secure secret handling
- Deterministic pipeline execution

It reflects modern DevOps maturity and production-ready deployment discipline.

---

### 👨‍💻 Senior DBA Perspective

This architecture demonstrates a strong understanding of:

- Deterministic schema deployment
- Drift prevention
- Data loss protection (`BlockOnPossibleDataLoss=True`)
- State-based deployment models (DACPAC)
- Controlled environment promotion
- Enterprise-grade release processes

It treats the database as an engineered system, not a manually maintained asset.

# High-Level Architecture Diagram
            +----------------------+
            |   Developer Commit   |
            +----------+-----------+
                       |
                       v
            +----------------------+
            |      GitHub Repo     |
            |  (Source of Truth)   |
            +----------+-----------+
                       |
                       v
            +----------------------+
            | Azure DevOps Pipeline|
            |  Multi-Stage YAML    |
            +----------+-----------+
                       |
            +----------+-----------+
            |                      |
            v                      v
      +------------+         +------------+
      |  Build     |         |  Artifact  |
      |  SSDT      |         |  DACPAC    |
      +------------+         +------------+
                       |
                       v
  +------------+ → +------------+ → +------------+ → +------------+
  |    Dev     |   |    QA      |   |  Staging   |   |    Prod    |
  | (Auto)     |   | (Auto)     |   | (Approval) |   | (Approval) |
  +------------+   +------------+   +------------+   +------------+


---

# Promotion Flow

1. Developer commits schema changes to SSDT project.
2. GitHub triggers Azure DevOps pipeline.
3. SSDT project builds into a DACPAC artifact.
4. The same artifact is promoted through environments.
5. Staging and Prod require manual approval.

---

# Deployment Model

This project uses a **state-based deployment model**.

Instead of executing incremental scripts:

- DACPAC represents desired schema state.
- SqlPackage compares source vs target.
- A deployment plan is generated.
- Only necessary changes are applied.

---

# Safety Controls

All deployments enforce:

- `BlockOnPossibleDataLoss=True`
- Encrypted SQL connections
- Environment-based approvals
- Secret-based credential handling
- Artifact promotion (no rebuild between environments)

---

# Environment Policy

| Environment | Approval Required |
|------------|------------------|
| Dev        | No |
| QA         | No |
| Staging    | Yes |
| Prod       | Yes |

---

# Security Model

- No passwords stored in GitHub
- Secrets stored in Azure DevOps
- TLS-encrypted connections
- Approval gates enforced by environment
- No direct schema edits in higher environments

---

# Drift Prevention Rule

The SSDT project is the single source of truth.

No manual changes are allowed in Staging or Prod.

Schema changes must move through:

Dev → QA → Staging → Prod

---

# Deterministic Deployment Principle

The artifact moves forward.

It is never rebuilt between environments.

Each stage deploys the same DACPAC.

---

## Repository Structure

- `database/` → SSDT project (schema source of truth)
- `infra/` → Docker configuration and environment setup
- `sql/` → Database initialization and bootstrap scripts
- `docs/` → Operational guidelines and governance documentation
- `azure-pipelines.yml` → Multi-stage CI/CD pipeline definition

---

# Professional Objective

This repository demonstrates enterprise-level database DevOps practices including:

- Controlled schema promotion
- Governance enforcement
- Drift avoidance
- Secure pipeline execution
- Artifact-based deployment
- Deterministic release strategy

---

# Core Principle

> The SSDT project in Git is the authority.  
> The database is a deployed artifact.  
> The pipeline is the enforcement mechanism.

Traceability test change



