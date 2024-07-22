
Import-Module SqlServer

$serverAddress = $("${serverName}" + ".database.windows.net")

Write-Host "serverAddress: $serverAddress"

$sqlScript = Get-Content -Path "create_tables.sql" -Raw

Invoke-Sqlcmd -ServerInstance $serverAddress -Username ${adminUserName} -Password ${adminPassword} -Database ${databaseName} -query $sqlScript
  