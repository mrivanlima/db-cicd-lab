param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("Dev","QA","Staging","Prod")]
  [string]$Environment
)

$ErrorActionPreference = "Stop"

# ---- Inputs (for now, hardcoded for local lab; later these become pipeline variables) ----
$DacpacPath = "database\AppDb.Database\bin\Debug\AppDb.Database.dacpac"
$DbName = "AppDb"
$User = "sa"
$Password = "YourStrong!Passw0rd"
$SqlPackage = "C:\Program Files\SqlPackage\sqlpackage.exe"

# ---- Map environment -> server/port ----
$TargetServerName = switch ($Environment) {
  "Dev"     { "localhost,14331" }
  "QA"      { "localhost,14332" }
  "Staging" { "localhost,14333" }
  "Prod"    { "localhost,14334" }
}

Write-Host "==> Deploying DACPAC to $Environment ($TargetServerName) / Database=$DbName"

# ---- Run deployment (state-based publish) ----
& $SqlPackage /Action:Publish `
  /SourceFile:$DacpacPath `
  /TargetServerName:$TargetServerName `
  /TargetDatabaseName:$DbName `
  /TargetUser:$User /TargetPassword:$Password `
  /TargetTrustServerCertificate:True `
  /p:BlockOnPossibleDataLoss=True

if ($LASTEXITCODE -ne 0) {
  throw "SqlPackage publish failed for environment: $Environment"
}

Write-Host "✅ Deployment succeeded for $Environment"
