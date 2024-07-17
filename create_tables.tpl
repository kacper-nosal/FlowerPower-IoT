
Import-Module SqlServer

$serverAddress = $($serverName + ".database.windows.net")

$tables = @("BRTDTable.sql", "FDTable.sql", "NRTDTable.sql")

Write-Host "username: $adminUserName"
Write-Host "password: $adminPassword"
Write-Host "server: $serverName"
Write-Host "database: $databaseName"

foreach($sqlFilePath in $tables){

    $sqlScript = Get-Content -Path $sqlFilePath -Raw

    Invoke-Sqlcmd -ServerInstance $serverAddress -Username $adminUserName -Password $adminPassword -Database $databaseName -query $sqlScript
   
}