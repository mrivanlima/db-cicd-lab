$ErrorActionPreference = "Stop"

$DacpacPath = "database\AppDb.Database\bin\Debug\AppDb.Database.dacpac"

& "C:\Program Files\SqlPackage\sqlpackage.exe" `
  /Action:Publish `
  /SourceFile:$DacpacPath `
  /TargetServerName:"localhost,14331" `
  /TargetDatabaseName:"AppDb" `
  /TargetUser:"sa" `
  /TargetPassword:"YourStrong!Passw0rd" `
  /TargetTrustServerCertificate:True `
  /p:BlockOnPossibleDataLoss=True

Write-Host "Deployment to Dev complete."
