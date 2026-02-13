$containers = @("sql-dev","sql-qa","sql-staging","sql-prod")

foreach ($c in $containers) {
    Write-Host "Creating AppDb in $c ..."
    docker exec -it $c /opt/mssql-tools18/bin/sqlcmd `
        -S localhost `
        -U sa `
        -P "YourStrong!Passw0rd" `
        -C `
        -Q "IF DB_ID('AppDb') IS NULL CREATE DATABASE AppDb;"
}

Write-Host "Done."
