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
