param (
    [string]$iothubName,
    [string]$resourceGroupName
)

$devices = @("TemperatureSensor", "HumiditySensor", "VelocitySensor", "FuelLevelSensor", "SensorSystem")

foreach($device in $devices){
    
    try{       
        az iot hub device-identity create --device-id $device --hub-name $iothubName 
        Write-Host "iothubName: $iothubName"
    } catch{
    
    }
    
}