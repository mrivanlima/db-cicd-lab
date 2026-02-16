DEV (GitHub)
┌───────────────────────────────┐
│ Feature branch (feature/*)     │
└───────────────┬───────────────┘
                │  Open PR → main
                v
PR VALIDATION (Azure DevOps pipeline: azure-pipelines-pr.yml)
┌──────────────────────────────────────────────────────────────┐
│ Trigger: PRs targeting main                                   │
│ Steps:                                                        │
│  - Restore/build SSDT (.sqlproj)                              │
│  - (Optional but recommended) Generate DACPAC                 │
│ Output: Pass/Fail status check back to PR                     │
└───────────────────────┬──────────────────────────────────────┘
                        │ Required status check + 1 approval
                        v
MERGE to MAIN (protected)
┌───────────────────────────────┐
│ main is always “green”         │
└───────────────┬───────────────┘
                │ push to main
                v
MAIN CI (Azure DevOps pipeline: azure-pipelines-ci.yml)
┌──────────────────────────────────────────────────────────────┐
│ Trigger: main only                                             │
│ Steps:                                                        │
│  - Build SSDT                                                  │
│  - Produce DACPAC (deterministic artifact)                     │
│  - Publish artifact (versioned by commit SHA / BuildId)        │
└───────────────┬──────────────────────────────────────────────┘
                │ Artifact becomes the ONLY deploy input
                v
DEPLOY (Azure DevOps “deployment” stages)
┌──────────────────────────────────────────────────────────────┐
│ Dev:    auto-deploy from CI artifact                           │
│ QA:     auto-deploy from CI artifact                           │
│ Staging: manual approval via Environment checks                │
│ Prod:    manual approval via Environment checks                │
│ Rule: always deploy the artifact produced from main            │
└──────────────────────────────────────────────────────────────┘

RUNTIME TARGETS (Docker on self-hosted agent)
Dev container  → deploy DACPAC (SqlPackage)
QA container   → deploy DACPAC (SqlPackage)
Staging cont.  → deploy DACPAC (SqlPackage) + approval gate
Prod container → deploy DACPAC (SqlPackage) + approval gate
