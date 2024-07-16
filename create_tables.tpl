param (
    [string]$serverName,
    [string]$databaseName,
    [string]$adminUserName,
    [String]$adminPassword
)

Import-Module SqlServer

$serverAddress = $($serverName + ".database.windows.net")

$tables = @("BRTDTable.sql", "FDTable.sql", "NRTDTable.sql")


foreach($sqlFilePath in $tables){

    $sqlScript = Get-Content -Path $sqlFilePath -Raw

    Invoke-Sqlcmd -ServerInstance $serverAddress -Username $adminUserName -Password $adminPassword -Database $databaseName -query $sqlScript
   
}